import 'package:get/get.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  
  // Trigger to reload user data
  final shouldReloadUserData = false.obs;

  void changeTab(int index) {
    // Reload user data when switching to Home tab
    if (index == 0) {
      shouldReloadUserData.value = true;
      // Reset after a short delay to allow Obx to fire
      Future.delayed(const Duration(milliseconds: 100), () {
        shouldReloadUserData.value = false;
      });
    }

    // Exit multi-select mode if switching away from library tab (index 2)
    if (currentIndex.value == 2 && index != 2) {
      try {
        final quizController = Get.find<QuizController>(tag: 'quiz');
        if (quizController.isMultiSelectionMode.value) {
          quizController.exitSelectionMode();
        }
      } catch (e) {
        // Controller might not be initialized, ignore error
      }
    }
    currentIndex.value = index;
  }
}
