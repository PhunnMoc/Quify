import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/data/providers/quiz_provider.dart';

/// Controller for managing quiz operations and state
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
  final pointsController = TextEditingController(text: '1000');
  final questionOptions = <QuestionOption>[].obs;

  final isLoading = false.obs;
  final currentQuizId = ''.obs;
  final quizzes = <QuizModel>[].obs;
  final questions = <QuestionModel>[].obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    coverImageUrlController.dispose();
    questionTextController.dispose();
    questionImageUrlController.dispose();
    timeLimitController.dispose();
    pointsController.dispose();
    super.onClose();
  }

  /// Resets all form controllers and state to default values
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
    pointsController.text = '1000';
    questionOptions.clear();
    currentQuizId.value = '';
  }

  /// Creates a new quiz with the current form data
  /// Returns the quiz ID if successful, null otherwise
  Future<String?> createQuiz() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      if (selectedCategories.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn ít nhất 1 phân loại',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      if (selectedCategories.length > 3) {
        Get.snackbar(
          'Lỗi',
          'Chỉ được chọn tối đa 3 phân loại',
          snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing quiz with the current form data
  Future<void> updateQuiz(String quizId) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng đăng nhập',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedCategories.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn ít nhất 1 phân loại',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedCategories.length > 3) {
        Get.snackbar(
          'Lỗi',
          'Chỉ được chọn tối đa 3 phân loại',
          snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads a quiz and populates the form for editing
  /// Delays execution to avoid setState conflicts during build
  Future<void> loadQuizForEdit(String quizId) async {
    await Future.delayed(Duration.zero);

    try {
      isLoading.value = true;
      final quiz = await _quizProvider.getQuizById(quizId);
      if (quiz == null) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy quiz',
          snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Retrieves a quiz by its ID
  Future<QuizModel?> getQuizById(String quizId) async {
    return await _quizProvider.getQuizById(quizId);
  }

  /// Loads all questions for a quiz and updates the questions list
  Future<void> loadQuestions(String quizId) async {
    try {
      final loadedQuestions = await _quizProvider.getQuizQuestions(quizId);
      questions.value = loadedQuestions;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Loads all quizzes owned by the current user
  /// Sets up a real-time stream that updates when quizzes change
  void loadUserQuizzes() {
    final user = _auth.currentUser;
    if (user == null) {
      print('loadUserQuizzes: No user found');
      quizzes.value = [];
      return;
    }

    print('loadUserQuizzes: Loading quizzes for user ${user.uid}');
    _quizProvider
        .getUserQuizzes(user.uid)
        .listen(
          (quizList) {
            print('loadUserQuizzes: Loaded ${quizList.length} quizzes');
            quizzes.value = quizList;
          },
          onError: (error) {
            print('loadUserQuizzes: Error loading quizzes: $error');
            Get.snackbar(
              'Lỗi',
              'Không thể tải danh sách quiz: ${error.toString()}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            quizzes.value = [];
          },
        );
  }

  /// Adds a new empty option to the question options list
  void addQuestionOption() {
    final optionId = 'opt_${questionOptions.length + 1}';
    questionOptions.add(
      QuestionOption(id: optionId, text: '', isCorrect: false),
    );
  }

  /// Removes a question option at the specified index
  /// Prevents removal if it would result in fewer than 2 options
  void removeQuestionOption(int index) {
    if (questionOptions.length > 2) {
      questionOptions.removeAt(index);
    } else {
      Get.snackbar(
        'Thông báo',
        'Quiz phải có ít nhất 2 đáp án',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Creates a new question in a quiz with the current form data
  /// Validates that the question has at least 2 options and at least one correct answer
  Future<void> createQuestion(String quizId) async {
    try {
      if (questionOptions.length < 2) {
        Get.snackbar(
          'Lỗi',
          'Phải có ít nhất 2 đáp án',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final hasCorrectAnswer = questionOptions.any((opt) => opt.isCorrect);
      if (!hasCorrectAnswer) {
        Get.snackbar(
          'Lỗi',
          'Phải có ít nhất 1 đáp án đúng',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (questionType.value == 'SINGLE') {
        final correctCount = questionOptions
            .where((opt) => opt.isCorrect)
            .length;
        if (correctCount > 1) {
          Get.snackbar(
            'Lỗi',
            'Câu hỏi đơn đáp án chỉ được có 1 đáp án đúng',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      isLoading.value = true;

      final question = QuestionModel(
        id: '', // Will be set by provider
        text: questionTextController.text.trim(),
        imageUrl: questionImageUrlController.text.trim().isEmpty
            ? null
            : questionImageUrlController.text.trim(),
        type: questionType.value,
        timeLimit: int.tryParse(timeLimitController.text) ?? 20,
        points: int.tryParse(pointsController.text) ?? 1000,
        order: questions.length + 1,
        options: questionOptions.toList(),
      );

      await _quizProvider.createQuestion(quizId, question);
      await _quizProvider.updateQuizQuestionCount(quizId, questions.length + 1);

      questionTextController.clear();
      questionImageUrlController.clear();
      questionType.value = 'SINGLE';
      timeLimitController.text = '20';
      pointsController.text = '1000';
      questionOptions.clear();
      addQuestionOption();
      addQuestionOption();
      await loadQuestions(quizId);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tạo câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing question in a quiz with the current form data
  /// Validates that the question has at least 2 options and at least one correct answer
  Future<void> updateQuestion(String quizId, String questionId) async {
    try {
      if (questionOptions.length < 2) {
        Get.snackbar(
          'Lỗi',
          'Phải có ít nhất 2 đáp án',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final hasCorrectAnswer = questionOptions.any((opt) => opt.isCorrect);
      if (!hasCorrectAnswer) {
        Get.snackbar(
          'Lỗi',
          'Phải có ít nhất 1 đáp án đúng',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (questionType.value == 'SINGLE') {
        final correctCount = questionOptions
            .where((opt) => opt.isCorrect)
            .length;
        if (correctCount > 1) {
          Get.snackbar(
            'Lỗi',
            'Câu hỏi đơn đáp án chỉ được có 1 đáp án đúng',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
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
        points: int.tryParse(pointsController.text) ?? 1000,
        order: existingQuestion.order,
        options: questionOptions.toList(),
      );

      await _quizProvider.updateQuestion(quizId, questionId, question);
      await loadQuestions(quizId);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a question from a quiz and reorders remaining questions
  /// Updates the quiz's total question count
  Future<void> deleteQuestion(String quizId, String questionId) async {
    try {
      isLoading.value = true;
      await _quizProvider.deleteQuestion(quizId, questionId);
      await loadQuestions(quizId);
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question.order != i + 1) {
          await _quizProvider.updateQuestion(
            quizId,
            question.id,
            question.copyWith(order: i + 1),
          );
        }
      }

      await _quizProvider.updateQuizQuestionCount(quizId, questions.length - 1);
      await loadQuestions(quizId);

      Get.snackbar(
        'Thành công',
        'Đã xóa câu hỏi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa câu hỏi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Populates the question form with data from an existing question for editing
  void loadQuestionForEdit(QuestionModel question) {
    questionTextController.text = question.text;
    questionImageUrlController.text = question.imageUrl ?? '';
    questionType.value = question.type;
    timeLimitController.text = question.timeLimit.toString();
    pointsController.text = question.points.toString();
    questionOptions.value = question.options;
  }

  /// Resets the question form to default values
  /// Does not add default options; the view should handle that
  void clearQuestionForm() {
    questionTextController.clear();
    questionImageUrlController.clear();
    questionType.value = 'SINGLE';
    timeLimitController.text = '20';
    pointsController.text = '1000';
    questionOptions.clear();
  }

  /// Deletes a quiz and all its associated questions
  Future<void> deleteQuiz(String quizId) async {
    try {
      isLoading.value = true;
      await _quizProvider.deleteQuiz(quizId);
      Get.snackbar(
        'Thành công',
        'Đã xóa quiz',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      loadUserQuizzes();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa quiz: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
