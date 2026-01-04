import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/features/auth/data/models/user_model.dart';
import 'package:quify/features/auth/data/providers/auth_provider.dart' as auth_provider;
import 'package:quify/features/auth/data/providers/firestore_provider.dart';

class AuthRepository {
  final auth_provider.AuthProvider _authProvider = auth_provider.AuthProvider();
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  Future<UserCredential?> login(String emailOrUsername, String password) async {
    try {
      if (emailOrUsername.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Email hoặc tên đăng nhập không được để trống',
        );
      }
      
      String email = emailOrUsername;
      
      // Check if input is username (doesn't contain @)
      if (!emailOrUsername.contains('@')) {
        final userEmail = await _firestoreProvider.getEmailByUsername(emailOrUsername);
        if (userEmail == null || userEmail.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Tên đăng nhập không tồn tại',
          );
        }
        email = userEmail;
      }
      
      return await _authProvider.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _authProvider.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    await _authProvider.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _authProvider.reloadUser();
  }

  Future<bool> isEmailVerified() async {
    await _authProvider.reloadUser();
    return _authProvider.currentUser?.emailVerified ?? false;
  }

  Future<void> logout() async {
    try {
      await _authProvider.signOut();
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _authProvider.currentUser;
  }

  Stream<User?> get authStateChanges => _authProvider.authStateChanges;

  // Firestore methods
  Future<void> createUser(String uid, String email) async {
    final userModel = UserModel(
      uid: uid,
      email: email,
      isSetupProfile: false,
      createdAt: DateTime.now(),
    );
    await _firestoreProvider.createUser(userModel);
  }

  Future<bool> usernameExists(String username) async {
    return await _firestoreProvider.usernameExists(username);
  }

  Future<void> setupProfile({
    required String uid,
    required String email,
    required String fullName,
    required String username,
  }) async {
    await _firestoreProvider.setupProfile(
      uid: uid,
      email: email,
      fullName: fullName,
      username: username,
    );
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    if (uid.isEmpty) {
      return null;
    }
    final user = await _firestoreProvider.getUserByUid(uid);
    return user?.toMap();
  }

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? username,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (username != null) data['username'] = username;
    
    await _firestoreProvider.updateUser(uid, data);
  }
}
