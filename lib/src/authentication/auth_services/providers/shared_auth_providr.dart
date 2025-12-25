import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_exceptions.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomSharedAuthProvider {
  static AuthUserRepository? currentUsr;

  Future<AuthUserRepository?> isAuthenticated() async {
    // if previously signed in, return user. Otherwise return null
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      currentUsr = AuthUserRepository.fromFirebase(user);
    } else {
      currentUsr = null;
    }
    return currentUsr;
  }

  Future<void> logOut() async {
    await GoogleSignIn.instance.signOut().catchError(
          (error, stackTrace) => throw GoogleLogoutException(),
        );

    await FirebaseAuth.instance.signOut().catchError(
          (error, stackTrace) => throw FirebaseLogoutException(),
        );
  }
}
