import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    final controller = Get.find<AuthController>();
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
                  controller: Get.find<AuthController>().emailController,
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
                Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomButton(
                    text: AppStrings.login,
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              authController.login();
                            }
                          },
                    isLoading: authController.isLoading.value,
                  );
                }),
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
                      onPressed: () {
                        Get.find<AuthController>().navigateToRegister();
                      },
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
