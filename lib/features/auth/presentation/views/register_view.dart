import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<AuthController>();
      controller.clearControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
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
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                CustomInputField(
                  label: AppStrings.email,
                  controller: Get.find<AuthController>().emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppDimens.marginM),
                // Password Field
                Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomInputField(
                    label: AppStrings.password,
                    controller: authController.passwordController,
                    validator: Validators.password,
                    obscureText: !authController.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: authController.togglePasswordVisibility,
                    ),
                  );
                }),
                const SizedBox(height: AppDimens.marginM),
                // Confirm Password Field
                Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomInputField(
                    label: AppStrings.confirmPassword,
                    controller: authController.confirmPasswordController,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      authController.passwordController.text,
                    ),
                    obscureText: !authController.isConfirmPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: authController.toggleConfirmPasswordVisibility,
                    ),
                  );
                }),
                const SizedBox(height: AppDimens.marginL),
                // Register Button
                Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomButton(
                    text: AppStrings.register,
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              authController.register();
                            }
                          },
                    isLoading: authController.isLoading.value,
                  );
                }),
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
                      onPressed: () {
                        Get.find<AuthController>().navigateToLogin();
                      },
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
