import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/routes/app_routes.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepository = AuthRepository();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Email
              Text(
                user?.email ?? 'No email',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              // Logout Button
              CustomButton(
                text: 'Đăng xuất',
                onPressed: () async {
                  await authRepository.logout();
                  Get.offAllNamed(AppRoutes.login);
                },
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
