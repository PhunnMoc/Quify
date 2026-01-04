import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/admin/controller/admin_controller.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/routes/app_routes.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final authRepository = AuthRepository();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  AdminController? _adminController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Khởi tạo AdminController nếu đang đăng nhập admin
    if (Get.find<AuthController>().isAdminLoggedIn()) {
      _adminController = Get.put(AdminController(), tag: 'admin');
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await authRepository.getUserData(user.uid);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = userData?['fullName'] ?? 'Người dùng';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.account),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.paddingM),
                child: Column(
                  children: [
                    // Profile Summary Card
                    Card(
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.editProfile)?.then((_) {
                            // Reload data when returning from edit profile
                            if (mounted) {
                              _loadUserData();
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.paddingM),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  fullName.isNotEmpty
                                      ? fullName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimens.marginM),
                              // Name and Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          AppStrings.seePersonalInfo,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.marginL),
                    // General Section
                    _buildSectionHeader(AppStrings.general),
                    const SizedBox(height: AppDimens.marginS),
                    _buildMenuItem(
                      icon: Icons.payment_outlined,
                      title: AppStrings.paymentMethods,
                      onTap: () {
                        // TODO: Navigate to payment methods
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.reviews_outlined,
                      title: AppStrings.reviews,
                      onTap: () {
                        // TODO: Navigate to reviews
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications,
                      onTap: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                    const SizedBox(height: AppDimens.marginL),
                    // Others Section
                    _buildSectionHeader(AppStrings.others),
                    const SizedBox(height: AppDimens.marginS),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: AppStrings.settings,
                      onTap: () {
                        // TODO: Navigate to settings
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: AppStrings.helpCenter,
                      onTap: () {
                        // TODO: Navigate to help center
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.thumb_up_outlined,
                      title: AppStrings.rateOurApp,
                      onTap: () {
                        // TODO: Navigate to rate app
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: AppStrings.termsOfService,
                      onTap: () {
                        // TODO: Navigate to terms
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.privacyPolicy,
                      onTap: () {
                        // TODO: Navigate to privacy policy
                      },
                    ),
                    // Tạo data - chỉ hiển thị cho admin
                    if (Get.find<AuthController>().isAdminLoggedIn())
                      Obx(() {
                        final adminController = _adminController ??
                            Get.find<AdminController>(tag: 'admin');
                        return _buildMenuItem(
                          icon: Icons.add_circle_outline,
                          title: 'Tạo data',
                          onTap: adminController.isLoading.value
                              ? null
                              : () {
                                  adminController.createDefaultCategories();
                                },
                          isLoading: adminController.isLoading.value,
                        );
                      }),
                    const SizedBox(height: AppDimens.marginL),
                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingM,
                      ),
                      child: OutlinedButton(
                        onPressed: () async {
                          final authController = Get.find<AuthController>();
                          // Clear trạng thái admin nếu có
                          authController.clearAdminLogin();
                          await authRepository.logout();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                        child: const Text(AppStrings.logout),
                      ),
                    ),
                    const SizedBox(height: AppDimens.marginM),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.marginS),
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: isLoading
            ? const SizedBox.shrink()
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isLoading ? null : onTap,
        enabled: !isLoading,
      ),
    );
  }
}
