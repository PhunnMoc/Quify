import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';

/// Reusable widget for quiz form fields (title, description, cover image, public/private, categories)
/// Used in both CreateQuizView and EditQuizView to avoid code duplication
class QuizFormFields extends StatefulWidget {
  final QuizController quizController;
  final CategoryProvider categoryProvider;

  const QuizFormFields({
    super.key,
    required this.quizController,
    required this.categoryProvider,
  });

  @override
  State<QuizFormFields> createState() => _QuizFormFieldsState();
}

class _QuizFormFieldsState extends State<QuizFormFields> {
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.categoryProvider.getAllCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });

      if (categories.isEmpty && mounted) {
        Get.snackbar(
          'Thông báo',
          'Chưa có phân loại nào. Vui lòng tạo phân loại từ menu admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() {
        _loadingCategories = false;
      });
      if (mounted) {
        Get.snackbar(
          'Lỗi',
          'Không thể tải danh sách phân loại: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomInputField(
          label: 'Tiêu đề Quiz *',
          controller: widget.quizController.titleController,
          validator: Validators.quizTitle,
          prefixIcon: const Icon(Icons.title),
        ),
        const SizedBox(height: AppDimens.marginM),
        CustomInputField(
          label: 'Mô tả (tùy chọn)',
          controller: widget.quizController.descriptionController,
          validator: Validators.quizDescription,
          maxLines: 4,
          prefixIcon: const Icon(Icons.description),
        ),
        const SizedBox(height: AppDimens.marginM),
        CustomInputField(
          label: 'Link ảnh bìa (tùy chọn)',
          controller: widget.quizController.coverImageUrlController,
          keyboardType: TextInputType.url,
          prefixIcon: const Icon(Icons.image),
        ),
        const SizedBox(height: AppDimens.marginM),
        Obx(
          () => Card(
            child: SwitchListTile(
              title: const Text('Công khai'),
              subtitle: const Text(
                'Cho phép người khác tìm thấy quiz này',
              ),
              value: widget.quizController.isPublic.value,
              onChanged: (value) {
                widget.quizController.isPublic.value = value;
              },
              secondary: Icon(
                widget.quizController.isPublic.value
                    ? Icons.public
                    : Icons.lock,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.marginM),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: AppDimens.marginS),
                    const Text(
                      'Phân loại *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => Text(
                        '${widget.quizController.selectedCategories.length}/3',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.marginS),
                if (_loadingCategories)
                  const Center(child: CircularProgressIndicator())
                else if (_categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Không có phân loại nào.'),
                  )
                else
                  Obx(() {
                    final selectedList =
                        widget.quizController.selectedCategories.toList();

                    return Wrap(
                      spacing: AppDimens.marginS,
                      runSpacing: AppDimens.marginS,
                      children: _categories.map((category) {
                        final categoryId = category['id'] as String;
                        final categoryName = category['name'] as String;
                        final isSelected = selectedList.contains(categoryId);
                        return FilterChip(
                          label: Text(categoryName),
                          selected: isSelected,
                          onSelected: (selected) {
                            final currentList = List<String>.from(
                              widget.quizController.selectedCategories,
                            );
                            if (selected) {
                              if (currentList.length < 3) {
                                currentList.add(categoryId);
                                widget.quizController.selectedCategories.value =
                                    currentList;
                              } else {
                                Get.snackbar(
                                  'Thông báo',
                                  'Chỉ được chọn tối đa 3 phân loại',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              currentList.remove(categoryId);
                              widget.quizController.selectedCategories.value =
                                  currentList;
                            }
                          },
                          selectedColor:
                              AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        );
                      }).toList(),
                    );
                  }),
                const SizedBox(height: AppDimens.marginS),
                Text(
                  'Chọn từ 1 đến 3 phân loại',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

