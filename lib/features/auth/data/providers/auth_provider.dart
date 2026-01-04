import 'package:firebase_auth/firebase_auth.dart';

/// Provider for Firebase Authentication operations
/// Handles direct interactions with Firebase Auth service
class AuthProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sends email verification to the current user
  /// Reloads user before sending to ensure fresh state
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Không tìm thấy người dùng');
    }

    await user.reload();
    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      throw Exception('Không tìm thấy người dùng sau khi reload');
    }

    if (refreshedUser.emailVerified) {
      throw Exception('Email đã được xác thực');
    }

    await refreshedUser.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
