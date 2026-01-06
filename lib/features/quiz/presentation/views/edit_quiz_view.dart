import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/quiz/controller/quiz_controller.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/presentation/widgets/quiz_form_fields.dart';

class EditQuizView extends StatefulWidget {
  final String quizId;

  const EditQuizView({super.key, required this.quizId});

  @override
  State<EditQuizView> createState() => _EditQuizViewState();
}

class _EditQuizViewState extends State<EditQuizView> {
  final _formKey = GlobalKey<FormState>();
  final _questionFormKey = GlobalKey<FormState>();
  late final QuizController _quizController;
  final _categoryProvider = CategoryProvider();
  bool _showQuestionForm = false;
  String? _editingQuestionId;
  final ScrollController _scrollController = ScrollController();
  final Map<int, TextEditingController> _optionControllers = {};

  @override
  void initState() {
    super.initState();
    _quizController = Get.put(QuizController(), tag: 'quiz');
    _quizController.loadQuizForEdit(widget.quizId);
    _quizController.clearQuestionForm();
  }

  void _showAddQuestionForm() {
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    _optionControllers.clear();

    setState(() {
      _showQuestionForm = true;
      _editingQuestionId = null;
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

  void _showEditQuestionForm(QuestionModel question) {
    setState(() {
      _showQuestionForm = true;
      _editingQuestionId = question.id;
      _quizController.loadQuestionForEdit(question);
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

  void _hideQuestionForm() {
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    _optionControllers.clear();

    setState(() {
      _showQuestionForm = false;
      _editingQuestionId = null;
      _quizController.clearQuestionForm();
    });
  }

  Future<void> _saveQuestion() async {
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

    final currentScrollPosition = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;

    if (_editingQuestionId != null) {
      await _quizController.updateQuestion(widget.quizId, _editingQuestionId!);
    } else {
      await _quizController.createQuestion(widget.quizId);
    }

    _hideQuestionForm();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScrollPosition);
      }
    });
  }

  Future<void> _updateQuiz() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    await _quizController.updateQuiz(widget.quizId);

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 200));

      Get.snackbar(
        'Thành công',
        'Cập nhật quiz thành công',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 2000),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(true);
      } else {
        Get.back(result: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(
        () => _quizController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppDimens.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          QuizFormFields(
                            quizController: _quizController,
                            categoryProvider: _categoryProvider,
                          ),
                          const SizedBox(height: AppDimens.marginM),
                          CustomButton(
                            text: 'Cập nhật Quiz',
                            onPressed: _updateQuiz,
                            isLoading: _quizController.isLoading.value,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.marginXL),

                    // Questions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Câu hỏi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _editingQuestionId != null
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
                                  controller:
                                      _quizController.questionTextController,
                                  validator: Validators.questionText,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: AppDimens.marginM),
                                CustomInputField(
                                  label: 'Link ảnh (tùy chọn)',
                                  controller: _quizController
                                      .questionImageUrlController,
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
                                        controller:
                                            _quizController.pointsController,
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
                                    selected: {
                                      _quizController.questionType.value,
                                    },
                                    onSelectionChanged:
                                        (Set<String> newSelection) {
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
                                                    label:
                                                        'Đáp án ${index + 1}',
                                                    controller: _optionControllers
                                                        .putIfAbsent(
                                                          index,
                                                          () =>
                                                              TextEditingController(
                                                                text:
                                                                    option.text,
                                                              ),
                                                        ),
                                                    validator:
                                                        Validators.optionText,
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
                                                    // Tìm index của đáp án đúng (nếu có)
                                                    final correctIndex =
                                                        _quizController
                                                            .questionOptions
                                                            .indexWhere(
                                                              (opt) =>
                                                                  opt.isCorrect,
                                                            );
                                                    return Radio<int>(
                                                      value: index,
                                                      groupValue:
                                                          correctIndex >= 0
                                                          ? correctIndex
                                                          : null,
                                                      onChanged: (selectedIndex) {
                                                        // Khi chọn đáp án này, bỏ chọn tất cả đáp án khác
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
                                                                  value ??
                                                                  false,
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
                                                    icon: const Icon(
                                                      Icons.delete,
                                                    ),
                                                    color: AppTheme.errorColor,
                                                    onPressed: () {
                                                      _optionControllers[index]
                                                          ?.dispose();
                                                      _optionControllers.remove(
                                                        index,
                                                      );

                                                      final keysToUpdate =
                                                          _optionControllers
                                                              .keys
                                                              .where(
                                                                (key) =>
                                                                    key > index,
                                                              )
                                                              .toList()
                                                            ..sort();

                                                      for (var oldKey
                                                          in keysToUpdate) {
                                                        final controller =
                                                            _optionControllers
                                                                .remove(oldKey);
                                                        if (controller !=
                                                            null) {
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
                                      if (_quizController
                                              .questionOptions
                                              .length <
                                          6)
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
                                  text: _editingQuestionId != null
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

                    const SizedBox(height: AppDimens.marginM),
                    if (_quizController.questions.isEmpty)
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
                      ..._quizController.questions.map(
                        (question) => Card(
                          margin: const EdgeInsets.only(
                            bottom: AppDimens.marginM,
                          ),
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
                              '${question.options.length} đáp án • ${question.type == 'SINGLE' ? 'Đơn' : 'Đa'} đáp án',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditQuestionForm(question),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: AppTheme.errorColor,
                                  onPressed: () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: const Text(
                                          'Bạn có chắc muốn xóa câu hỏi này?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Get.back();

                                              final currentScrollPosition =
                                                  _scrollController.hasClients
                                                  ? _scrollController
                                                        .position
                                                        .pixels
                                                  : 0.0;

                                              await _quizController
                                                  .deleteQuestion(
                                                    widget.quizId,
                                                    question.id,
                                                  );

                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 100,
                                                ),
                                                () {
                                                  if (_scrollController
                                                      .hasClients) {
                                                    _scrollController.jumpTo(
                                                      currentScrollPosition,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                            child: const Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
