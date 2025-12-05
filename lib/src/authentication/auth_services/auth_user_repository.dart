import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

@immutable
class AuthUserRepository {
  final String id;
  final String email;
  final bool isEmailVerified;
  final User userDetail;

  const AuthUserRepository({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.userDetail,
  });

  // Named constructor
  AuthUserRepository.fromFirebase(User user)
      : id = user.uid,
        email =
            user.email ?? user.providerData.first.email ?? "cant extract email",
        isEmailVerified = user.emailVerified,
        userDetail = user;

  @override
  String toString() => 'Email:$email\nId:$id\nisEmailVerified:$isEmailVerified';
}
