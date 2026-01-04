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
  final canResendEmail = true.obs;
  final resendCountdown = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Không tự động navigate từ auth state changes
    // Chỉ navigate khi user đăng nhập thành công trong hàm login()
  }

  @override
  void onClose() {
    // Không dispose controllers vì chúng vẫn được dùng ở các màn hình khác
    // Controllers sẽ được dispose khi app đóng hoàn toàn
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
      final credential = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (credential?.user != null) {
        await _authRepository.reloadUser();
        final user = credential!.user!;

        // Check email verification first
        if (!user.emailVerified) {
          Get.snackbar(
            'Thông báo',
            'Vui lòng xác thực email trước khi đăng nhập',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          // Initialize countdown will be done in EmailVerificationView
          Get.offAllNamed(AppRoutes.emailVerification);
          return;
        }

        // Check profile setup (only if email is verified)
        if (user.uid.isEmpty) {
          Get.snackbar(
            'Lỗi',
            'Không tìm thấy thông tin người dùng',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        final userData = await _authRepository.getUserData(user.uid);
        if (userData == null || userData['isSetupProfile'] != true) {
          Get.offAllNamed(AppRoutes.setupProfile);
          return;
        }

        // User is ready, go to home
        Get.snackbar(
          'Thành công',
          'Đăng nhập thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không đúng';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      } else if (e.code == 'invalid-credential') {
        message = 'Email/Username hoặc mật khẩu không đúng';
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
      final credential = await _authRepository.register(
        emailController.text.trim(),
        passwordController.text,
      );

      if (credential?.user != null) {
        // Create user document in Firestore
        await _authRepository.createUser(
          credential!.user!.uid,
          credential.user!.email!,
        );

        // Reload user first to ensure user object is fresh
        await _authRepository.reloadUser();

        // Send email verification
        try {
          await _authRepository.sendEmailVerification();
        } catch (e) {
          // Error sending email, but don't block registration flow
          // User can resend email from verification screen
        }

        Get.snackbar(
          'Thành công',
          'Đăng ký thành công. Vui lòng xác thực email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Initialize countdown will be done in EmailVerificationView
        Get.offAllNamed(AppRoutes.emailVerification);
      }
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

  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;

      // Check if user exists
      final user = getCurrentUser();
      if (user == null) {
        throw Exception('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      }

      await _authRepository.sendEmailVerification();

      // Start countdown
      canResendEmail.value = false;
      resendCountdown.value = 20;

      // Start countdown timer
      _startCountdownTimer();

      Get.snackbar(
        'Thành công',
        'Email xác thực đã được gửi đến ${user.email}. Vui lòng kiểm tra hộp thư (bao gồm thư mục Spam).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      String errorMessage = 'Không thể gửi email xác thực';

      if (e.toString().contains('email-already-verified')) {
        errorMessage = 'Email đã được xác thực rồi';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Vui lòng đợi một chút trước khi gửi lại';
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }

      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Re-enable button on error
      canResendEmail.value = true;
      resendCountdown.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  void _startCountdownTimer() {
    // Cancel any existing timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      } else {
        canResendEmail.value = true;
        return false;
      }
    });
  }

  // Khởi tạo countdown khi vào màn hình email verification
  void initializeEmailVerificationCountdown() {
    canResendEmail.value = false;
    resendCountdown.value = 20;
    _startCountdownTimer();
  }

  Future<void> checkEmailVerification() async {
    try {
      isLoading.value = true;
      final isVerified = await _authRepository.isEmailVerified();
      if (isVerified) {
        final user = _authRepository.getCurrentUser();
        if (user != null) {
          if (user.uid.isEmpty) {
            Get.snackbar(
              'Lỗi',
              'Không tìm thấy thông tin người dùng',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
          // Check if user has setup profile
          final userData = await _authRepository.getUserData(user.uid);
          if (userData == null || userData['isSetupProfile'] != true) {
            Get.offAllNamed(AppRoutes.setupProfile);
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        }
      } else {
        Get.snackbar(
          'Thông báo',
          'Email chưa được xác thực. Vui lòng kiểm tra hộp thư.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: ${e.toString()}',
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

  Future<bool> usernameExists(String username) async {
    return await _authRepository.usernameExists(username);
  }

  Future<void> setupProfile({
    required String fullName,
    required String username,
  }) async {
    try {
      isLoading.value = true;
      final user = getCurrentUser();
      if (user == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      await _authRepository.setupProfile(
        uid: user.uid,
        email: user.email!,
        fullName: fullName,
        username: username,
      );
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  User? getCurrentUser() {
    return _authRepository.getCurrentUser();
  }
}
