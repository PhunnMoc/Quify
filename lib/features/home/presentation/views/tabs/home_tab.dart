import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final authRepository = AuthRepository();
  bool _hasShownWelcome = false;

  @override
  void initState() {
    super.initState();
    _showWelcomeMessage();
  }

  Future<void> _showWelcomeMessage() async {
    if (_hasShownWelcome) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await authRepository.getUserData(user.uid);
      if (userData != null && userData['username'] != null) {
        final username = userData['username'] as String;
        
        // Luôn hiển thị thông báo chào mừng
        Get.snackbar(
          'Chào mừng',
          'Chào mừng $username',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        _hasShownWelcome = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            AppStrings.home,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
