import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/firebase_service.dart';

class UserDataReferances {
  static final FirebaseFirestore userRef =
      FirestoreService().getCurrentUserDocRef().collection("users").firestore;
  static final uud = FirestoreService().getCurrentUserDocRef().id;
}
