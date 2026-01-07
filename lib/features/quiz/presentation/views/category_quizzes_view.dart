import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/admin/data/models/category_model.dart';
import 'package:quify/features/quiz/controller/public_quiz_controller.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/routes/app_routes.dart';

class CategoryQuizzesView extends StatefulWidget {
  final CategoryModel category;

  const CategoryQuizzesView({required this.category, super.key});

  @override
  State<CategoryQuizzesView> createState() => _CategoryQuizzesViewState();
}

class _CategoryQuizzesViewState extends State<CategoryQuizzesView> {
  final ScrollController _scrollController = ScrollController();
  final PublicQuizController _controller = Get.find<PublicQuizController>();

  @override
  void initState() {
    super.initState();
    _controller.loadCategoryQuizzes(widget.category.id, refresh: true);
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
      _controller.loadCategoryQuizzes(widget.category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.loadCategoryQuizzes(widget.category.id, refresh: true);
        },
        child: Obx(() {
          if (_controller.isLoadingCategoryQuizzes.value &&
              _controller.categoryQuizzes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.categoryQuizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có quiz nào trong danh mục này',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimens.paddingM),
            itemCount: _controller.categoryQuizzes.length +
                (_controller.hasMoreCategoryQuizzes.value ? 1 : 0),
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimens.marginS),
            itemBuilder: (context, index) {
              if (index == _controller.categoryQuizzes.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final quiz = _controller.categoryQuizzes[index];
              return _QuizListItem(quiz: quiz, controller: _controller);
            },
          );
        }),
      ),
    );
  }
}

class _QuizListItem extends StatelessWidget {
  final QuizModel quiz;
  final PublicQuizController controller;

  const _QuizListItem({required this.quiz, required this.controller});

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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz, color: AppTheme.primaryColor, size: 30),
              ),
              const SizedBox(width: AppDimens.marginM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                          '${quiz.totalQuestions} câu hỏi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'Tác giả: ${controller.getAuthorName(quiz.ownerId)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        )),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

