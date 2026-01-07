import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/quiz/controller/public_quiz_controller.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/routes/app_routes.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final controller = Get.put(PublicQuizController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm quiz...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() {
                    if (controller.isSearching.value) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (controller.searchController.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchQuizzes('');
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

            // Content
            Expanded(
              child: Obx(() {
                // Showing search results if query is not empty
                if (controller.searchController.text.trim().isNotEmpty) {
                  return _buildSearchResults(controller);
                }
                
                // Show Hot Quizzes
                return _buildHotQuizzesSection(controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(PublicQuizController controller) {
    if (controller.isSearching.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả nào',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.paddingM),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.marginM),
      itemBuilder: (context, index) {
        final quiz = controller.searchResults[index];
        return _SearchResultItem(quiz: quiz, controller: controller);
      },
    );
  }

  Widget _buildHotQuizzesSection(PublicQuizController controller) {
    if (controller.isLoadingHot.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hotQuizzes.isEmpty) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadHotQuizzes();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
        children: [
          // Hot Quizzes Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quiz Hot Nhất',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.hotQuizzes);
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimens.marginS),

          // Hot Quizzes Horizontal List
          SizedBox(
            height: 200, // Fixed height for cards
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
              scrollDirection: Axis.horizontal,
              itemCount: controller.hotQuizzes.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppDimens.marginM),
              itemBuilder: (context, index) {
                final quiz = controller.hotQuizzes[index];
                return _HotQuizCard(quiz: quiz, controller: controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HotQuizCard extends StatelessWidget {
  final QuizModel quiz;
  final PublicQuizController controller;

  const _HotQuizCard({required this.quiz, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.quizDetail, arguments: quiz.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon placeholder
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline, 
                          size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.totalPlays}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.getAuthorName(quiz.ownerId),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final QuizModel quiz;
  final PublicQuizController controller;

  const _SearchResultItem({required this.quiz, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.quizDetail, arguments: quiz.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingM),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, color: AppTheme.primaryColor),
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
                      maxLines: 1,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
