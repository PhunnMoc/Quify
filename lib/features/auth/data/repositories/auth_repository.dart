import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/features/auth/data/providers/auth_provider.dart' as auth_provider;

class AuthRepository {
  final auth_provider.AuthProvider _authProvider = auth_provider.AuthProvider();

  Future<UserCredential?> login(String email, String password) async {
    try {
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
}

