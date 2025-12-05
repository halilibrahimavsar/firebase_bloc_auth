import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePasswd = true;

  String? _errorText;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePasswd,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePasswd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePasswd =
                          !_obscurePasswd; // Toggle the visibility of the password
                    });
                  },
                ),
              ),
              onChanged: (value) {
                _isPasswdMatch(value, _confirmPasswordController);
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscurePasswd,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                errorText: _errorText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePasswd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePasswd =
                          !_obscurePasswd; // Toggle the visibility of the password
                    });
                  },
                ),
              ),
              onChanged: (value) {
                _isPasswdMatch(value, _passwordController);
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // checking password match
                if (_errorText == null) {
                  // Check if passwords match

                  context.read<AuthBloc>().add(
                        RegisterEmailPaswdEvent(
                          email: _emailController.text,
                          paswd: _passwordController.text,
                        ),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _isPasswdMatch(String value1, TextEditingController value2) {
    return setState(() {
      if ((value1.length == value2.text.length) && (value1 != value2.text)) {
        _errorText = 'Passwords do not match';
      } else if (value1.length < value2.text.length) {
        _errorText = 'Write something, maybe it can match';
      } else if (value1.length > value2.text.length) {
        _errorText = 'Stooopp, its getting worse';
      } else {
        _errorText = null;
      }
    });
  }
}
