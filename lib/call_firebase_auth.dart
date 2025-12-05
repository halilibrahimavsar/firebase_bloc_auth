import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:firebase_bloc_auth/src/views/private_pages/profile_update_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/confirm_email_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/forgot_paswd_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/public_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/register_page.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/wait_a_little_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'call_firebase_auth.dart';
export 'package:firebase_bloc_auth/src/authentication/auth_services/auth_user_repository.dart';
export 'package:firebase_bloc_auth/src/views/private_pages/profile_update_page.dart';

/// Before using this package, you should initialize and setup your firebase
/// console into your project. After that you should call
/// below two lines in your main function;
/// {@tool snippet}

/// ```dart
/// WidgetsFlutterBinding.ensureInitialized();
///  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
/// ```
/// {@end-tool}
/// This file includes the Firebase Auth library, so you can simply invoke
/// `CallFirebaseAuth(privateWidget: YourWidget)` and everything will be taken care of.
/// If the user logs in successfully, your private widget will be displayed.
/// You can acces user details by calling [AuthUser]
/// and then you can call [ProfileUpdatePage] wherever you want
class CallFirebaseAuth extends StatelessWidget {
  final Widget privateWidget;
  const CallFirebaseAuth({super.key, required this.privateWidget});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        routes: {
          '/public': (context) => PublicPage(privatePage: privateWidget),
          '/private': (context) => const ProfileUpdatePage(),
          '/register': (context) => const RegisterPage(),
          '/wait_a_little': (context) => const WaitALittlePage(),
          '/confirm_email': (context) => const ConfirmEmailPage(),
          '/forgot_paswd': (context) => const ForgotPaswdPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter App',
        home: PublicPage(privatePage: privateWidget),
      ),
    );
  }
}
