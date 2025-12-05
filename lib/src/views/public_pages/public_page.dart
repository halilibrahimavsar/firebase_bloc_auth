// ignore_for_file: deprecated_member_use

import 'dart:ui';
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
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscure = true;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    context.read<AuthBloc>().add(IsAuthenticatedEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    bool obscure = false,
    TextEditingController? controller,
    VoidCallback? onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: onToggle != null
              ? GestureDetector(
                  onTap: onToggle,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, anim) =>
                        RotationTransition(turns: anim, child: c),
                    child: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      key: ValueKey(obscure),
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _animatedButton({
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
    IconData? icon,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: outlined
                ? Border.all(color: Colors.white)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, color: outlined ? Colors.white : Colors.blue),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: outlined ? Colors.white : Colors.blue,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.toString())),
          );
        } else if (state is UserShouldVerifyEmailState) {
          Navigator.pushNamed(context, "/confirm_email");
        } else if (state is TooManyRequestState) {
          Navigator.pushNamed(context, "/wait_a_little");
        } else if (state is PasswordResetSendedToEmailState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset sent")),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return widget.privatePage;
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 🔵 Gradient Arkaplan
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1d2671), Color(0xffc33764)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // İçerik
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Welcome",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(.2),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _buildModernTextField(
                                  label: "Email",
                                  icon: Icons.email,
                                  controller: _emailController,
                                ),
                                const SizedBox(height: 20),
                                _buildModernTextField(
                                  label: "Password",
                                  icon: Icons.lock,
                                  controller: _passwordController,
                                  obscure: _obscure,
                                  onToggle: () {
                                    setState(() => _obscure = !_obscure);
                                  },
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, "/forgot_paswd"),
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _animatedButton(
                                  label: "Login",
                                  onTap: () {
                                    context.read<AuthBloc>().add(
                                          LoginEmailPaswdEven(
                                            email: _emailController.text,
                                            paswd: _passwordController.text,
                                          ),
                                        );
                                  },
                                ),
                                const SizedBox(height: 15),
                                _animatedButton(
                                  label: "Register",
                                  onTap: () =>
                                      Navigator.pushNamed(context, "/register"),
                                ),
                                const SizedBox(height: 15),
                                _animatedButton(
                                  label: "Login with Google",
                                  outlined: true,
                                  icon: Icons.account_circle_outlined,
                                  onTap: () {
                                    context
                                        .read<AuthBloc>()
                                        .add(LoginGoogleEvent());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔄 Loading Overlay
              if (state is LoadingState)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              if (state is LoadingState)
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 80,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
