import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/auth/controller/auth_controller.dart';
import 'package:quify/features/game/controller/game_controller.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/routes/app_routes.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quizController = Get.put(QuizController(), tag: 'quiz');
    final user = FirebaseAuth.instance.currentUser;
    final authController = Get.find<AuthController>();

    // Kiểm tra nếu đăng nhập admin
    if (authController.isAdminLoggedIn()) {
      // Admin có thể xem tất cả quizzes hoặc không load gì
      // Tạm thời hiển thị thông báo
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.library),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined,
                    size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: AppDimens.marginM),
                Text(
                  'Chế độ admin',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.marginS),
                Text(
                  'Vui lòng đăng nhập bằng tài khoản thường để xem quiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Vui lòng đăng nhập',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    quizController.loadUserQuizzes();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.library),
      ),
      body: SafeArea(
        child: Obx(() {
          if (quizController.quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: AppDimens.marginM),
                  Text(
                    'Chưa có quiz nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.marginS),
                  Text(
                    'Tạo quiz mới để bắt đầu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            itemCount: quizController.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizController.quizzes[index];
              return _QuizCard(quiz: quiz);
            },
          );
        }),
      ),
    );
  }
}

class _QuizCard extends StatefulWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  final CategoryProvider _categoryProvider = CategoryProvider();
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
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

  List<String> _getCategoryNames() {
    if (_loadingCategories || _categories.isEmpty) {
      return [];
    }
    final categoryMap = {
      for (var cat in _categories) cat['id'] as String: cat['name'] as String
    };
    return widget.quiz.categoryIds
        .map((id) => categoryMap[id] ?? id)
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = _getCategoryNames();

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.marginM),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.quizDetail, arguments: widget.quiz.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingM,
            AppDimens.paddingM,
            AppDimens.paddingM,
            AppDimens.paddingS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    widget.quiz.isPublic ? Icons.public : Icons.lock,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.marginS),
              Text(
                widget.quiz.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (categoryNames.isNotEmpty) ...[
                const SizedBox(height: AppDimens.marginS),
                Wrap(
                  spacing: AppDimens.marginXS,
                  runSpacing: AppDimens.marginXS,
                  children: categoryNames.map((name) {
                    return Chip(
                      label: Text(
                        name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppDimens.marginS),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline,
                      size: AppDimens.iconS, color: AppTheme.textSecondary),
                  const SizedBox(width: AppDimens.marginXS),
                  Text(
                    '${widget.quiz.totalQuestions} câu hỏi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.marginL),
                  Icon(Icons.play_circle_outline,
                      size: AppDimens.iconS, color: AppTheme.textSecondary),
                  const SizedBox(width: AppDimens.marginXS),
                  Text(
                    '${widget.quiz.totalPlays} lượt chơi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryColor),
                    iconSize: AppDimens.iconL,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Tổ chức Game',
                    onPressed: () {
                      final gameController = Get.put(GameController());
                      gameController.createGame(widget.quiz);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
