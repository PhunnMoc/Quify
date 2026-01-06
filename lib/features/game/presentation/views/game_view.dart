import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/features/game/controller/game_controller.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("Câu hỏi ${controller.currentGame.value.currentQuestionIndex + 1}")),
        actions: [
          Obx(() => Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "${controller.timeLeft.value}s",
                    style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: SafeArea(
        child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.questions.isEmpty) {
          return const Center(child: Text("Không tải được câu hỏi."));
        }

        int currentIndex = controller.currentGame.value.currentQuestionIndex;
        if (currentIndex >= controller.questions.length) {
          return const Center(child: Text("Kết thúc game hoặc lỗi trạng thái"));
        }

        QuestionModel currentQuestion = controller.questions[currentIndex];
        bool isLastQuestion = currentIndex + 1 >= controller.questions.length;

        return Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentQuestion.text,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.network(
                  currentQuestion.imageUrl!,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  // Pastel colors for options (same tone, darker)
                  final colors = [
                    const Color(0xFFFF6B7A), // Pastel pink/red (darker)
                    const Color(0xFF6B9EFF), // Pastel blue (darker)
                    const Color(0xFFFFA66B), // Pastel peach/orange (darker)
                    const Color(0xFF6BFFA6), // Pastel mint/green (darker)
                  ];
                  final color = colors[index % colors.length];

                  return Obx(() {
                    // 1. Get time up state - accessing .value ensures Obx rebuilds when it changes
                    bool timeUp = controller.isTimeUp.value;
                    
                    // 2. Determine if this option is selected
                    bool isSelected = false;
                    if (currentQuestion.type == 'SINGLE') {
                      isSelected = controller.selectedAnswerIndex.value == index;
                    } else if (currentQuestion.type == 'MULTIPLE') {
                      isSelected = controller.selectedAnswerIndices.contains(index);
                    }
                    
                    // 3. Determine border color and shadow based on state
                    Color? borderColor;
                    double? borderWidth;
                    List<BoxShadow>? boxShadows;
                    
                    if (timeUp) {
                      // --- WHEN TIME IS UP (SHOW RESULTS) ---
                      if (option.isCorrect) {
                        // Correct answer -> Always highlight in green
                        borderColor = Colors.green;
                        borderWidth = 4.0;
                        boxShadows = [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ];
                      } else if (isSelected && !option.isCorrect) {
                        // User selected wrong answer -> Highlight in red
                        borderColor = Colors.red;
                        borderWidth = 4.0;
                        boxShadows = [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ];
                      }
                      // Other options (not selected, not correct) -> No highlight
                    } else {
                      // --- WHEN PLAYING (TIME NOT UP) ---
                      if (isSelected) {
                        // Currently selected answer -> Highlight in white/yellow
                        borderColor = Colors.white;
                        borderWidth = 4.0;
                        boxShadows = [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ];
                      }
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        if (!controller.isHost.value && controller.timeLeft.value > 0) {
                          controller.selectAnswer(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: borderColor != null
                              ? Border.all(
                                  color: borderColor,
                                  width: borderWidth ?? 4,
                                )
                              : null,
                          boxShadow: boxShadows,
                        ),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                option.text,
                                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            // Host controls
            if (controller.isHost.value)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Kết thúc Game button - takes available space
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.finishGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Kết thúc Game",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    // Câu tiếp theo button - only show if time is up and not last question
                    if (controller.timeLeft.value == 0 && !isLastQuestion) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => controller.nextQuestion(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Câu tiếp theo >>",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        );
        }),
      ),
    );
  }
}
