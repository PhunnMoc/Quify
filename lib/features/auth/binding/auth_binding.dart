import 'package:get/get.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true, // Cho phép recreate controller nếu bị dispose
    );
  }
}
