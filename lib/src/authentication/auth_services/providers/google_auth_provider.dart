import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_exceptions.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_user_repository.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/shared_auth_providr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomGoogleAuthProvider extends CustomSharedAuthProvider {
  Future<AuthUserRepository?> googleLogin() async {
    // -----------Google stuff-------------
    // Get configurations
    final GoogleSignIn googleSignn = GoogleSignIn();
    // sign in user
    final GoogleSignInAccount? googleUsr =
        await googleSignn.signIn().then((gUser) {
      if (gUser != null) {
        return gUser;
      } else {
        throw UserDisabledAuthException();
      }
    });
    // Obtain the auth details from user(if signed in successfully into google)
    final GoogleSignInAuthentication? googlAuth =
        await googleUsr?.authentication;
    // Create credential for Firebase
    final gUserCredential = GoogleAuthProvider.credential(
      accessToken: googlAuth?.accessToken,
      idToken: googlAuth?.idToken,
    );

    // -----------Firebase stuff-------------
    // Once signed in, return the User
    UserCredential userCredent = await FirebaseAuth.instance
        .signInWithCredential(gUserCredential)
        .catchError(
      (error, stackTrace) {
        if (error.code == 'invalid-credential') {
          throw InvalidCredentialException();
        } else if (error.code == 'user-disabled') {
          throw UserDisabledAuthException();
        } else if (error.code == 'user-not-found') {
          throw UserNotFoundAuthException();
        } else if (error.code == 'wrong-password') {
          throw WrongPasswordAuthException();
        } else if (error.code == 'invalid-verification-code') {
          throw InvalidVerificationCodeException();
        } else if (error.code == 'invalid-verification-id') {
          throw InvalidVerificationIdException();
        } else if (error.code == 'account-exists-with-different-credential') {
          throw AccExistWithDifferentCredentialException();
        } else if (error.code == 'operation-not-allowed') {
          throw OperationNotAllowedException();
        } else {
          throw GenericAuthException();
        }
      },
    );

    if (userCredent.user != null) {
      CustomSharedAuthProvider.currentUsr =
          AuthUserRepository.fromFirebase(userCredent.user!);
      return CustomSharedAuthProvider.currentUsr;
    }
    return null;
  }
}
