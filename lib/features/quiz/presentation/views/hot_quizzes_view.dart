import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/quiz/controller/public_quiz_controller.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/routes/app_routes.dart';

class HotQuizzesView extends StatefulWidget {
  const HotQuizzesView({super.key});

  @override
  State<HotQuizzesView> createState() => _HotQuizzesViewState();
}

class _HotQuizzesViewState extends State<HotQuizzesView> {
  final PublicQuizController controller = Get.find<PublicQuizController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.loadAllHotQuizzes(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadAllHotQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Hot Nhất'),
      ),
      body: Obx(() {
        if (controller.isLoadingAllHot.value && controller.allHotQuizzes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadAllHotQuizzes(refresh: true);
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimens.paddingM),
            itemCount: controller.allHotQuizzes.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: AppDimens.marginM),
            itemBuilder: (context, index) {
              if (index == controller.allHotQuizzes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimens.paddingM),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final quiz = controller.allHotQuizzes[index];
              return _HotQuizListItem(quiz: quiz, controller: controller);
            },
          ),
        );
      }),
    );
  }
}

class _HotQuizListItem extends StatelessWidget {
  final QuizModel quiz;
  final PublicQuizController controller;

  const _HotQuizListItem({required this.quiz, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.quizDetail, arguments: quiz.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingM),
          child: Row(
            children: [
              // Icon or Image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppDimens.marginM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      'Tác giả: ${controller.getAuthorName(quiz.ownerId)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline, 
                          size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.totalPlays} lượt chơi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.help_outline, 
                          size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.totalQuestions} câu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

