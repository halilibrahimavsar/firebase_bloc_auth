import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPaswdPage extends StatefulWidget {
  const ForgotPaswdPage({super.key});

  @override
  ForgotPasswordFormState createState() => ForgotPasswordFormState();
}

class ForgotPasswordFormState extends State<ForgotPaswdPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(SendPaswdResetEvent(email: _emailController.text));
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
