import 'package:get/get.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

/// Initial dependency injection binding
/// Registers global controllers that persist across route changes
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
