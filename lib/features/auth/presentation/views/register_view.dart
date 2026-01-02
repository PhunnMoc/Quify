import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Title
                Text(
                  'Tạo tài khoản mới',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tham gia Quify và bắt đầu học tập vui vẻ!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                CustomInputField(
                  label: AppStrings.email,
                  controller: controller.emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Password Field
                Obx(
                  () => CustomInputField(
                    label: AppStrings.password,
                    controller: controller.passwordController,
                    validator: Validators.password,
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Confirm Password Field
                Obx(
                  () => CustomInputField(
                    label: AppStrings.confirmPassword,
                    controller: controller.confirmPasswordController,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      controller.passwordController.text,
                    ),
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.marginL),
                // Register Button
                Obx(
                  () => CustomButton(
                    text: AppStrings.register,
                    onPressed: controller.isLoading.value ? null : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        controller.register();
                      }
                    },
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: controller.navigateToLogin,
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

