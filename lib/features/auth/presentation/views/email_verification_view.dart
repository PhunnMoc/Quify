import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';
import 'package:quify/routes/app_routes.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo countdown khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<AuthController>();
      // Luôn khởi tạo countdown khi vào màn hình (nếu chưa chạy)
      if (controller.resendCountdown.value == 0) {
        controller.initializeEmailVerificationCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAllNamed(AppRoutes.login);
          },
        ),
        title: const Text(AppStrings.verifyEmail),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppDimens.marginL),
              // Title
              Text(
                AppStrings.pleaseVerifyEmail,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.marginM),
              // Description
              Text(
                email.isNotEmpty
                    ? 'Chúng tôi đã gửi email xác thực đến $email. Vui lòng kiểm tra hộp thư và nhấp vào liên kết xác thực.'
                    : 'Chúng tôi đã gửi email xác thực đến địa chỉ email của bạn. Vui lòng kiểm tra hộp thư và nhấp vào liên kết xác thực.',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.marginXL),
              // Resend Button with countdown
              Obx(() {
                final canResend = controller.canResendEmail.value;
                final countdown = controller.resendCountdown.value;

                return Column(
                  children: [
                    CustomButton(
                      text: countdown > 0
                          ? 'Gửi lại sau $countdown giây'
                          : 'Gửi lại email xác thực',
                      onPressed: (canResend && !controller.isLoading.value)
                          ? () {
                              controller.resendVerificationEmail();
                            }
                          : null,
                      isLoading: controller.isLoading.value,
                      backgroundColor: canResend
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ],
                );
              }),
              const SizedBox(height: AppDimens.marginM),
              // Check Verification Button
              Obx(
                () => CustomButton(
                  text: 'Đã xác thực, tiếp tục',
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.checkEmailVerification();
                        },
                  isLoading: controller.isLoading.value,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
