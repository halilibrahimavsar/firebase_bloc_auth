import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:firebase_bloc_auth/src/authentication/biometric_service.dart';
import 'package:firebase_bloc_auth/src/views/private_pages/security_settings_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_app/restart_app.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  ProfileUpdatePageState createState() => ProfileUpdatePageState();
}

class ProfileUpdatePageState extends State<ProfileUpdatePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController oldPasswordController;
  late TextEditingController passwordController1;
  late TextEditingController passwordController2;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  final BiometricService _biometricService = BiometricService();
  String? _errorText;
  bool _obscureOldPassword = true;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _isBiometricEnabled = false;
  bool _isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.displayName ?? 'User');
    oldPasswordController = TextEditingController();
    passwordController1 = TextEditingController();
    passwordController2 = TextEditingController();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    animationController.forward();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    final biometric = await _biometricService.isBiometricEnabled();
    final pin = await _biometricService.isPinCodeSet();
    setState(() {
      _isBiometricEnabled = biometric;
      _isPinEnabled = pin;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    oldPasswordController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUpdateErrorState) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.toString())),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NameUpdatedState) {
            nameController.text = state.newName;
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProfileCard(user),
                          const SizedBox(height: 20),
                          _buildSecurityCard(),
                          const SizedBox(height: 20),
                          _buildUpdateNameCard(),
                          const SizedBox(height: 20),
                          _buildUpdatePasswordCard(),
                          const SizedBox(height: 20),
                          _buildLogoutButton(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Text(
                    (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SecuritySettingsPage(),
              ),
            );
            _loadSecuritySettings();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isBiometricEnabled || _isPinEnabled
                            ? 'Security enabled'
                            : 'Setup biometric or PIN',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateNameCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Update Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  bool result = await showCustmDialog(
                    context,
                    title: "Update Name",
                    msg: "Do you want to update your name?",
                    cancelButton: "Cancel",
                    confirmButton: "Update",
                    color: Colors.green,
                    functionWhenConfirm: () {},
                  );
                  if (result && mounted) {
                    context.read<AuthBloc>().add(
                          UpdateNameEvent(name: nameController.text),
                        );
                    await Future.delayed(const Duration(seconds: 1));
                    Restart.restartApp();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatePasswordCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Update Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                labelText: 'Old Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureOldPassword = !_obscureOldPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController1,
              obscureText: _obscurePassword1,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword1 ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword1 = !_obscurePassword1);
                  },
                ),
              ),
              onChanged: (value) {
                _isPasswdMatch(value, passwordController2);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController2,
              obscureText: _obscurePassword2,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outlined),
                errorText: _errorText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword2 ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword2 = !_obscurePassword2);
                  },
                ),
              ),
              onChanged: (value) {
                _isPasswdMatch(value, passwordController1);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _errorText == null
                    ? () async {
                        if (oldPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your old password"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null && user.email != null) {
                            AuthCredential credential =
                                EmailAuthProvider.credential(
                              email: user.email!,
                              password: oldPasswordController.text,
                            );
                            await user.reauthenticateWithCredential(credential);
                          }
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Old password incorrect: ${e.message}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        bool result = await showCustmDialog(
                          context,
                          title: "Update Password",
                          msg: "Do you want to update your password?",
                          cancelButton: "Cancel",
                          confirmButton: "Update",
                          color: Colors.orange,
                          functionWhenConfirm: () {},
                        );
                        if (result && mounted) {
                          context.read<AuthBloc>().add(
                                UpdatePasswdEvent(
                                    passwd: passwordController1.text),
                              );
                          await Future.delayed(const Duration(seconds: 1));
                          Restart.restartApp();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            bool result = await showCustmDialog(
              context,
              title: "Log Out",
              msg: "Are you sure you want to log out?",
              cancelButton: "Cancel",
              confirmButton: "Log Out",
              color: Colors.red,
              functionWhenConfirm: () {},
            );
            if (context.mounted && result) {
              context.read<AuthBloc>().add(LogoutEvent());
              await Future.delayed(const Duration(seconds: 1));
              Restart.restartApp();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Colors.red, size: 22),
                const SizedBox(width: 12),
                const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
