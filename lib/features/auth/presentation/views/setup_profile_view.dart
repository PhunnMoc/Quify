import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/routes/app_routes.dart';

class SetupProfileView extends GetView<AuthController> {
  SetupProfileView({super.key});
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final isCheckingUsername = false.obs;
  final authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.setupProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Title
                Text(
                  'Thiết lập hồ sơ của bạn',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoàn tất thông tin để bắt đầu sử dụng Quify',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Full Name Field
                CustomInputField(
                  label: AppStrings.fullName,
                  controller: fullNameController,
                  validator: Validators.fullName,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Username Field
                Obx(
                  () => CustomInputField(
                    label: AppStrings.username,
                    controller: usernameController,
                    validator: Validators.username,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.alternate_email),
                    suffixIcon: isCheckingUsername.value
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    onChanged: (value) {
                      // Check username availability
                      if (value.length >= 3) {
                        _checkUsername(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.marginL),
                // Submit Button
                Obx(
                  () => CustomButton(
                    text: 'Hoàn tất',
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _setupProfile();
                            }
                          },
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkUsername(String username) async {
    isCheckingUsername.value = true;
    try {
      final exists = await authRepository.usernameExists(username);
      if (exists && _formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    } catch (e) {
      // Handle error
    } finally {
      isCheckingUsername.value = false;
    }
  }

  Future<void> _setupProfile() async {
    try {
      final user = controller.getCurrentUser();
      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy thông tin người dùng',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check username availability
      final usernameExists = await authRepository.usernameExists(
        usernameController.text.trim(),
      );
      if (usernameExists) {
        Get.snackbar(
          'Lỗi',
          AppStrings.usernameExists,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Setup profile (controller sẽ handle loading state)
      await controller.setupProfile(
        fullName: fullNameController.text.trim(),
        username: usernameController.text.trim(),
      );

      // Welcome message will be shown in HomeTab

      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Thiết lập hồ sơ thất bại: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

