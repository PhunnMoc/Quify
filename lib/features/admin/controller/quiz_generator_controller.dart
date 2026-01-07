import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/providers/quiz_provider.dart';

class QuizGeneratorController extends GetxController {
  final QuizProvider _quizProvider = QuizProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;

  // Sample data for generation
  final List<String> _quizTitles = [
    'Kiến thức Địa lý Việt Nam', 'Lịch sử thế giới', 'Khoa học vui', 'Đố vui dân gian', 
    'Tiếng Anh cơ bản', 'Toán học thú vị', 'Văn học Việt Nam', 'Công nghệ thông tin', 
    'Âm nhạc quốc tế', 'Thể thao tổng hợp', 'Ẩm thực ba miền', 'Điện ảnh Hollywood',
    'Vũ trụ bao la', 'Động vật hoang dã', 'Cơ thể người', 'Hóa học đời sống',
    'Vật lý vui', 'Lịch sử Việt Nam', 'Địa lý thế giới', 'Văn hóa các nước'
  ];

  final List<String> _quizDescriptions = [
    'Thử thách kiến thức của bạn về chủ đề này!',
    'Bạn biết bao nhiêu về lĩnh vực này?',
    'Cùng khám phá những điều thú vị nhé.',
    'Quiz dành cho người yêu thích tìm hiểu.',
    'Kiểm tra IQ của bạn qua bài test này.',
    'Những câu hỏi hóc búa đang chờ bạn.',
    'Vừa học vừa chơi, kiến thức muôn nơi.',
    'Dành cho các bạn đam mê khám phá.'
  ];

  final List<Map<String, dynamic>> _sampleQuestions = [
    {
      'text': 'Thủ đô của Việt Nam là gì?',
      'options': ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Huế'],
      'correctIndex': 0
    },
    {
      'text': 'Đỉnh núi cao nhất thế giới là?',
      'options': ['K2', 'Everest', 'Fansipan', 'Phú Sĩ'],
      'correctIndex': 1
    },
    {
      'text': 'Nước nào đông dân nhất thế giới (2023)?',
      'options': ['Trung Quốc', 'Mỹ', 'Ấn Độ', 'Indonesia'],
      'correctIndex': 2
    },
    {
      'text': 'Con vật nào là chúa sơn lâm?',
      'options': ['Voi', 'Gấu', 'Sư tử', 'Hổ'],
      'correctIndex': 3
    },
    {
      'text': '1 + 1 bằng mấy?',
      'options': ['1', '2', '3', '4'],
      'correctIndex': 1
    },
    {
      'text': 'Mặt trời mọc ở hướng nào?',
      'options': ['Đông', 'Tây', 'Nam', 'Bắc'],
      'correctIndex': 0
    },
    {
      'text': 'Ai là tác giả của Truyện Kiều?',
      'options': ['Nguyễn Trãi', 'Nguyễn Du', 'Xuân Diệu', 'Hồ Xuân Hương'],
      'correctIndex': 1
    },
    {
      'text': 'Hành tinh nào gần Mặt Trời nhất?',
      'options': ['Sao Kim', 'Sao Hỏa', 'Sao Thủy', 'Sao Mộc'],
      'correctIndex': 2
    },
    {
      'text': 'Nước là hợp chất của nguyên tố nào?',
      'options': ['Hydro và Oxy', 'Hydro và Nitơ', 'Oxy và Cacbon', 'Heli và Oxy'],
      'correctIndex': 0
    },
    {
      'text': 'Bóng đá có bao nhiêu cầu thủ mỗi đội trên sân?',
      'options': ['10', '11', '12', '9'],
      'correctIndex': 1
    },
  ];

  Future<void> generateRandomQuizzes() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để tạo dữ liệu');
      return;
    }

    try {
      isLoading.value = true;
      final categories = await _categoryProvider.getAllCategories();
      final categoryIds = categories.map((c) => c['id'] as String).toList();
      
      if (categoryIds.isEmpty) {
        Get.snackbar('Lỗi', 'Cần có ít nhất 1 danh mục để tạo quiz. Vui lòng tạo danh mục trước.');
        return;
      }

      final random = Random();
      int successCount = 0;

      // Generate 50 quizzes
      for (int i = 0; i < 50; i++) {
        // 1. Create Quiz Info
        final title = _quizTitles[random.nextInt(_quizTitles.length)] + ' #${i + 1}';
        final description = _quizDescriptions[random.nextInt(_quizDescriptions.length)];
        
        // Random categories (1 to 3)
        final numCategories = random.nextInt(3) + 1;
        final selectedCategories = <String>{};
        while (selectedCategories.length < numCategories && selectedCategories.length < categoryIds.length) {
          selectedCategories.add(categoryIds[random.nextInt(categoryIds.length)]);
        }

        final quiz = QuizModel(
          id: '', // Will be set by provider
          title: title,
          titleLower: title.toLowerCase(),
          description: description,
          ownerId: user.uid,
          isPublic: true, // Make public for search testing
          createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          categoryIds: selectedCategories.toList(),
          totalQuestions: 0, // Will update after adding questions
          totalPlays: random.nextInt(1000), // Random plays for sorting
        );

        final quizId = await _quizProvider.createQuiz(quiz);

        // 2. Add Questions (3 to 10 questions)
        final numQuestions = random.nextInt(8) + 3;
        final quizQuestions = <QuestionModel>[];

        for (int j = 0; j < numQuestions; j++) {
          final sampleQ = _sampleQuestions[random.nextInt(_sampleQuestions.length)];
          final options = (sampleQ['options'] as List<String>).asMap().entries.map((e) {
            return QuestionOption(
              id: DateTime.now().millisecondsSinceEpoch.toString() + j.toString() + e.key.toString(),
              text: e.value,
              isCorrect: e.key == sampleQ['correctIndex'],
            );
          }).toList();

          final question = QuestionModel(
            id: '', // Will be set by provider
            text: sampleQ['text'] as String,
            type: 'SINGLE',
            timeLimit: [10, 20, 30][random.nextInt(3)],
            points: [10, 20, 50, 100][random.nextInt(4)],
            order: j + 1,
            options: options,
          );

          await _quizProvider.createQuestion(quizId, question);
          quizQuestions.add(question);
        }

        // Update total questions count
        await _quizProvider.updateQuizQuestionCount(quizId, quizQuestions.length);
        successCount++;
      }

      Get.snackbar(
        'Thành công',
        'Đã tạo $successCount Quiz mẫu',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print('Error generating quizzes: $e');
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra khi tạo dữ liệu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

