import 'dart:ui';
import 'package:firebase_bloc_auth/src/authentication/biometric_service.dart';
import 'package:flutter/material.dart';

class BiometricAuthPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const BiometricAuthPage({super.key, required this.onSuccess});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage>
    with SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _showPinInput = false;
  bool _isBiometricAvailable = false;
  bool _isPinEnabled = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkAuthMethods();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthMethods() async {
    final biometricAvailable = await _biometricService.isBiometricAvailable();
    final biometricEnabled = await _biometricService.isBiometricEnabled();
    final pinEnabled = await _biometricService.isPinCodeSet();

    setState(() {
      _isBiometricAvailable = biometricAvailable;
      _isPinEnabled = pinEnabled;
    });

    // Auto-trigger biometric if enabled
    if (biometricEnabled && biometricAvailable) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authenticated = await _biometricService.authenticateWithBiometrics();
    if (authenticated) {
      widget.onSuccess();
    }
  }

  void _verifyPin() async {
    if (_pinController.text.isEmpty) {
      setState(() => _errorText = 'Please enter your PIN');
      return;
    }

    final isCorrect =
        await _biometricService.verifyPinCode(_pinController.text);
    if (isCorrect) {
      widget.onSuccess();
    } else {
      setState(() => _errorText = 'Incorrect PIN');
      _pinController.clear();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Secure Access',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showPinInput
                          ? 'Enter your PIN to continue'
                          : 'Authenticate to access your account',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    if (!_showPinInput) ...[
                      // Biometric Button
                      if (_isBiometricAvailable)
                        _buildAuthButton(
                          icon: Icons.fingerprint,
                          label: 'Use Biometric',
                          onTap: _authenticateWithBiometric,
                        ),

                      if (_isBiometricAvailable && _isPinEnabled)
                        const SizedBox(height: 16),

                      // PIN Button
                      if (_isPinEnabled)
                        _buildAuthButton(
                          icon: Icons.dialpad,
                          label: 'Use PIN',
                          onTap: () => setState(() => _showPinInput = true),
                          outlined: true,
                        ),
                    ] else ...[
                      // PIN Input
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _pinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    letterSpacing: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '• • • •',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    counterText: '',
                                    errorText: _errorText,
                                    errorStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onChanged: (_) {
                                    setState(() => _errorText = null);
                                  },
                                  onSubmitted: (_) => _verifyPin(),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _showPinInput = false;
                                            _pinController.clear();
                                            _errorText = null;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Back'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _verifyPin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                outlined ? Colors.transparent : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(outlined ? 0.5 : 0.3),
              width: outlined ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
