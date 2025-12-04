import 'package:auth_demo/components/my_button.dart';
import 'package:auth_demo/components/my_textfield.dart';
import 'package:auth_demo/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthUnauthenticated) {
            return EmailScreenWidget();
          }
          if (state is AuthSendCode) {
            return CodeScreenWideget();
          }
          if (state is AuthAuthenticated) {
            return MainScreenWidget(user_id: state.userId);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class EmailScreenWidget extends StatelessWidget {
  EmailScreenWidget({super.key});
  final emailController = TextEditingController();

  void signUserIn(BuildContext context) {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email);

    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Некорректный формат email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<AuthCubit>().sendCode(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Добро пожаловать!',
                  style: TextStyle(color: Colors.blueGrey[700], fontSize: 18),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                MyButton(
                  onTab: () => signUserIn(context),
                  text: 'Получить код',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CodeScreenWideget extends StatelessWidget {
  CodeScreenWideget({super.key});
  final codeController = TextEditingController();

  void signUserIn(BuildContext context) {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите код'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final state = context.read<AuthCubit>().state;
    if (state is AuthSendCode) {
      context.read<AuthCubit>().confirmCode(state.email, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Введите код из сообщения',
                  style: TextStyle(color: Colors.blueGrey[700], fontSize: 18),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: codeController,
                  hintText: 'Код (цифры)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 10),
                MyButton(onTab: () => signUserIn(context), text: 'Войти'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreenWidget extends StatelessWidget {
  const MainScreenWidget({super.key, required this.user_id});
  final String user_id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Вы успешно авторизованы!',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              'Ваш ID: $user_id',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () => context.read<AuthCubit>().Logout(),
              child: const Text('Выйти', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
