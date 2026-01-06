import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/home/controller/home_controller.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/presentation/widgets/quiz_form_fields.dart';

class CreateQuizView extends StatefulWidget {
  const CreateQuizView({super.key});

  @override
  State<CreateQuizView> createState() => _CreateQuizViewState();
}

class _CreateQuizViewState extends State<CreateQuizView> {
  final _formKey = GlobalKey<FormState>();
  final _questionFormKey = GlobalKey<FormState>();
  late final QuizController _quizController;
  final _categoryProvider = CategoryProvider();
  bool _showQuestionForm = false;
  List<QuestionModel> _tempQuestions = [];
  int? _editingQuestionIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<int, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
    _quizController = Get.put(QuizController(), tag: 'quiz');
    _quizController.clearForm();
  }

  void _showAddQuestionForm() {
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    _optionControllers.clear();

    setState(() {
      _showQuestionForm = true;
      _editingQuestionIndex = null;
      _quizController.clearQuestionForm();
      _quizController.addQuestionOption();
      _quizController.addQuestionOption();
      _quizController.addQuestionOption();
      _quizController.addQuestionOption();

      for (int i = 0; i < 4; i++) {
        _optionControllers[i] = TextEditingController();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showEditQuestionForm(int index) {
    if (index < 0 || index >= _tempQuestions.length) return;

    final question = _tempQuestions[index];
    setState(() {
      _showQuestionForm = true;
      _editingQuestionIndex = index; // Edit câu hỏi tại index này

      // Load dữ liệu câu hỏi vào form
      _quizController.questionTextController.text = question.text;
      _quizController.questionImageUrlController.text = question.imageUrl ?? '';
      _quizController.questionType.value = question.type;
      _quizController.timeLimitController.text = question.timeLimit.toString();
      _quizController.pointsController.text = question.points.toString();
      _quizController.questionOptions.value = question.options;
    });

    // Scroll đến form sau một chút để form render xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _hideQuestionForm() {
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    _optionControllers.clear();

    setState(() {
      _showQuestionForm = false;
      _editingQuestionIndex = null;
      _quizController.clearQuestionForm();
    });
  }

  void _saveQuestion() {
    if (!(_questionFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_quizController.questionTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập nội dung câu hỏi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_quizController.questionOptions.length < 2) {
      Get.snackbar(
        'Lỗi',
        'Phải có ít nhất 2 đáp án',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final emptyOptions = _quizController.questionOptions
        .where((opt) => opt.text.trim().isEmpty)
        .toList();
    if (emptyOptions.isNotEmpty) {
      Get.snackbar(
        'Lỗi',
        'Tất cả các đáp án không được để trống',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final hasCorrectAnswer = _quizController.questionOptions.any(
      (opt) => opt.isCorrect,
    );
    if (!hasCorrectAnswer) {
      Get.snackbar(
        'Lỗi',
        'Phải có ít nhất 1 đáp án đúng',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_quizController.questionType.value == 'SINGLE') {
      final correctCount = _quizController.questionOptions
          .where((opt) => opt.isCorrect)
          .length;
      if (correctCount != 1) {
        Get.snackbar(
          'Lỗi',
          'Câu hỏi đơn đáp án phải có đúng 1 đáp án đúng',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    final question = QuestionModel(
      id: _editingQuestionIndex != null
          ? _tempQuestions[_editingQuestionIndex!].id
          : 'temp_${_tempQuestions.length + 1}',
      text: _quizController.questionTextController.text.trim(),
      imageUrl: _quizController.questionImageUrlController.text.trim().isEmpty
          ? null
          : _quizController.questionImageUrlController.text.trim(),
      type: _quizController.questionType.value,
      timeLimit: int.tryParse(_quizController.timeLimitController.text) ?? 20,
      points: int.tryParse(_quizController.pointsController.text) ?? 100,
      order: _editingQuestionIndex != null
          ? _tempQuestions[_editingQuestionIndex!].order
          : _tempQuestions.length + 1,
      options: _quizController.questionOptions.toList(),
    );

    setState(() {
      if (_editingQuestionIndex != null) {
        _tempQuestions[_editingQuestionIndex!] = question;
      } else {
        _tempQuestions.add(question);
      }
      _hideQuestionForm();
    });

    final currentScrollPosition = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;

    Get.snackbar(
      'Thành công',
      _editingQuestionIndex != null
          ? 'Đã cập nhật câu hỏi'
          : 'Đã thêm câu hỏi vào danh sách',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScrollPosition);
      }
    });
  }

  void _removeTempQuestion(int index) {
    final currentScrollPosition = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;

    setState(() {
      _tempQuestions.removeAt(index);
      for (int i = 0; i < _tempQuestions.length; i++) {
        _tempQuestions[i] = _tempQuestions[i].copyWith(order: i + 1);
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScrollPosition);
      }
    });
  }

  Future<void> _createQuiz() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_quizController.selectedCategories.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn ít nhất 1 phân loại',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_quizController.selectedCategories.length > 3) {
      Get.snackbar(
        'Lỗi',
        'Chỉ được chọn tối đa 3 phân loại',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final quizId = await _quizController.createQuiz();
    if (quizId != null && mounted) {
      if (_tempQuestions.isNotEmpty) {
        try {
          for (var question in _tempQuestions) {
            _quizController.questionTextController.text = question.text;
            _quizController.questionImageUrlController.text =
                question.imageUrl ?? '';
            _quizController.questionType.value = question.type;
            _quizController.timeLimitController.text = question.timeLimit
                .toString();
            _quizController.pointsController.text = question.points.toString();
            _quizController.questionOptions.value = question.options;
            await _quizController.createQuestion(quizId);
          }
        } catch (e) {
          Get.snackbar(
            'Lỗi',
            'Không thể tạo một số câu hỏi: ${e.toString()}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      FocusManager.instance.primaryFocus?.unfocus();

      if (mounted) {
        Get.snackbar(
          'Thành công',
          'Đã tạo quiz thành công',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 2000),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              final homeController = Get.find<HomeController>();
              homeController.changeTab(2);
            } catch (e) {
              print('Không tìm thấy HomeController: $e');
            }
          });
        } else {
          print('Không thể pop màn hình!');
          Get.back();
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              final homeController = Get.find<HomeController>();
              homeController.changeTab(2);
            } catch (e) {
              print('Không tìm thấy HomeController: $e');
            }
          });
        }
      }
    } else if (quizId == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Quiz Mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizFormFields(
                quizController: _quizController,
                categoryProvider: _categoryProvider,
              ),
              const SizedBox(height: AppDimens.marginXL),

              // Questions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Câu hỏi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (!_showQuestionForm)
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppTheme.primaryColor,
                      onPressed: _showAddQuestionForm,
                    ),
                ],
              ),
              const SizedBox(height: AppDimens.marginM),

              if (_showQuestionForm)
                Card(
                  color: AppTheme.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingM),
                    child: Form(
                      key: _questionFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _editingQuestionIndex != null
                                    ? 'Sửa câu hỏi'
                                    : 'Thêm câu hỏi mới',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _hideQuestionForm,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          CustomInputField(
                            label: 'Nội dung câu hỏi *',
                            controller: _quizController.questionTextController,
                            validator: Validators.questionText,
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          CustomInputField(
                            label: 'Link ảnh (tùy chọn)',
                            controller:
                                _quizController.questionImageUrlController,
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  label: 'Thời gian (giây) *',
                                  controller:
                                      _quizController.timeLimitController,
                                  validator: Validators.timeLimit,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: AppDimens.marginM),
                              Expanded(
                                child: CustomInputField(
                                  label: 'Điểm số *',
                                  controller: _quizController.pointsController,
                                  validator: Validators.points,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          Obx(
                            () => SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'SINGLE',
                                  label: Text('Đơn đáp án'),
                                  icon: Icon(Icons.radio_button_checked),
                                ),
                                ButtonSegment(
                                  value: 'MULTIPLE',
                                  label: Text('Đa đáp án'),
                                  icon: Icon(Icons.check_box),
                                ),
                              ],
                              selected: {_quizController.questionType.value},
                              onSelectionChanged: (Set<String> newSelection) {
                                _quizController.questionType.value =
                                    newSelection.first;
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          const Text(
                            'Đáp án *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimens.marginS),
                          Obx(
                            () => Column(
                              children: [
                                ..._quizController.questionOptions.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final option = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.only(
                                      bottom: AppDimens.marginS,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppDimens.paddingS,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CustomInputField(
                                              label: 'Đáp án ${index + 1}',
                                              controller: _optionControllers
                                                  .putIfAbsent(
                                                    index,
                                                    () => TextEditingController(
                                                      text: option.text,
                                                    ),
                                                  ),
                                              validator: Validators.optionText,
                                              onChanged: (value) {
                                                _quizController
                                                        .questionOptions[index] =
                                                    option.copyWith(
                                                      text: value,
                                                    );
                                              },
                                            ),
                                          ),
                                          Obx(() {
                                            final isSingle =
                                                _quizController
                                                    .questionType
                                                    .value ==
                                                'SINGLE';
                                            if (isSingle) {
                                              final correctIndex =
                                                  _quizController
                                                      .questionOptions
                                                      .indexWhere(
                                                        (opt) => opt.isCorrect,
                                                      );
                                              return Radio<int>(
                                                value: index,
                                                groupValue: correctIndex >= 0
                                                    ? correctIndex
                                                    : null,
                                                onChanged: (selectedIndex) {
                                                  for (
                                                    int i = 0;
                                                    i <
                                                        _quizController
                                                            .questionOptions
                                                            .length;
                                                    i++
                                                  ) {
                                                    _quizController
                                                            .questionOptions[i] =
                                                        _quizController
                                                            .questionOptions[i]
                                                            .copyWith(
                                                              isCorrect:
                                                                  i ==
                                                                  selectedIndex,
                                                            );
                                                  }
                                                },
                                              );
                                            } else {
                                              return Checkbox(
                                                value: option.isCorrect,
                                                onChanged: (value) {
                                                  _quizController
                                                          .questionOptions[index] =
                                                      option.copyWith(
                                                        isCorrect:
                                                            value ?? false,
                                                      );
                                                },
                                              );
                                            }
                                          }),
                                          if (_quizController
                                                  .questionOptions
                                                  .length >
                                              2)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: AppTheme.errorColor,
                                              onPressed: () {
                                                _optionControllers[index]
                                                    ?.dispose();
                                                _optionControllers.remove(
                                                  index,
                                                );

                                                final keysToUpdate =
                                                    _optionControllers.keys
                                                        .where(
                                                          (key) => key > index,
                                                        )
                                                        .toList()
                                                      ..sort();

                                                for (var oldKey
                                                    in keysToUpdate) {
                                                  final controller =
                                                      _optionControllers.remove(
                                                        oldKey,
                                                      );
                                                  if (controller != null) {
                                                    _optionControllers[oldKey -
                                                            1] =
                                                        controller;
                                                  }
                                                }

                                                _quizController
                                                    .removeQuestionOption(
                                                      index,
                                                    );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                if (_quizController.questionOptions.length < 6)
                                  TextButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm đáp án'),
                                    onPressed: () {
                                      final newIndex = _quizController
                                          .questionOptions
                                          .length;
                                      _quizController.addQuestionOption();
                                      _optionControllers[newIndex] =
                                          TextEditingController();
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          CustomButton(
                            text: _editingQuestionIndex != null
                                ? 'Cập nhật câu hỏi'
                                : 'Thêm câu hỏi',
                            onPressed: _saveQuestion,
                            isLoading: _quizController.isLoading.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Questions List
              const SizedBox(height: AppDimens.marginM),
              if (_tempQuestions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingXL),
                    child: Text(
                      'Chưa có câu hỏi nào. Nhấn nút + để thêm.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ..._tempQuestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppDimens.marginM),
                    child: ListTile(
                      leading: Container(
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
                      title: Text(
                        question.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${question.type == 'SINGLE' ? 'Đơn đáp án' : 'Đa đáp án'} • ${question.timeLimit}s • ${question.points} điểm',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: AppTheme.primaryColor,
                            onPressed: () => _showEditQuestionForm(index),
                            tooltip: 'Sửa câu hỏi',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: AppTheme.errorColor,
                            onPressed: () => _removeTempQuestion(index),
                            tooltip: 'Xóa câu hỏi',
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: AppDimens.marginXL),

              // Create Button
              Obx(
                () => CustomButton(
                  text: 'Tạo Quiz',
                  onPressed: _quizController.isLoading.value
                      ? null
                      : _createQuiz,
                  isLoading: _quizController.isLoading.value,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    _optionControllers.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
