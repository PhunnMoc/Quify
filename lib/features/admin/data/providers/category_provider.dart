import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<String> createCategory(Map<String, dynamic> categoryData) async {
    final docRef = _firestore.collection(_categoriesCollection).doc();
    await docRef.set(categoryData);
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
  Future<List<Map<String, dynamic>>> getAllCategories() async {
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
          // Đảm bảo có id - ưu tiên id từ data, nếu không thì dùng doc.id
          if (!data.containsKey('id') || data['id'] == null) {
            data['id'] = doc.id;
          }
          return data;
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
            return data;
          }).toList();
          // Sort manually
          categories.sort((a, b) {
            final priorityA = a['orderPriority'] as int? ?? 999;
            final priorityB = b['orderPriority'] as int? ?? 999;
            return priorityA.compareTo(priorityB);
          });
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
        return data;
      }).toList();
    }
  }

  /// Gets category by ID
  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    final doc = await _firestore.collection(_categoriesCollection).doc(id).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}

