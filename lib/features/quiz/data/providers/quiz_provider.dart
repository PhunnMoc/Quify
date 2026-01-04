import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quify/features/quiz/data/models/quiz_model.dart';
import 'package:quify/features/quiz/data/models/question_model.dart';

/// Provider for Firestore operations related to quizzes and questions
class QuizProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _quizzesCollection = 'quizzes';
  final String _questionsSubCollection = 'questions';

  /// Creates a new quiz document in Firestore
  /// Returns the generated document ID
  Future<String> createQuiz(QuizModel quiz) async {
    final docRef = _firestore.collection(_quizzesCollection).doc();
    final data = quiz.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
    return docRef.id;
  }

  /// Updates an existing quiz document in Firestore
  Future<void> updateQuiz(String quizId, QuizModel quiz) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .update(quiz.toMap());
  }

  /// Retrieves a quiz by its document ID
  /// Returns null if the quiz does not exist
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore
          .collection(_quizzesCollection)
          .doc(quizId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        if (!data.containsKey('id') || data['id'] == null || data['id'].toString().isEmpty) {
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

  /// Retrieves all quizzes owned by a specific user
  /// Returns a stream that emits lists of quizzes ordered by creation date (newest first)
  /// Falls back to manual sorting if Firestore index is not available
  Stream<List<QuizModel>> getUserQuizzes(String userId) {
    try {
      try {
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
      } catch (e) {
        if (e.toString().contains('index') || 
            e.toString().contains('Index') ||
            e.toString().contains('requires an index')) {
          return _firestore
              .collection(_quizzesCollection)
              .where('ownerId', isEqualTo: userId)
              .snapshots()
              .map((snapshot) {
                try {
                  final quizzes = snapshot.docs
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
                  quizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return quizzes;
                } catch (e) {
                  print('Error processing quiz snapshot: $e');
                  return <QuizModel>[];
                }
              });
        }
        rethrow;
      }
    } catch (e) {
      print('Error in getUserQuizzes: $e');
      return Stream.value(<QuizModel>[]);
    }
  }

  /// Retrieves all public quizzes
  /// Returns a stream ordered by creation date (newest first)
  Stream<List<QuizModel>> getPublicQuizzes() {
    return _firestore
        .collection(_quizzesCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data()))
            .toList());
  }

  /// Retrieves public quizzes that match any of the provided category IDs
  /// Returns an empty stream if no category IDs are provided
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
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data()))
            .toList());
  }

  /// Deletes a quiz and all its associated questions
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

  /// Creates a new question in a quiz's questions subcollection
  /// Returns the generated document ID
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

  /// Updates an existing question in a quiz
  Future<void> updateQuestion(
      String quizId, String questionId, QuestionModel question) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .doc(questionId)
        .update(question.toMap());
  }

  /// Retrieves all questions for a quiz, ordered by question order
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

  /// Retrieves a real-time stream of questions for a quiz, ordered by question order
  Stream<List<QuestionModel>> getQuizQuestionsStream(String quizId) {
    return _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuestionModel.fromMap(doc.data()))
            .toList());
  }

  /// Deletes a question from a quiz
  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .collection(_questionsSubCollection)
        .doc(questionId)
        .delete();
  }

  /// Updates the total number of questions in a quiz
  Future<void> updateQuizQuestionCount(String quizId, int count) async {
    await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .update({'totalQuestions': count});
  }
}

