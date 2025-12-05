import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PublicPage extends StatefulWidget {
  final Widget privatePage;
  const PublicPage({super.key, required this.privatePage});

  @override
  PublicPageState createState() => PublicPageState();
}

class PublicPageState extends State<PublicPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePaswd = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    context.read<AuthBloc>().add(IsAuthenticatedEvent());

    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UserShouldVerifyEmailState) {
          Navigator.pushNamed(context, "/confirm_email");
        } else if (state is TooManyRequestState) {
          Navigator.pushNamed(context, "/wait_a_little");
        } else if (state is PasswordResetSendedToEmailState) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset Sended")),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return widget.privatePage;
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Welcome"),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _animation,
                    child: Padding(
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
                            obscureText: _obscurePaswd,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePaswd
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePaswd = !_obscurePaswd;
                                  });
                                },
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/forgot_paswd");
                            },
                            style: ButtonStyle(
                              textStyle: WidgetStateProperty.all(
                                const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            child: const Text("Forgot Password?"),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(LoginEmailPaswdEven(
                                  email: _emailController.text,
                                  paswd: _passwordController.text));
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              textStyle: const TextStyle(fontSize: 18),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              textStyle: const TextStyle(fontSize: 18),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: const Text('Register'),
                          ),
                          const SizedBox(height: 20.0),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<AuthBloc>().add(LoginGoogleEvent());
                            },
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Login with Google'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is LoadingState)
                  Container(
                    color: Colors.white
                        .withValues(alpha: 0.7), // Adjust opacity as needed
                  ),
                if (state is LoadingState)
                  Center(
                    child: LoadingAnimationWidget.newtonCradle(
                      color: Colors.black,
                      size: 150,
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
