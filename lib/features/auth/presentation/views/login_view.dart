import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  LoginView({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo/Title
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Học tập vui vẻ, hiệu quả hơn!',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // Email/Username Field
                CustomInputField(
                  label: 'Email hoặc ${AppStrings.username}',
                  controller: controller.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email hoặc tên đăng nhập';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person_outlined),
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
                const SizedBox(height: AppDimens.marginS),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppDimens.marginL),
                // Login Button
                Obx(
                  () => CustomButton(
                    text: AppStrings.login,
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.login();
                            }
                          },
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: controller.navigateToRegister,
                      child: const Text(AppStrings.register),
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
