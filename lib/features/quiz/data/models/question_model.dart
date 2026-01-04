/// Data model representing a quiz question
class QuestionModel {
  final String id;
  final String text;
  final String? imageUrl;
  final String type; // "SINGLE" or "MULTIPLE"
  final int timeLimit; // seconds
  final int points;
  final int order;
  final List<QuestionOption> options;

  QuestionModel({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.type,
    required this.timeLimit,
    required this.points,
    required this.order,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'type': type,
      'timeLimit': timeLimit,
      'points': points,
      'order': order,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      type: map['type']?.toString() ?? 'SINGLE',
      timeLimit: map['timeLimit'] as int? ?? 20,
      points: map['points'] as int? ?? 1000,
      order: map['order'] as int? ?? 0,
      options: (map['options'] as List<dynamic>?)
              ?.map((opt) => QuestionOption.fromMap(opt as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  QuestionModel copyWith({
    String? id,
    String? text,
    String? imageUrl,
    String? type,
    int? timeLimit,
    int? points,
    int? order,
    List<QuestionOption>? options,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      timeLimit: timeLimit ?? this.timeLimit,
      points: points ?? this.points,
      order: order ?? this.order,
      options: options ?? this.options,
    );
  }
}

/// Data model representing a question answer option
class QuestionOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      isCorrect: map['isCorrect'] as bool? ?? false,
    );
  }

  QuestionOption copyWith({
    String? id,
    String? text,
    bool? isCorrect,
  }) {
    return QuestionOption(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

