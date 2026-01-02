import 'package:get/get.dart';
import 'package:quify/features/auth/binding/auth_binding.dart';
import 'package:quify/features/auth/presentation/views/login_view.dart';
import 'package:quify/features/auth/presentation/views/register_view.dart';
import 'package:quify/features/home/binding/home_binding.dart';
import 'package:quify/features/home/presentation/views/home_view.dart';
import 'package:quify/routes/app_routes.dart';

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
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}

