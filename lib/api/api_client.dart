import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final _storage = FlutterSecureStorage();
  final String _baseUrl = 'https://d5dsstfjsletfcftjn3b.apigw.yandexcloud.net';
  Future<void> sendCode(String email) async {
    var url = Uri.parse('$_baseUrl/login');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка отправки кода: ${response.statusCode}');
    }
  }

  Future<void> confirm_code(String email, int code) async {
    var url = Uri.parse(
      'https://d5dsstfjsletfcftjn3b.apigw.yandexcloud.net/confirm_code',
    );
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String jwt = body['jwt']!;
      String rt = body['refresh_token']!;
      await _saveTokens(jwt, rt);
    } else {
      throw Exception('Неверный код или ошибка сервера');
    }
  }

  Future<String> getUserId() async {
    String? token = await _storage.read(key: "jwt");
    if (token == null) throw Exception("Не авторизован");
    var url = Uri.parse('$_baseUrl/auth');
    var response = await http.get(url, headers: {'Auth': 'Bearer $token'});
    // Если токен протух (401), пробуем обновить
    if (response.statusCode == 401) {
      token = await _refreshToken();
      response = await http.get(url, headers: {'Auth': 'Bearer $token'});
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['user_id'].toString();
    } else {
      throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
    }
  }

  Future<String> _refreshToken() async {
    final rt = await _storage.read(key: 'refresh_token');
    if (rt == null) throw Exception('Нет RT, нужен ре-логин');

    final url = Uri.parse('$_baseUrl/refresh_token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': rt}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await _saveTokens(body['jwt'], body['refresh_token']);
      return body['jwt'];
    } else {
      await logout();
      throw Exception('Сессия истекла');
    }
  }

  Future<void> _saveTokens(String jwt, String rt) async {
    await _storage.write(key: 'jwt', value: jwt);
    await _storage.write(key: 'refresh_token', value: rt);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'jwt');
    return token != null;
  }
}
