import 'dart:developer';

import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_exceptions.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_user_repository.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/shared_auth_providr.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomEmailAuthProvider extends CustomSharedAuthProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<AuthUserRepository?> registerUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    /// If register successful, return [AuthUserRepository]. Otherwise return [null]
    UserCredential userCredential = await auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((error, stackTrace) {
      if (error.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (error.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (error.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (error.code == "too-many-requests") {
        throw TooManyRequestException();
      } else {
        throw GenericAuthException(cause: error + stackTrace);
      }
    });
    if (userCredential.user != null) {
      CustomSharedAuthProvider.currentUsr =
          AuthUserRepository.fromFirebase(userCredential.user!);
      return CustomSharedAuthProvider.currentUsr;
    }
    return null;
  }

  Future<AuthUserRepository?> logIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }
    UserCredential userCredent = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((error, stackTrace) {
      if (error.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (error.code == 'user-disabled') {
        throw UserDisabledAuthException();
      } else if (error.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (error.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (error.code == "invalid-credential") {
        throw InvalidCredentialException();
      } else if (error.code == "too-many-requests") {
        throw TooManyRequestException();
      } else {
        log("error is ${error.code}");
        throw GenericAuthException();
      }
    });
    if (userCredent.user != null) {
      CustomSharedAuthProvider.currentUsr =
          AuthUserRepository.fromFirebase(userCredent.user!);
      return CustomSharedAuthProvider.currentUsr;
    }
    return null;
  }

  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification().catchError((error, stackTrace) {
        if (error.code == "too-many-requests") {
          throw TooManyRequestException();
        } else {
          throw GenericAuthException(cause: error);
        }
      });
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  Future<bool> sendPasswordReset({required String toEmail}) async {
    bool isSended = false;
    await auth.sendPasswordResetEmail(email: toEmail).then((value) {
      isSended = true;
    }).catchError((error, stackTrace) {
      throw PasswdResetException(error: error.toString());
    });

    return isSended;
  }

  Future<bool> updateName(String name) async {
    bool isUpdated = false;
    await auth.currentUser
        ?.updateDisplayName(name)
        .then((value) => isUpdated = true);
    return isUpdated;
  }

  Future<bool> updatePaswd(String passwd) async {
    bool isUpdated = false;
    await auth.currentUser
        ?.updatePassword(passwd)
        .then((value) => isUpdated = true)
        .catchError((error, stackTrace) {
      if (error.code == "weak-password") {
        throw WeakPasswordAuthException();
      } else if (error.code == "requires-recent-login") {
        throw RequiresRecentLoginException();
      } else {
        throw GenericAuthException(cause: error);
      }
    });
    return isUpdated;
  }
}
