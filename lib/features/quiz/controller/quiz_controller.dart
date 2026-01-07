import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/data/providers/quiz_provider.dart';

// Controller for managing quiz operations and state
class QuizController extends GetxController {
  final QuizProvider _quizProvider = QuizProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverImageUrlController = TextEditingController();
  final isPublic = true.obs;
  final selectedCategories = <String>[].obs;

  final questionTextController = TextEditingController();
  final questionImageUrlController = TextEditingController();
  final questionType = 'SINGLE'.obs;
  final timeLimitController = TextEditingController(text: '20');
  final pointsController = TextEditingController(text: '100');
  final questionOptions = <QuestionOption>[].obs;

  final isLoading = false.obs;
  final currentQuizId = ''.obs;
  final quizzes = <QuizModel>[].obs;
  final questions = <QuestionModel>[].obs;

  // Multi-selection mode
  final isMultiSelectionMode = false.obs;
  final selectedQuizIds = <String>[].obs;

  StreamSubscription? _userQuizzesSubscription;

  @override
  void onClose() {
    _userQuizzesSubscription?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    questionTextController.dispose();
    questionImageUrlController.dispose();
    timeLimitController.dispose();
    pointsController.dispose();
    super.onClose();
  }

  // Resets all form controllers and state to default values
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    coverImageUrlController.clear();
    isPublic.value = true;
    selectedCategories.clear();
    questionTextController.clear();
    questionImageUrlController.clear();
    questionType.value = 'SINGLE';
    timeLimitController.text = '20';
    pointsController.text = '100';
    questionOptions.clear();
    currentQuizId.value = '';
    questions.clear();
  }

  // Creates a new quiz with the current form data
  Future<String?> createQuiz() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      if (selectedCategories.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn ít nhất 1 phân loại',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      if (selectedCategories.length > 3) {
        Get.snackbar(
          'Lỗi',
          'Chỉ được chọn tối đa 3 phân loại',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      final quiz = QuizModel(
        id: '',
        title: titleController.text.trim(),
        titleLower: titleController.text.trim().toLowerCase(),
        description: descriptionController.text.trim().isEmpty
            ? 'Không có mô tả'
            : descriptionController.text.trim(),
        coverImageUrl: coverImageUrlController.text.trim().isEmpty
            ? null
            : coverImageUrlController.text.trim(),
        ownerId: user.uid,
        isPublic: isPublic.value,
        createdAt: DateTime.now(),
        categoryIds: selectedCategories.toList(),
        totalQuestions: 0,
        totalPlays: 0,
      );

      final quizId = await _quizProvider.createQuiz(quiz);
      currentQuizId.value = quizId;
      return quizId;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tạo quiz: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Updates an existing quiz with the current form data
  Future<void> updateQuiz(String quizId) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedCategories.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn ít nhất 1 phân loại',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedCategories.length > 3) {
        Get.snackbar(
          'Lỗi',
          'Chỉ được chọn tối đa 3 phân loại',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final quiz = QuizModel(
        id: quizId,
        title: titleController.text.trim(),
        titleLower: titleController.text.trim().toLowerCase(),
        description: descriptionController.text.trim().isEmpty
            ? 'Không có mô tả'
            : descriptionController.text.trim(),
        coverImageUrl: coverImageUrlController.text.trim().isEmpty
            ? null
            : coverImageUrlController.text.trim(),
        ownerId: user.uid,
        isPublic: isPublic.value,
        createdAt: DateTime.now(),
        categoryIds: selectedCategories.toList(),
        totalQuestions: questions.length,
        totalPlays: 0,
      );

      await _quizProvider.updateQuiz(quizId, quiz);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật quiz: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Loads a quiz and populates the form for editing
  Future<void> loadQuizForEdit(String quizId) async {
    try {
      isLoading.value = true;
      final quiz = await _quizProvider.getQuizById(quizId);
      if (quiz == null) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy quiz',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      currentQuizId.value = quizId;
      titleController.text = quiz.title;
      descriptionController.text = quiz.description;
      coverImageUrlController.text = quiz.coverImageUrl ?? '';
      isPublic.value = quiz.isPublic;
      selectedCategories.value = quiz.categoryIds;
      await loadQuestions(quizId);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải quiz: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Retrieves a quiz by its ID
  Future<QuizModel?> getQuizById(String quizId) async {
    return await _quizProvider.getQuizById(quizId);
  }

  // Loads all questions for a quiz and updates the questions list
  Future<void> loadQuestions(String quizId) async {
    try {
      final loadedQuestions = await _quizProvider.getQuizQuestions(quizId);
      questions.value = loadedQuestions;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Loads all quizzes owned by the current user
  void loadUserQuizzes() {
    final user = _auth.currentUser;
    if (user == null) {
      quizzes.value = [];
      return;
    }

    _userQuizzesSubscription?.cancel();

    _userQuizzesSubscription = _quizProvider
        .getUserQuizzes(user.uid)
        .listen(
          (quizList) {
            quizzes.value = quizList;
          },
          onError: (error) {
            if (_auth.currentUser == null) return;

            print('Error loading quizzes: $error');
            Get.snackbar(
              'Lỗi',
              'Không thể tải danh sách quiz: ${error.toString()}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            quizzes.value = [];
          },
        );
  }

  // Clears all data and stops listening to streams
  void clearDataAndStopListening() {
    _userQuizzesSubscription?.cancel();
    _userQuizzesSubscription = null;
    quizzes.clear();
    questions.clear();
    currentQuizId.value = '';
  }

  // Adds a new empty option to the question options list
  void addQuestionOption() {
    final optionId = DateTime.now().millisecondsSinceEpoch.toString();
    questionOptions.add(
      QuestionOption(id: optionId, text: '', isCorrect: false),
    );
  }

  // Removes a question option at the specified index
  void removeQuestionOption(int index) {
    if (questionOptions.length > 2) {
      questionOptions.removeAt(index);
    } else {
      Get.snackbar(
        'Thông báo',
        'Quiz phải có ít nhất 2 đáp án',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // Validates the question form
  bool _validateQuestionForm() {
    if (questionOptions.length < 2) {
      Get.snackbar(
        'Lỗi',
        'Phải có ít nhất 2 đáp án',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    final hasCorrectAnswer = questionOptions.any((opt) => opt.isCorrect);
    if (!hasCorrectAnswer) {
      Get.snackbar(
        'Lỗi',
        'Phải có ít nhất 1 đáp án đúng',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (questionType.value == 'SINGLE') {
      final correctCount = questionOptions.where((opt) => opt.isCorrect).length;
      if (correctCount > 1) {
        Get.snackbar(
          'Lỗi',
          'Câu hỏi đơn đáp án chỉ được có 1 đáp án đúng',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }

    return true;
  }

  // Creates a new question in a quiz with the current form data
  Future<void> createQuestion(String quizId) async {
    try {
      if (!_validateQuestionForm()) {
        return;
      }

      isLoading.value = true;

      final question = QuestionModel(
        id: '',
        text: questionTextController.text.trim(),
        imageUrl: questionImageUrlController.text.trim().isEmpty
            ? null
            : questionImageUrlController.text.trim(),
        type: questionType.value,
        timeLimit: int.tryParse(timeLimitController.text) ?? 20,
        points: int.tryParse(pointsController.text) ?? 100,
        order: questions.length + 1,
        options: questionOptions.toList(),
      );

      await _quizProvider.createQuestion(quizId, question);
      await _quizProvider.updateQuizQuestionCount(quizId, questions.length + 1);

      questionTextController.clear();
      questionImageUrlController.clear();
      questionType.value = 'SINGLE';
      timeLimitController.text = '20';
      pointsController.text = '100';
      questionOptions.clear();
      addQuestionOption();
      addQuestionOption();
      await loadQuestions(quizId);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tạo câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Updates an existing question in a quiz with the current form data
  Future<void> updateQuestion(String quizId, String questionId) async {
    try {
      if (!_validateQuestionForm()) {
        return;
      }

      isLoading.value = true;

      final existingQuestion = questions.firstWhere((q) => q.id == questionId);
      final question = QuestionModel(
        id: questionId,
        text: questionTextController.text.trim(),
        imageUrl: questionImageUrlController.text.trim().isEmpty
            ? null
            : questionImageUrlController.text.trim(),
        type: questionType.value,
        timeLimit: int.tryParse(timeLimitController.text) ?? 20,
        points: int.tryParse(pointsController.text) ?? 100,
        order: existingQuestion.order,
        options: questionOptions.toList(),
      );

      await _quizProvider.updateQuestion(quizId, questionId, question);
      await loadQuestions(quizId);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Deletes a question from a quiz and reorders remaining questions
  Future<void> deleteQuestion(String quizId, String questionId) async {
    try {
      isLoading.value = true;
      await _quizProvider.deleteQuestion(quizId, questionId);
      await loadQuestions(quizId);

      final questionsToReorder = <QuestionModel>[];
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question.order != i + 1) {
          questionsToReorder.add(question.copyWith(order: i + 1));
        }
      }

      if (questionsToReorder.isNotEmpty) {
        await _quizProvider.reorderQuestionsBatch(quizId, questionsToReorder);
      }

      await _quizProvider.updateQuizQuestionCount(quizId, questions.length);
      await loadQuestions(quizId);

      Get.snackbar(
        'Thành công',
        'Đã xóa câu hỏi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Populates the question form with data from an existing question for editing
  void loadQuestionForEdit(QuestionModel question) {
    questionTextController.text = question.text;
    questionImageUrlController.text = question.imageUrl ?? '';
    questionType.value = question.type;
    timeLimitController.text = question.timeLimit.toString();
    pointsController.text = question.points.toString();
    questionOptions.value = question.options;
  }

  // Resets the question form to default values
  void clearQuestionForm() {
    questionTextController.clear();
    questionImageUrlController.clear();
    questionType.value = 'SINGLE';
    timeLimitController.text = '20';
    pointsController.text = '100';
    questionOptions.clear();
  }

  // Deletes a quiz and all its associated questions
  // Returns true if deletion was successful, false otherwise
  Future<bool> deleteQuiz(String quizId) async {
    try {
      isLoading.value = true;
      await _quizProvider.deleteQuiz(quizId);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggles multi-selection mode
  void toggleSelectionMode(String? initialQuizId) {
    isMultiSelectionMode.value = !isMultiSelectionMode.value;
    selectedQuizIds.clear();
    if (isMultiSelectionMode.value && initialQuizId != null) {
      selectedQuizIds.add(initialQuizId);
    }
  }

  // Toggles selection of a specific quiz
  // Does not automatically exit multi-select mode when list becomes empty
  void toggleQuizSelection(String quizId) {
    if (selectedQuizIds.contains(quizId)) {
      selectedQuizIds.remove(quizId);
    } else {
      selectedQuizIds.add(quizId);
    }
  }

  // Checks if all quizzes are currently selected
  bool get isAllSelected {
    if (quizzes.isEmpty) return false;
    return selectedQuizIds.length == quizzes.length;
  }

  // Toggles selection of all quizzes
  // If all are selected, deselects all but keeps multi-select mode active
  // If not all are selected, selects all
  void toggleSelectAll() {
    if (isAllSelected) {
      selectedQuizIds.clear();
    } else {
      selectedQuizIds.value = quizzes.map((quiz) => quiz.id).toList();
    }
  }

  // Deletes all selected quizzes
  Future<void> deleteSelectedQuizzes() async {
    if (selectedQuizIds.isEmpty) return;

    try {
      isLoading.value = true;
      final count = selectedQuizIds.length;
      await _quizProvider.deleteQuizzes(selectedQuizIds.toList());

      Get.snackbar(
        'Thành công',
        'Đã xóa $count quiz',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isMultiSelectionMode.value = false;
      selectedQuizIds.clear();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa các quiz đã chọn: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Exits selection mode
  void exitSelectionMode() {
    isMultiSelectionMode.value = false;
    selectedQuizIds.clear();
  }
}
