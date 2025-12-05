// ignore_for_file: deprecated_member_use

import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PublicPage2 extends StatefulWidget {
  final Widget privatePage;
  const PublicPage2({super.key, required this.privatePage});

  @override
  PublicPage2State createState() => PublicPage2State();
}

class PublicPage2State extends State<PublicPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _containerColorAnimation;
  late Animation<double> _buttonScaleAnimation;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePaswd = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _containerColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withOpacity(0.97),
    ).animate(_animationController);

    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginEmailPaswdEven(
          email: _emailController.text,
          paswd: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.toString())),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is UserShouldVerifyEmailState) {
          Navigator.pushNamed(context, "/confirm_email");
        } else if (state is TooManyRequestState) {
          Navigator.pushNamed(context, "/wait_a_little");
        } else if (state is PasswordResetSendedToEmailState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text("Password reset email sent!"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return widget.privatePage;
        } else {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: AnimatedOpacity(
                opacity: _animationController.value,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                // Gradient Background
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primaryContainer.withOpacity(0.1),
                            theme.colorScheme.secondaryContainer
                                .withOpacity(0.1),
                            theme.colorScheme.tertiaryContainer
                                .withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),

                // Animated Background Shapes
                Positioned(
                  top: -100,
                  right: -100,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOut,
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.primary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -150,
                  left: -100,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOut,
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.secondary.withOpacity(0.1),
                          theme.colorScheme.secondary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 100,
                          bottom: 40,
                        ),
                        height: screenHeight,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Logo/Icon Section
                          ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.lock_open_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 40,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Login Form Container
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Material(
                                elevation: 20,
                                borderRadius: BorderRadius.circular(20),
                                color: _containerColorAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Email Field
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Enter your email',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        prefixIcon: Icon(
                                          Icons.email_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePaswd,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        prefixIcon: Icon(
                                          Icons.lock_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscurePaswd = !_obscurePaswd;
                                            });
                                          },
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            transitionBuilder:
                                                (child, animation) {
                                              return ScaleTransition(
                                                scale: animation,
                                                child: child,
                                              );
                                            },
                                            child: Icon(
                                              _obscurePaswd
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              key:
                                                  ValueKey<bool>(_obscurePaswd),
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, "/forgot_paswd");
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Login Button
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _buttonScaleAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: ElevatedButton(
                                      onPressed: _onLoginPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        elevation: 8,
                                        shadowColor: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        animationDuration:
                                            const Duration(milliseconds: 200),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: state is LoadingState
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    theme.colorScheme.onPrimary,
                                                  ),
                                                ),
                                              )
                                            : const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 20),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register Button
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Login Button
                          OutlinedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(LoginGoogleEvent());
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface,
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/google.png',
                                  height: 24,
                                  width: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.account_circle_outlined,
                                      color: Colors.grey[700],
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Loading Overlay
                if (state is LoadingState)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: Colors.white.withOpacity(0.85),
                  ),
                if (state is LoadingState)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.staggeredDotsWave(
                          color: theme.colorScheme.primary,
                          size: 100,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Signing you in...",
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
