import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing Firestore user collections
/// This service provides methods to:
/// - Create user documents in Firestore
/// - Get reference to current user's document
/// - Access subcollections within user documents
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Creates a user document in Firestore with basic info
  /// Called automatically when [createUserCollection] is true
  Future<void> createUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection(_usersCollection).doc(user.uid);

      // Check if document already exists
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  /// Updates user document with new information
  Future<void> updateUserDocument(User user, Map<String, dynamic> data) async {
    try {
      final userDoc = _firestore.collection(_usersCollection).doc(user.uid);
      await userDoc.update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  /// Gets the DocumentReference for the current user
  /// Use this to create subcollections in your project
  /// Example:
  /// ```dart
  /// final userRef = FirestoreService().getCurrentUserDocRef();
  /// final tasksCollection = userRef.collection('tasks');
  /// await tasksCollection.add({'title': 'My Task'});
  /// ```
  DocumentReference getCurrentUserDocRef() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return _firestore.collection(_usersCollection).doc(currentUser.uid);
  }

  /// Gets the DocumentReference for a specific user by UID
  DocumentReference getUserDocRef(String uid) {
    return _firestore.collection(_usersCollection).doc(uid);
  }

  /// Gets the current user's document data
  Future<DocumentSnapshot> getCurrentUserDoc() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return await _firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .get();
  }

  /// Gets a specific subcollection reference for the current user
  /// Example:
  /// ```dart
  /// final tasksCollection = FirestoreService().getUserSubcollection('tasks');
  /// await tasksCollection.add({'title': 'My Task'});
  /// ```
  CollectionReference getUserSubcollection(String subcollectionName) {
    return getCurrentUserDocRef().collection(subcollectionName);
  }

  /// Stream of current user's document
  /// Useful for real-time updates
  Stream<DocumentSnapshot> getCurrentUserStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return _firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .snapshots();
  }

  /// Deletes the current user's document and all subcollections
  /// Use with caution!
  Future<void> deleteCurrentUserDocument() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    await _firestore.collection(_usersCollection).doc(currentUser.uid).delete();
  }
}
