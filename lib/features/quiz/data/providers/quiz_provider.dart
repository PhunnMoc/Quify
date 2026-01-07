import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';

// Provider for Firestore operations related to quizzes and questions
class QuizProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _quizzesCollection = 'quizzes';
  final String _questionsSubCollection = 'questions';

  // Helper to generate keywords for search
  List<String> _generateKeywords(String title) {
    final lowerTitle = title.toLowerCase();
    final words = lowerTitle.split(' ').where((w) => w.isNotEmpty).toList();
    return words;
  }

  // Creates a new quiz document in Firestore
  // Returns the generated document ID
  Future<String> createQuiz(QuizModel quiz) async {
    final docRef = _firestore.collection(_quizzesCollection).doc();

    // Generate keywords if not provided
    List<String> keywords = quiz.keywords;
    if (keywords.isEmpty) {
      keywords = _generateKeywords(quiz.title);
    }

    final data = quiz.copyWith(id: docRef.id, keywords: keywords).toMap();

    await docRef.set(data);
    return docRef.id;
  }

  // Updates an existing quiz document in Firestore
  Future<void> updateQuiz(String quizId, QuizModel quiz) async {
    // Regenerate keywords based on title
    final keywords = _generateKeywords(quiz.title);
    final updatedQuiz = quiz.copyWith(keywords: keywords);

    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .update(updatedQuiz.toMap());
  }

  // Retrieves a quiz by its document ID
  // Returns null if the quiz does not exist
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore
          .collection(_quizzesCollection)
          .doc(quizId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        if (!data.containsKey('id') ||
            data['id'] == null ||
            data['id'].toString().isEmpty) {
          data['id'] = doc.id;
        }
        return QuizModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting quiz by ID: $e');
      return null;
    }
  }

  // Retrieves all quizzes owned by a specific user
  // Returns a stream that emits lists of quizzes ordered by creation date (newest first)
  // Requires Firestore index on (ownerId, createdAt)
  Stream<List<QuizModel>> getUserQuizzes(String userId) {
    return _firestore
        .collection(_quizzesCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data();
                    if (!data.containsKey('id') ||
                        data['id'] == null ||
                        data['id'].toString().isEmpty) {
                      data['id'] = doc.id;
                    }
                    return QuizModel.fromMap(data);
                  } catch (e) {
                    print('Error parsing quiz document ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<QuizModel>()
                .toList();
          } catch (e) {
            print('Error processing quiz snapshot: $e');
            return <QuizModel>[];
          }
        });
  }

  // Retrieves all public quizzes
  // Returns a stream ordered by creation date (newest first)
  Stream<List<QuizModel>> getPublicQuizzes() {
    return _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuizModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Retrieves public quizzes that match any of the provided category IDs
  // Returns an empty stream if no category IDs are provided
  Stream<List<QuizModel>> getQuizzesByCategories(List<String> categoryIds) {
    if (categoryIds.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .where('categoryIds', arrayContainsAny: categoryIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuizModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Deletes a quiz and all its associated questions
  Future<void> deleteQuiz(String quizId) async {
    final questionsSnapshot = await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .get();

    final batch = _firestore.batch();
    for (var doc in questionsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _firestore.collection(_quizzesCollection).doc(quizId).delete();
  }

  // Creates a new question in a quiz's questions subcollection
  // Returns the generated document ID
  Future<String> createQuestion(String quizId, QuestionModel question) async {
    final docRef = _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .doc();
    final data = question.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
    return docRef.id;
  }

  // Updates an existing question in a quiz
  Future<void> updateQuestion(
    String quizId,
    String questionId,
    QuestionModel question,
  ) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .doc(questionId)
        .update(question.toMap());
  }

  // Retrieves all questions for a quiz, ordered by question order
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    final snapshot = await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data()))
        .toList();
  }

  // Retrieves a real-time stream of questions for a quiz, ordered by question order
  Stream<List<QuestionModel>> getQuizQuestionsStream(String quizId) {
    return _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuestionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Deletes a question from a quiz
  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .doc(questionId)
        .delete();
  }

  // Updates the total number of questions in a quiz
  Future<void> updateQuizQuestionCount(String quizId, int count) async {
    await _firestore.collection(_quizzesCollection).doc(quizId).update({
      'totalQuestions': count,
    });
  }

  // Reorders questions using batch update for better performance
  // Updates the order field of multiple questions in a single Firestore write operation
  Future<void> reorderQuestionsBatch(
    String quizId,
    List<QuestionModel> questions,
  ) async {
    final batch = _firestore.batch();
    final collectionRef = _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection);

    for (var question in questions) {
      batch.update(collectionRef.doc(question.id), {'order': question.order});
    }

    await batch.commit();
  }

  // Deletes multiple quizzes and their questions using batch operations
  // Firestore batch limit is 500 operations, so we split into multiple batches if needed
  Future<void> deleteQuizzes(List<String> quizIds) async {
    WriteBatch batch = _firestore.batch();
    int operationCount = 0;

    for (final quizId in quizIds) {
      final questionsSnapshot = await _firestore
          .collection(_quizzesCollection)
          .doc(quizId)
          .collection(_questionsSubCollection)
          .get();

      for (var doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
        operationCount++;

        if (operationCount >= 490) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      batch.delete(_firestore.collection(_quizzesCollection).doc(quizId));
      operationCount++;

      if (operationCount >= 490) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }
  }

  // Retrieves hot quizzes (most played) that are public
  // Limit defaults to 5
  Future<List<QuizModel>> getHotQuizzes({int limit = 5}) async {
    // Note: This requires a composite index on (isPublic ASC, totalPlays DESC)
    try {
      final snapshot = await _firestore
          .collection(_quizzesCollection)
          .where('isPublic', isEqualTo: true)
          .orderBy('totalPlays', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => QuizModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting hot quizzes: $e');
      // Fallback: fetch all public and sort client-side (inefficient but works without index)
      // Only do this if strictly necessary during dev
      final snapshot = await _firestore
          .collection(_quizzesCollection)
          .where('isPublic', isEqualTo: true)
          .limit(20)
          .get();

      final quizzes = snapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data()))
          .toList();

      quizzes.sort((a, b) => b.totalPlays.compareTo(a.totalPlays));
      return quizzes.take(limit).toList();
    }
  }

  // Retrieves paginated public quizzes ordered by total plays
  Future<List<QuizModel>> getPaginatedHotQuizzes({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('totalPlays', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Gets the last document snapshot for pagination
  Future<DocumentSnapshot?> getLastDocument(List<QuizModel> quizzes) async {
    if (quizzes.isEmpty) return null;
    final lastQuiz = quizzes.last;
    final snapshot = await _firestore
        .collection(_quizzesCollection)
        .doc(lastQuiz.id)
        .get();
    return snapshot;
  }

  // Searches public quizzes by title (Prefix and Keyword)
  Future<List<QuizModel>> searchQuizzes(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    // 1. Prefix search: Matches titles starting with query (e.g. "Tiếng" -> "Tiếng Anh")
    final prefixQuery = _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('titleLower')
        .startAt([queryLower])
        .endAt(['$queryLower\uf8ff'])
        .limit(20);

    // 2. Keyword search: Matches words containing query (e.g. "ba" -> "Ẩm thực ba miền")
    // Requires 'keywords' array-contains index
    final keywordQuery = _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .where('keywords', arrayContains: queryLower)
        .limit(20);

    try {
      final results = await Future.wait([
        prefixQuery.get(),
        keywordQuery.get(),
      ]);

      // Merge results and remove duplicates
      final Map<String, QuizModel> uniqueQuizzes = {};

      for (var snapshot in results) {
        for (var doc in snapshot.docs) {
          final quiz = QuizModel.fromMap(doc.data());
          uniqueQuizzes[quiz.id] = quiz;
        }
      }

      return uniqueQuizzes.values.toList();
    } catch (e) {
      print('Error searching quizzes: $e');
      // Fallback: client-side search (only if indexes are broken)
      final snapshot = await _firestore
          .collection(_quizzesCollection)
          .where('isPublic', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data()))
          .where((quiz) {
            final title = quiz.titleLower;
            return title.contains(queryLower);
          })
          .take(20)
          .toList();
    }
  }

  // Clones a quiz and its questions for a new owner
  Future<String> cloneQuiz(QuizModel originalQuiz, String newOwnerId) async {
    // 1. Create new quiz document
    final newQuizDoc = _firestore.collection(_quizzesCollection).doc();
    final newTitle = '${originalQuiz.title} (Copy)';
    final newKeywords = _generateKeywords(newTitle);

    final newQuiz = originalQuiz.copyWith(
      id: newQuizDoc.id,
      ownerId: newOwnerId,
      title: newTitle,
      titleLower: newTitle.toLowerCase(),
      keywords: newKeywords,
      totalPlays: 0,
      createdAt: DateTime.now(),
      isPublic: false, // Default to private when cloning
    );

    // 2. Get all questions from original quiz
    final questionsSnapshot = await _firestore
        .collection(_quizzesCollection)
        .doc(originalQuiz.id)
        .collection(_questionsSubCollection)
        .get();

    final batch = _firestore.batch();

    // Set new quiz data
    batch.set(newQuizDoc, newQuiz.toMap());

    // Copy questions
    for (var doc in questionsSnapshot.docs) {
      final originalQuestion = QuestionModel.fromMap(doc.data());
      final newQuestionDoc = newQuizDoc
          .collection(_questionsSubCollection)
          .doc();

      final newQuestion = originalQuestion.copyWith(id: newQuestionDoc.id);

      batch.set(newQuestionDoc, newQuestion.toMap());
    }

    await batch.commit();
    return newQuizDoc.id;
  }
}
