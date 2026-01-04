import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quify/features/auth/data/models/user_model.dart';

/// Provider for Firestore database operations
/// Handles all user data interactions with Cloud Firestore
class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Creates a new user document in Firestore
  Future<void> createUser(UserModel user) async {
    if (user.uid.isEmpty) {
      throw Exception('UID cannot be empty');
    }
    final data = user.toMap();
    if (data['createdAt'] == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection(_usersCollection).doc(user.uid).set(data);
  }

  /// Retrieves user data by UID
  Future<UserModel?> getUserByUid(String uid) async {
    if (uid.isEmpty) {
      return null;
    }
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Retrieves user data by username (case-insensitive)
  /// Uses usernameLowercase field for efficient querying
  Future<UserModel?> getUserByUsername(String username) async {
    if (username.isEmpty) {
      return null;
    }
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('usernameLowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return UserModel.fromMap(querySnapshot.docs.first.data());
  }

  /// Gets email address associated with a username
  /// Used for username-based login
  Future<String?> getEmailByUsername(String username) async {
    if (username.isEmpty) {
      return null;
    }
    final user = await getUserByUsername(username);
    return user?.email;
  }

  /// Checks if a username already exists in the database
  Future<bool> usernameExists(String username) async {
    if (username.isEmpty) {
      return false;
    }
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('usernameLowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  /// Updates user document in Firestore
  /// Automatically updates usernameLowercase when username is changed
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) {
      throw Exception('UID cannot be empty');
    }
    if (data.containsKey('username') && data['username'] != null) {
      data['usernameLowercase'] = (data['username'] as String).toLowerCase();
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_usersCollection).doc(uid).update(data);
  }

  /// Sets up user profile with full name and username
  /// Creates usernameLowercase field for case-insensitive username queries
  Future<void> setupProfile({
    required String uid,
    required String email,
    required String fullName,
    required String username,
  }) async {
    if (uid.isEmpty) {
      throw Exception('UID cannot be empty');
    }
    if (username.isEmpty) {
      throw Exception('Username cannot be empty');
    }

    final userRef = _firestore.collection(_usersCollection).doc(uid);
    await userRef.set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'usernameLowercase': username.toLowerCase(),
      'isSetupProfile': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
