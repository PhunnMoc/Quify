import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/features/game/controller/game_controller.dart';

class LobbyView extends GetView<GameController> {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phòng chờ")),
      body: SafeArea(
        child: Column(
        children: [
          const SizedBox(height: 20),
          Obx(() => Text(
                "Mã PIN: ${controller.currentGame.value.pinCode}",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
          Obx(() => Text(
                "Đang có ${controller.players.length} người tham gia",
                style: const TextStyle(fontSize: 16),
              )),
          const Text("Đang chờ người chơi..."),
          const Divider(),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.players.length,
                  itemBuilder: (context, index) {
                    var player = controller.players[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          player.name.isNotEmpty
                              ? player.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(player.name),
                    );
                  },
                )),
          ),
          Obx(() {
            if (controller.isHost.value) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => controller.startGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text("Bắt đầu Game", style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Đang chờ chủ phòng bắt đầu..."),
            );
          }),
        ],
        ),
      ),
    );
  }
}
