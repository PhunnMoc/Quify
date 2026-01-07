import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/providers/quiz_provider.dart';

// Controller for managing public quizzes, search, and cloning logic
class PublicQuizController extends GetxController {
  final QuizProvider _quizProvider = QuizProvider();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State
  final hotQuizzes = <QuizModel>[].obs;
  final searchResults = <QuizModel>[].obs;
  final allHotQuizzes = <QuizModel>[].obs; // For the "See All" view
  final isLoadingHot = false.obs;
  final isSearching = false.obs;
  final isLoadingAllHot = false.obs;
  final isCloning = false.obs;
  
  // Cache for author names to reduce Firestore reads
  final authorNames = <String, String>{}.obs;

  // Pagination for Hot Quizzes View
  DocumentSnapshot? _lastDocument;
  final hasMore = true.obs;
  final int _pageSize = 10;

  final searchController = TextEditingController();

  // Observable for search query
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHotQuizzes();
    
    // Listen to text controller changes manually since we can't easily bind it
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Debounce search input
    debounce(
      searchQuery,
      (val) => searchQuizzes(val),
      time: const Duration(seconds: 1),
    );
  }

  @override
  void onClose() {
    searchController.dispose(); // This disposes the controller
    super.onClose();
  }

  // Loads top 5 hot quizzes
  Future<void> loadHotQuizzes() async {
    try {
      isLoadingHot.value = true;
      final quizzes = await _quizProvider.getHotQuizzes();
      hotQuizzes.value = quizzes;
      await _fetchAuthorNames(quizzes);
    } catch (e) {
      print('Error loading hot quizzes: $e');
    } finally {
      isLoadingHot.value = false;
    }
  }

  // Searches quizzes by title
  Future<void> searchQuizzes(String query) async {
    // If query is empty, clear search results but NOT hot quizzes
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false; // Ensure loading state is reset
      return;
    }

    try {
      isSearching.value = true;
      final results = await _quizProvider.searchQuizzes(query.trim());
      searchResults.value = results;
      await _fetchAuthorNames(results);
    } catch (e) {
      print('Error searching quizzes: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // Loads paginated hot quizzes for "See All" screen
  Future<void> loadAllHotQuizzes({bool refresh = false}) async {
    if (refresh) {
      _lastDocument = null;
      allHotQuizzes.clear();
      hasMore.value = true;
    }

    if (!hasMore.value || isLoadingAllHot.value) return;

    try {
      isLoadingAllHot.value = true;
      
      final newQuizzes = await _quizProvider.getPaginatedHotQuizzes(
        limit: _pageSize,
        startAfter: _lastDocument,
      );

      if (newQuizzes.length < _pageSize) {
        hasMore.value = false;
      }

      if (newQuizzes.isNotEmpty) {
        _lastDocument = await _quizProvider.getLastDocument(newQuizzes);
        allHotQuizzes.addAll(newQuizzes);
        await _fetchAuthorNames(newQuizzes);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách: $e');
    } finally {
      isLoadingAllHot.value = false;
    }
  }

  // Helper to fetch and cache author names
  Future<void> _fetchAuthorNames(List<QuizModel> quizzes) async {
    final uniqueOwnerIds = quizzes
        .map((q) => q.ownerId)
        .where((id) => !authorNames.containsKey(id))
        .toSet();

    for (final uid in uniqueOwnerIds) {
      try {
        final userData = await _authRepository.getUserData(uid);
        if (userData != null) {
          // Prefer fullName, fallback to username or email or "Unknown"
          final name = userData['fullName'] ?? userData['username'] ?? 'Người dùng ẩn danh';
          authorNames[uid] = name;
        } else {
          authorNames[uid] = 'Người dùng ẩn danh';
        }
      } catch (e) {
        print('Error fetching user $uid: $e');
        authorNames[uid] = 'Người dùng ẩn danh';
      }
    }
  }

  // Gets display name for an owner ID
  String getAuthorName(String ownerId) {
    return authorNames[ownerId] ?? 'Đang tải...';
  }

  // Clones a quiz
  Future<void> cloneQuiz(QuizModel quiz) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để clone quiz');
      return;
    }

    try {
      isCloning.value = true;
      
      // Perform clone
      await _quizProvider.cloneQuiz(quiz, currentUser.uid);
      
      Get.snackbar(
        'Thành công',
        'Đã clone quiz vào thư viện của bạn',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Optional: Navigate to library or ask user?
      // For now just stay on page with success message as requested
      
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể clone quiz: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCloning.value = false;
    }
  }
}

