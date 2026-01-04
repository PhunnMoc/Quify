import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quify/features/auth/data/models/user_model.dart';

class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Create user document
  Future<void> createUser(UserModel user) async {
    if (user.uid.isEmpty) {
      throw Exception('UID cannot be empty');
    }
    final data = user.toMap();
    // Ensure createdAt is set if not provided
    if (data['createdAt'] == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection(_usersCollection).doc(user.uid).set(data);
  }

  // Get user by UID
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

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    if (username.isEmpty) {
      return null;
    }
    // Query users collection by usernameLowercase field (case-insensitive)
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

  // Get email by username
  Future<String?> getEmailByUsername(String username) async {
    if (username.isEmpty) {
      return null;
    }
    final user = await getUserByUsername(username);
    return user?.email;
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    if (username.isEmpty) {
      return false;
    }
    // Query users collection by usernameLowercase field (case-insensitive)
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('usernameLowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) {
      throw Exception('UID cannot be empty');
    }
    // If username is being updated, also update usernameLowercase
    if (data.containsKey('username') && data['username'] != null) {
      data['usernameLowercase'] = (data['username'] as String).toLowerCase();
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_usersCollection).doc(uid).update(data);
  }

  // Setup profile (create user document)
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
    
    // Create/update user document with username and usernameLowercase
    final userRef = _firestore.collection(_usersCollection).doc(uid);
    await userRef.set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'usernameLowercase': username.toLowerCase(), // For case-insensitive queries
      'isSetupProfile': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

