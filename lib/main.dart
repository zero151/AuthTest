import 'package:auth_demo/api/api_client.dart';
import 'package:auth_demo/cubit/auth_cubit.dart';
import 'package:auth_demo/screen/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (context) => AuthCubit(ApiClient()),
        child: AuthScreen(),
      ),
    );
  }
}
