import 'dart:async';
import 'dart:ui';

import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePasswd = true;
  bool _isVerificationView = false;
  String? _errorText;
  Timer? _timer;
  int _timerDuration = 30;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerDuration = 30;
      _isTimerRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerDuration > 0) {
        setState(() {
          _timerDuration--;
        });
      } else {
        setState(() {
          _isTimerRunning = false;
        });
        timer.cancel();
      }
    });
  }

  void _isPasswdMatch(String value1, TextEditingController value2) {
    setState(() {
      if (value2.text.isNotEmpty && value1 != value2.text) {
        _errorText = 'Passwords do not match';
      } else {
        _errorText = null;
      }
    });
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    bool obscure = false,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
    VoidCallback? onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: errorText != null
              ? Colors.redAccent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.redAccent),
          suffixIcon: onToggle != null
              ? GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _animatedButton({
    required String label,
    required VoidCallback? onTap,
    bool outlined = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              outlined ? Colors.transparent : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: Colors.white)
              : Border.all(color: Colors.transparent),
          boxShadow: outlined
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: outlined ? Colors.white : (textColor ?? Colors.blue),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.2),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildModernTextField(
          label: "Email",
          icon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          label: "Password",
          icon: Icons.lock_outline,
          controller: _passwordController,
          obscure: _obscurePasswd,
          onToggle: () => setState(() => _obscurePasswd = !_obscurePasswd),
          onChanged: (value) =>
              _isPasswdMatch(value, _confirmPasswordController),
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          label: "Confirm Password",
          icon: Icons.lock_outline,
          controller: _confirmPasswordController,
          obscure: _obscurePasswd,
          errorText: _errorText,
          onToggle: () => setState(() => _obscurePasswd = !_obscurePasswd),
          onChanged: (value) => _isPasswdMatch(value, _passwordController),
        ),
        const SizedBox(height: 30),
        _animatedButton(
          label: "Sign Up",
          onTap: () {
            if (_errorText == null &&
                _emailController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty) {
              context.read<AuthBloc>().add(
                    RegisterEmailPaswdEvent(
                      email: _emailController.text,
                      paswd: _passwordController.text,
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Already have an account? Login",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Verify your Email",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a verification link to\n${_emailController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        _animatedButton(
          label:
              _isTimerRunning ? "Resend in $_timerDuration s" : "Resend Email",
          onTap: _isTimerRunning
              ? null
              : () {
                  context.read<AuthBloc>().add(SendVerificationToEmailEvent());
                  _startTimer();
                },
          backgroundColor: _isTimerRunning ? Colors.grey : Colors.white,
          textColor: _isTimerRunning ? Colors.white : Colors.blue,
        ),
        const SizedBox(height: 15),
        _animatedButton(
          label: "I Verified It, Login",
          outlined: true,
          onTap: () {
            // Navigate back to login to let user sign in with verified account
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UserShouldVerifyEmailState) {
          setState(() {
            _isVerificationView = true;
          });
          _startTimer();
          // Trigger the email sending immediately
          context.read<AuthBloc>().add(SendVerificationToEmailEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              // Gradient Background (Same as PublicPage)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1d2671), Color(0xffc33764)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: _isVerificationView
                                  ? _buildVerificationView()
                                  : _buildRegisterForm(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Loading Overlay
              if (state is LoadingState)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
