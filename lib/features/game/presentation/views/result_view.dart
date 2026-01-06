import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/features/game/controller/game_controller.dart';
import 'package:quify/routes/app_routes.dart';

class ResultView extends GetView<GameController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kết quả trận đấu"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "BẢNG XẾP HẠNG",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.players.length,
                  itemBuilder: (context, index) {
                    var p = controller.players[index];
                    // Highlight top 3
                    Color? bgColor;
                    if (index == 0) bgColor = Colors.amber[100];
                    if (index == 1) bgColor = Colors.grey[200];
                    if (index == 2) bgColor = Colors.brown[100];

                    return Container(
                      color: bgColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          "${p.score} điểm",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Obx(() {
              if (controller.isHost.value) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => controller.closeAndArchiveGame(),
                    child: const Text(
                      "Đóng phòng & Lưu lịch sử",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text(
                      "Về trang chủ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
