import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quify/features/admin/data/models/category_model.dart';

/// Provider for Category operations in Firestore
class CategoryProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'categories';

  /// Checks if a category with the given slug already exists
  Future<bool> categoryExistsBySlug(String slug) async {
    if (slug.isEmpty) {
      return false;
    }
    final querySnapshot = await _firestore
        .collection(_categoriesCollection)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  /// Creates a category document with auto-generated ID
  Future<String> createCategory(CategoryModel category) async {
    final docRef = _firestore.collection(_categoriesCollection).doc();
    // Ensure ID is set
    final data = category.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
    return docRef.id;
  }

  /// Gets all existing category slugs
  Future<Set<String>> getAllCategorySlugs() async {
    final querySnapshot = await _firestore
        .collection(_categoriesCollection)
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data()['slug'] as String? ?? '')
        .where((slug) => slug.isNotEmpty)
        .toSet();
  }

  /// Gets all active categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      // Thử query với orderBy trước
      try {
        final querySnapshot = await _firestore
            .collection(_categoriesCollection)
            .where('isActive', isEqualTo: true)
            .orderBy('orderPriority')
            .get();
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id') || data['id'] == null) {
            data['id'] = doc.id;
          }
          return CategoryModel.fromMap(data);
        }).toList();
      } catch (e) {
        // Nếu lỗi do thiếu index, thử query không có orderBy
        if (e.toString().contains('index') || e.toString().contains('Index')) {
          final querySnapshot = await _firestore
              .collection(_categoriesCollection)
              .where('isActive', isEqualTo: true)
              .get();
          final categories = querySnapshot.docs.map((doc) {
            final data = doc.data();
            if (!data.containsKey('id') || data['id'] == null) {
              data['id'] = doc.id;
            }
            return CategoryModel.fromMap(data);
          }).toList();
          // Sort manually
          categories.sort((a, b) => a.orderPriority.compareTo(b.orderPriority));
          return categories;
        }
        rethrow;
      }
    } catch (e) {
      // Fallback: lấy tất cả categories không filter
      final querySnapshot = await _firestore
          .collection(_categoriesCollection)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null) {
          data['id'] = doc.id;
        }
        return CategoryModel.fromMap(data);
      }).toList();
    }
  }

  /// Gets top categories by priority (limit default 10)
  Future<List<CategoryModel>> getTopCategories({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('orderPriority')
          .limit(limit)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null) {
          data['id'] = doc.id;
        }
        return CategoryModel.fromMap(data);
      }).toList();
    } catch (e) {
      // Fallback if index missing
      final all = await getAllCategories();
      return all.take(limit).toList();
    }
  }

  /// Gets category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _firestore.collection(_categoriesCollection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (!data.containsKey('id') || data['id'] == null) {
        data['id'] = doc.id;
      }
      return CategoryModel.fromMap(data);
    }
    return null;
  }
}

