import 'package:get/get.dart';
import 'package:quify/features/auth/binding/auth_binding.dart';
import 'package:quify/features/auth/presentation/views/email_verification_view.dart';
import 'package:quify/features/auth/presentation/views/login_view.dart';
import 'package:quify/features/auth/presentation/views/register_view.dart';
import 'package:quify/features/auth/presentation/views/setup_profile_view.dart';
import 'package:quify/features/home/binding/home_binding.dart';
import 'package:quify/features/home/presentation/views/home_view.dart';
import 'package:quify/features/profile/binding/profile_binding.dart';
import 'package:quify/features/profile/presentation/views/edit_profile_view.dart';
import 'package:quify/routes/app_routes.dart';

/// Application route configuration
/// Maps route names to their corresponding views and bindings
class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => EmailVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.setupProfile,
      page: () => SetupProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
