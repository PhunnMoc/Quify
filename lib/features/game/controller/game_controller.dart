import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/features/game/data/models/game_session.dart';
import 'package:quify/features/game/data/models/player.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';
import 'package:quify/features/quiz/data/providers/quiz_provider.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/routes/app_routes.dart';

class GameController extends GetxController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final QuizProvider _quizProvider = QuizProvider();
  final AuthRepository _authRepository = AuthRepository();

  // Observables
  var currentGame = GameSession().obs;
  var players = <Player>[].obs;
  var timeLeft = 0.obs;
  var isHost = false.obs;
  var questions = <QuestionModel>[].obs; // Questions for the current game
  var isLoading = false.obs;
  var selectedAnswerIndex = Rx<int?>(
    null,
  ); // Currently selected answer index (for SINGLE)
  var selectedAnswerIndices =
      <int>[].obs; // Selected answer indices (for MULTIPLE)
  var lastClickedAnswerIndex = Rx<int?>(
    null,
  ); // Last clicked answer index (for MULTIPLE final answer)
  var isTimeUp =
      false.obs; // Track if time is up to show correct/incorrect highlights
  var hasSubmittedAnswer = false
      .obs; // Track if answer has been submitted to prevent duplicate submissions

  Timer? _timer;
  StreamSubscription? _gameSub;
  StreamSubscription? _playerSub;

  // ==================== HELPER FUNCTIONS ====================

  /// Reset all local state related to answer selection and highlighting
  /// Called when moving to a new question to ensure clean state
  void _resetLocalState() {
    selectedAnswerIndex.value = null;
    selectedAnswerIndices.clear();
    lastClickedAnswerIndex.value = null;
    isTimeUp.value = false;
    hasSubmittedAnswer.value = false;
  }

  Future<String> _getCurrentUserName() async {
    try {
      final userData = await _authRepository.getUserData(currentUserId);
      if (userData != null && userData['fullName'] != null) {
        return userData['fullName'] as String;
      }
    } catch (e) {
      // Fallback if error
    }
    return FirebaseAuth.instance.currentUser?.displayName ?? "User";
  }

  // ==================== HOST FUNCTIONS ====================

  // 1. Host creates a game room
  Future<void> createGame(QuizModel quiz) async {
    try {
      isLoading.value = true;
      isHost.value = true;

      // Fetch questions for the quiz
      questions.value = await _quizProvider.getQuizQuestions(quiz.id);

      if (questions.isEmpty) {
        Get.snackbar(
          "Lỗi",
          "Quiz này không có câu hỏi nào!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      String pin = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();
      var newGameRef = _dbRef.child('active_games').push();

      var newGame = GameSession(
        id: newGameRef.key!,
        hostId: currentUserId,
        quizId: quiz.id,
        pinCode: pin,
        state: 'WAITING',
      );

      await newGameRef.set(newGame.toJson());

      // Host is NOT added to players list - only regular players join

      _listenToGame(newGameRef.key!);
      Get.toNamed(
        AppRoutes.lobby,
      ); // Navigate to waiting screen (need to add route)
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Tạo game thất bại: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Host starts the game
  void startGame() {
    _dbRef.child('active_games/${currentGame.value.id}').update({
      'state': 'PLAYING',
      'currentQuestionIndex': 0,
      'questionStartTime': ServerValue.timestamp,
    });
  }

  // 3. Host moves to next question
  void nextQuestion() {
    // 1. Reset local state immediately on Host side
    _resetLocalState();

    int nextIndex = currentGame.value.currentQuestionIndex + 1;

    if (nextIndex >= questions.length) {
      finishGame();
    } else {
      // 2. Update Firebase to notify other clients about question change
      _dbRef.child('active_games/${currentGame.value.id}').update({
        'currentQuestionIndex': nextIndex,
        'questionStartTime': ServerValue.timestamp,
      });
    }
  }

  // 4. Host finishes game
  void finishGame() {
    _dbRef.child('active_games/${currentGame.value.id}').update({
      'state': 'FINISHED',
    });
  }

  // 5. Host closes room and saves history
  Future<void> closeAndArchiveGame() async {
    String gameId = currentGame.value.id;

    // Get final data
    DataSnapshot snapshot = await _dbRef.child('active_games/$gameId').get();
    if (snapshot.value != null) {
      // Save to history
      await _dbRef.child('history_games/$gameId').set(snapshot.value);
      // Remove from active
      await _dbRef.child('active_games/$gameId').remove();
    }
    Get.offAllNamed(AppRoutes.home);
    Get.delete<GameController>(force: true);
  }

  // ==================== PLAYER FUNCTIONS ====================

  // 1. Player joins game
  Future<void> joinGame(String pinCode) async {
    try {
      isLoading.value = true;
      isHost.value = false;

      // Find game by PIN
      // Note: This query requires indexing on 'pinCode' in Firebase Rules for performance,
      // but works for small datasets without it.
      final event = await _dbRef
          .child('active_games')
          .orderByChild('pinCode')
          .equalTo(pinCode)
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> games = event.snapshot.value as Map;
        String gameId = games.keys.first;
        var gameData = games[gameId] as Map;
        String quizId = gameData['quizId'] ?? '';

        // Fetch questions so player can see them
        if (quizId.isNotEmpty) {
          questions.value = await _quizProvider.getQuizQuestions(quizId);
        }

        // Join into players node
        String playerName = await _getCurrentUserName();
        Player me = Player(id: currentUserId, name: playerName, score: 0);
        await _dbRef
            .child('active_games/$gameId/players/$currentUserId')
            .set(me.toJson());

        _listenToGame(gameId);
        Get.toNamed(AppRoutes.lobby);
      } else {
        Get.snackbar(
          "Lỗi",
          "Không tìm thấy phòng!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Tham gia thất bại: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Player selects answer (only stores locally, not sent to DB yet)
  void selectAnswer(int answerIndex) {
    if (timeLeft.value <= 0) return;

    int currentIndex = currentGame.value.currentQuestionIndex;
    if (currentIndex >= questions.length) return;

    QuestionModel currentQuestion = questions[currentIndex];

    if (currentQuestion.type == 'SINGLE') {
      // Single choice: only one answer can be selected
      selectedAnswerIndex.value = answerIndex;
      selectedAnswerIndices.clear();
      lastClickedAnswerIndex.value = answerIndex;
    } else if (currentQuestion.type == 'MULTIPLE') {
      // Multiple choice: toggle selection
      if (selectedAnswerIndices.contains(answerIndex)) {
        selectedAnswerIndices.remove(answerIndex);
      } else {
        selectedAnswerIndices.add(answerIndex);
      }
      selectedAnswerIndex.value = null;
      // Always update last clicked index (even when toggling off)
      lastClickedAnswerIndex.value = answerIndex;
    }
  }

  // 3. Calculate and submit final answer when time is up
  Future<void> submitFinalAnswer() async {
    if (timeLeft.value > 0) return; // Only submit when time is up
    if (hasSubmittedAnswer.value) return; // Prevent duplicate submissions

    // --- FIX: Lấy điểm hiện tại TRƯỚC khi xử lý update DB ---
    // Để tránh việc listener cập nhật lại list players làm sai lệch tính toán hiển thị
    int currentScoreBeforeUpdate = 0;
    var myPlayer = players.firstWhereOrNull((p) => p.id == currentUserId);
    if (myPlayer != null) {
      currentScoreBeforeUpdate = myPlayer.score;
    }
    // --------------------------------------------------------

    int currentIndex = currentGame.value.currentQuestionIndex;
    if (currentIndex >= questions.length) return;

    QuestionModel currentQuestion = questions[currentIndex];

    // Mark as submitted to prevent duplicate calls
    hasSubmittedAnswer.value = true;

    // Mark time as up first to show highlights immediately
    // Keep selected answers so they can be highlighted
    isTimeUp.value = true;

    int pointsEarned = 0;
    bool hasCorrectAnswer = false;

    if (currentQuestion.type == 'SINGLE') {
      // Single choice: use the last selected answer
      if (selectedAnswerIndex.value == null) {
        // No answer selected, save null and show wrong notification
        await _dbRef
            .child(
              'active_games/${currentGame.value.id}/players/$currentUserId',
            )
            .update({'selectedAnswer': null});
        // hasCorrectAnswer is already false, pointsEarned is already 0
        // Will show wrong notification below
      } else {
        int answerIndex = selectedAnswerIndex.value!;
        bool isCorrect = currentQuestion.options[answerIndex].isCorrect;

        if (isCorrect) {
          pointsEarned = currentQuestion.points;
          hasCorrectAnswer = true;
        }

        // Update database with final answer and score
        await _dbRef
            .child('active_games/${currentGame.value.id}/players/$currentUserId')
            .update({
              'selectedAnswer': answerIndex,
              'score': ServerValue.increment(pointsEarned),
            });
      }
    } else if (currentQuestion.type == 'MULTIPLE') {
      // Multiple choice: answer is all selected answers
      if (selectedAnswerIndices.isEmpty) {
        // No answer selected, save null and show wrong notification
        await _dbRef
            .child(
              'active_games/${currentGame.value.id}/players/$currentUserId',
            )
            .update({'selectedAnswer': null});
        // hasCorrectAnswer is already false, pointsEarned is already 0
        // Will show wrong notification below
      } else {

        // Check if user selected any incorrect answer
        bool hasIncorrectAnswer = false;
        for (int index in selectedAnswerIndices) {
          if (!currentQuestion.options[index].isCorrect) {
            hasIncorrectAnswer = true;
            break;
          }
        }

        // If user has any incorrect answer, give 0 points
        if (hasIncorrectAnswer) {
          pointsEarned = 0;
          hasCorrectAnswer = false;
        } else {
          // No incorrect answers: calculate points for each correct selected answer
          int correctAnswersCount = currentQuestion.options
              .where((opt) => opt.isCorrect)
              .length;
          if (correctAnswersCount > 0) {
            // Points per correct answer = total points / correct count (rounded up)
            int pointsPerAnswer = (currentQuestion.points / correctAnswersCount)
                .ceil();

            // Count how many correct answers the user selected
            int correctSelectedCount = 0;
            for (int index in selectedAnswerIndices) {
              if (currentQuestion.options[index].isCorrect) {
                correctSelectedCount++;
                pointsEarned += pointsPerAnswer;
              }
            }

            hasCorrectAnswer = correctSelectedCount > 0;
          }
        }

        // Use the last clicked answer index (for display purposes)
        int answerIndexToSave =
            lastClickedAnswerIndex.value ?? selectedAnswerIndices.last;

        // Update database with final answer and score
        await _dbRef
            .child('active_games/${currentGame.value.id}/players/$currentUserId')
            .update({
              'selectedAnswer': answerIndexToSave,
              'score': ServerValue.increment(pointsEarned),
            });
      }
    }

    // --- FIX: TÍNH ĐIỂM MỚI DỰA TRÊN ĐIỂM ĐÃ LƯU TỪ ĐẦU ---
    // Không lấy lại từ list players nữa vì có thể list đã được update từ server
    int newPlayerScore = currentScoreBeforeUpdate + pointsEarned;

    // Show notification
    if (hasCorrectAnswer && pointsEarned > 0) {
      Get.snackbar(
        "Đúng rồi!",
        "+$pointsEarned điểm. Điểm hiện tại: $newPlayerScore",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else if (!hasCorrectAnswer) {
      // Show wrong notification if user selected wrong answer or didn't select any answer
      Get.snackbar(
        "Sai rồi!",
        "Không có điểm. Điểm hiện tại: $currentScoreBeforeUpdate",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    // DO NOT reset selected answers here - keep them for highlighting
    // They will be reset when moving to next question
  }

  // 3. Update personal stats
  Future<void> _updateMyStats(int scoreEarned) async {
    final statsRef = _dbRef.child('user_stats/$currentUserId');
    await statsRef.runTransaction((Object? currentData) {
      Map<String, dynamic> stats = {};
      if (currentData != null && currentData is Map) {
        stats = Map<String, dynamic>.from(currentData);
      }

      stats['totalGames'] = (stats['totalGames'] ?? 0) + 1;
      stats['totalScore'] = (stats['totalScore'] ?? 0) + scoreEarned;

      return Transaction.success(stats);
    });
  }

  // ==================== COMMON SYNC LOGIC ====================

  void _listenToGame(String gameId) {
    // A. Listen to Game State
    _gameSub = _dbRef.child('active_games/$gameId').onValue.listen((event) {
      if (event.snapshot.value == null) {
        // Game deleted or finished completely
        _timer?.cancel();
        if (Get.currentRoute == AppRoutes.game ||
            Get.currentRoute == AppRoutes.lobby) {
          Get.offAllNamed(AppRoutes.home);
          Get.snackbar(
            "Thông báo",
            "Game đã kết thúc.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.amber,
            colorText: Colors.white,
          );
          Get.delete<GameController>(force: true);
        }
        return;
      }

      var data = event.snapshot.value as Map;
      var newSession = GameSession.fromMap(data);
      var oldState = currentGame.value.state;
      var oldQuestionIndex = currentGame.value.currentQuestionIndex;

      // Check if question index changed BEFORE updating currentGame
      // This ensures we reset state before UI renders with new question
      if (newSession.currentQuestionIndex != oldQuestionIndex) {
        _resetLocalState();
      }

      // Update currentGame after resetting state
      currentGame.value = newSession;

      // 1. Navigation
      if (newSession.state == 'PLAYING' && Get.currentRoute != AppRoutes.game) {
        // Ensure reset when entering game screen
        _resetLocalState();
        Get.offNamed(AppRoutes.game);
      } else if (newSession.state == 'FINISHED' &&
          Get.currentRoute != AppRoutes.result) {
        Get.offNamed(AppRoutes.result);
      }

      // 2. Stats Update
      if (newSession.state == 'FINISHED' &&
          oldState != 'FINISHED' &&
          !isHost.value) {
        var myData = players.firstWhereOrNull((p) => p.id == currentUserId);
        if (myData != null) {
          _updateMyStats(myData.score);
          Get.snackbar(
            "Kết quả",
            "Bạn đạt được ${myData.score} điểm!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }

      // 3. Timer Sync
      if (newSession.state == 'PLAYING') {
        // Only sync timer if question start time changed (new question) or timer is not active
        if (oldQuestionIndex != newSession.currentQuestionIndex ||
            _timer == null ||
            !_timer!.isActive) {
          _syncTimer(newSession.questionStartTime);
        }
      }
    });

    // B. Listen to Players (Realtime Scoreboard)
    _playerSub = _dbRef.child('active_games/$gameId/players').onValue.listen((
      event,
    ) {
      if (event.snapshot.value == null) return;
      var map = event.snapshot.value as Map;
      players.value = map.entries.map((e) {
        var pMap = e.value as Map;
        pMap['id'] = e.key;
        return Player.fromMap(pMap);
      }).toList();
      // Sort by score descending
      players.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  void _syncTimer(int startTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;
      int duration =
          15000; // 15 seconds per question (Could be dynamic from QuestionModel)

      // Use question specific time limit if available
      if (questions.isNotEmpty &&
          currentGame.value.currentQuestionIndex < questions.length) {
        duration =
            questions[currentGame.value.currentQuestionIndex].timeLimit * 1000;
      }

      int elapsed = now - startTime;
      int remain = ((duration - elapsed) / 1000).round();

      if (remain >= 0) {
        timeLeft.value = remain;
      } else {
        timeLeft.value = 0;
        timer.cancel();
        // Submit final answer when time is up
        if (!isHost.value) {
          submitFinalAnswer();
        }
      }
    });
  }

  @override
  void onClose() {
    _gameSub?.cancel();
    _playerSub?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
