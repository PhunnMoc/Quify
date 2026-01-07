import 'package:get/get.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
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
