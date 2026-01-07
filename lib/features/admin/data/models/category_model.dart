class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final int orderPriority;
  final int totalQuizzes;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.orderPriority,
    this.totalQuizzes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      'orderPriority': orderPriority,
      'totalQuizzes': totalQuizzes,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      isActive: map['isActive'] as bool? ?? true,
      orderPriority: map['orderPriority'] as int? ?? 999,
      totalQuizzes: map['totalQuizzes'] as int? ?? 0,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    bool? isActive,
    int? orderPriority,
    int? totalQuizzes,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      orderPriority: orderPriority ?? this.orderPriority,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
    );
  }
}

