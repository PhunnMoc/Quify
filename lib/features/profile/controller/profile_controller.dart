import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final isEditing = false.obs;
  final isCheckingUsername = false.obs;

  Map<String, dynamic>? userData;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userData = await _authRepository.getUserData(user.uid);
        if (userData != null) {
          fullNameController.text = userData!['fullName'] ?? '';
          usernameController.text = userData!['username'] ?? '';
          emailController.text = userData!['email'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải thông tin người dùng',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset to original values
      _loadUserData();
    }
  }

  Future<void> checkUsername(String username) async {
    if (username.length < 3) return;

    // Don't check if it's the current username
    if (username == userData?['username']) return;

    isCheckingUsername.value = true;
    try {
      final exists = await _authRepository.usernameExists(username);
      if (exists) {
        // Show error in controller or return validation error
      }
    } catch (e) {
      // Handle error
    } finally {
      isCheckingUsername.value = false;
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final fullName = fullNameController.text.trim();
      final username = usernameController.text.trim();

      // Validate
      if (fullName.isEmpty) {
        throw Exception('Vui lòng nhập họ và tên');
      }
      if (username.isEmpty) {
        throw Exception('Vui lòng nhập tên đăng nhập');
      }

      // Check username if changed
      if (username != userData?['username']) {
        final exists = await _authRepository.usernameExists(username);
        if (exists) {
          throw Exception('Tên đăng nhập đã tồn tại');
        }
      }

      // Update profile
      await _authRepository.updateProfile(
        uid: user.uid,
        fullName: fullName,
        username: username,
      );

      // Reload user data
      await _loadUserData();

      isEditing.value = false;

      // Show success message
      Get.snackbar(
        'Thành công',
        'Cập nhật hồ sơ thành công',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
