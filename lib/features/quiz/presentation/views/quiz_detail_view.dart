import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/routes/app_routes.dart';

class QuizDetailView extends StatefulWidget {
  final String quizId;

  const QuizDetailView({super.key, required this.quizId});

  @override
  State<QuizDetailView> createState() => _QuizDetailViewState();
}

class _QuizDetailViewState extends State<QuizDetailView> {
  late Future<QuizModel?> _quizFuture;
  final QuizController _quizController = Get.put(QuizController(), tag: 'quiz');
  final CategoryProvider _categoryProvider = CategoryProvider();
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryProvider.getAllCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
    }
  }

  List<String> _getCategoryNames(QuizModel quiz) {
    if (_loadingCategories || _categories.isEmpty) {
      return [];
    }
    final categoryMap = {
      for (var cat in _categories) cat['id'] as String: cat['name'] as String
    };
    return quiz.categoryIds
        .map((id) => categoryMap[id] ?? id)
        .where((name) => name.isNotEmpty)
        .toList();
  }

  void _loadQuiz() {
    setState(() {
      _quizFuture = _quizController.getQuizById(widget.quizId).then((quiz) async {
        if (quiz != null) {
          await _quizController.loadQuestions(widget.quizId);
        }
        return quiz;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Quiz'),
        actions: [
          if (user != null)
            FutureBuilder<QuizModel?>(
              future: _quizController.getQuizById(widget.quizId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.ownerId == user.uid) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Get.toNamed(AppRoutes.editQuiz, arguments: widget.quizId);
                      if (result == true || result == null) {
                        _loadQuiz();
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: FutureBuilder<QuizModel?>(
        future: _quizFuture,
        builder: (context, quizSnapshot) {
          if (!quizSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quiz = quizSnapshot.data!;
          final categoryNames = _getCategoryNames(quiz);

          return Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quiz.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  quiz.isPublic ? Icons.public : Icons.lock,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimens.marginS),
                            Text(
                              quiz.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (categoryNames.isNotEmpty) ...[
                              const SizedBox(height: AppDimens.marginXS),
                              Wrap(
                                spacing: AppDimens.marginXS,
                                runSpacing: AppDimens.marginXS,
                                children: categoryNames.map((name) {
                                  return Chip(
                                    label: Text(name),
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    avatar: Icon(
                                      Icons.label_outline,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: AppDimens.marginS),
                            Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.help_outline,
                                  label: '${quiz.totalQuestions} câu hỏi',
                                ),
                                const SizedBox(width: AppDimens.marginS),
                                _InfoChip(
                                  icon: Icons.play_circle_outline,
                                  label: '${quiz.totalPlays} lượt chơi',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.marginL),
                    const Text(
                      'Danh sách câu hỏi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.marginM),
                    if (_quizController.questions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.paddingXL),
                          child: Text(
                            'Chưa có câu hỏi nào',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._quizController.questions.map((question) =>
                          _QuestionCard(question: question, quizId: widget.quizId)),
                  ],
                ),
              ));
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final String quizId;

  const _QuestionCard({required this.question, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.marginM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Câu ${question.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(question.type == 'SINGLE' ? 'Đơn đáp án' : 'Đa đáp án'),
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.marginS),
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimens.marginS),
            ...question.options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.marginXS),
                  child: Row(
                    children: [
                      Icon(
                        option.isCorrect ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: option.isCorrect
                            ? AppTheme.successColor
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppDimens.marginXS),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            color: option.isCorrect
                                ? AppTheme.successColor
                                : AppTheme.textPrimary,
                            fontWeight:
                                option.isCorrect ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppDimens.marginS),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: AppDimens.marginXS),
                Text(
                  '${question.timeLimit}s',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppDimens.marginM),
                Icon(Icons.star_outline,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: AppDimens.marginXS),
                Text(
                  '${question.points} điểm',
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
    );
  }
}

