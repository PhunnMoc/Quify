import 'package:get/get.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';

/// Binding for Quiz feature dependency injection
class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<QuizController>(QuizController(), tag: 'quiz', permanent: false);
  }
}

