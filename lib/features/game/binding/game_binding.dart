import 'package:get/get.dart';
import 'package:quify/features/game/controller/game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GameController>(GameController());
  }
}

