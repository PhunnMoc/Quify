import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes - chỉ navigate khi cần thiết
    _authRepository.authStateChanges.listen((User? user) {
      final currentRoute = Get.currentRoute;
      if (user != null) {
        // Chỉ navigate nếu chưa ở trang home
        if (currentRoute != AppRoutes.home) {
          Get.offAllNamed(AppRoutes.home);
        }
      }
      // Không tự động navigate về login khi user == null
      // Để tránh vòng lặp rebuild
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      Get.snackbar(
        'Thành công',
        'Đăng nhập thành công',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không đúng';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      Get.snackbar(
        'Lỗi',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đăng nhập thất bại: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      isLoading.value = true;
      await _authRepository.register(
        emailController.text.trim(),
        passwordController.text,
      );
      Get.snackbar(
        'Thành công',
        'Đăng ký thành công',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      Get.snackbar(
        'Lỗi',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đăng ký thất bại: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }
}

