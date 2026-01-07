import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a quiz
class QuizModel {
  final String id;
  final String title;
  final String titleLower;
  final String description;
  final String? coverImageUrl;
  final String ownerId;
  final bool isPublic;
  final DateTime createdAt;
  final List<String> categoryIds;
  final List<String> keywords; // For search
  final int totalQuestions;
  final int totalPlays;

  QuizModel({
    required this.id,
    required this.title,
    required this.titleLower,
    required this.description,
    this.coverImageUrl,
    required this.ownerId,
    required this.isPublic,
    required this.createdAt,
    required this.categoryIds,
    this.keywords = const [],
    required this.totalQuestions,
    this.totalPlays = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleLower': titleLower,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'categoryIds': categoryIds,
      'keywords': keywords,
      'totalQuestions': totalQuestions,
      'totalPlays': totalPlays,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return QuizModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      titleLower: map['titleLower']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      coverImageUrl: map['coverImageUrl']?.toString(),
      ownerId: map['ownerId']?.toString() ?? '',
      isPublic: map['isPublic'] as bool? ?? false,
      createdAt: parseDateTime(map['createdAt']),
      categoryIds: (map['categoryIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      keywords: (map['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      totalPlays: map['totalPlays'] as int? ?? 0,
    );
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? titleLower,
    String? description,
    String? coverImageUrl,
    String? ownerId,
    bool? isPublic,
    DateTime? createdAt,
    List<String>? categoryIds,
    List<String>? keywords,
    int? totalQuestions,
    int? totalPlays,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLower: titleLower ?? this.titleLower,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      categoryIds: categoryIds ?? this.categoryIds,
      keywords: keywords ?? this.keywords,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPlays: totalPlays ?? this.totalPlays,
    );
  }
}

