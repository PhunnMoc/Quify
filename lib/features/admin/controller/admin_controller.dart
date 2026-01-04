import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/features/admin/data/providers/category_provider.dart';

/// Controller for admin operations
class AdminController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();
  final isLoading = false.obs;

  /// Creates default categories if they don't exist
  Future<void> createDefaultCategories() async {
    try {
      isLoading.value = true;

      // Danh sách 20 category về học tập
      final categories = [
        {
          'id': 'math',
          'name': 'Toán học',
          'slug': 'toan-hoc',
          'isActive': true,
          'orderPriority': 1,
        },
        {
          'id': 'physics',
          'name': 'Vật lý',
          'slug': 'vat-ly',
          'isActive': true,
          'orderPriority': 2,
        },
        {
          'id': 'chemistry',
          'name': 'Hóa học',
          'slug': 'hoa-hoc',
          'isActive': true,
          'orderPriority': 3,
        },
        {
          'id': 'biology',
          'name': 'Sinh học',
          'slug': 'sinh-hoc',
          'isActive': true,
          'orderPriority': 4,
        },
        {
          'id': 'literature',
          'name': 'Ngữ văn',
          'slug': 'ngu-van',
          'isActive': true,
          'orderPriority': 5,
        },
        {
          'id': 'history',
          'name': 'Lịch sử',
          'slug': 'lich-su',
          'isActive': true,
          'orderPriority': 6,
        },
        {
          'id': 'geography',
          'name': 'Địa lý',
          'slug': 'dia-ly',
          'isActive': true,
          'orderPriority': 7,
        },
        {
          'id': 'english',
          'name': 'Tiếng Anh',
          'slug': 'tieng-anh',
          'isActive': true,
          'orderPriority': 8,
        },
        {
          'id': 'informatics',
          'name': 'Tin học',
          'slug': 'tin-hoc',
          'isActive': true,
          'orderPriority': 9,
        },
        {
          'id': 'civic-education',
          'name': 'Giáo dục công dân',
          'slug': 'giao-duc-cong-dan',
          'isActive': true,
          'orderPriority': 10,
        },
        {
          'id': 'art',
          'name': 'Mỹ thuật',
          'slug': 'my-thuat',
          'isActive': true,
          'orderPriority': 11,
        },
        {
          'id': 'music',
          'name': 'Âm nhạc',
          'slug': 'am-nhac',
          'isActive': true,
          'orderPriority': 12,
        },
        {
          'id': 'physical-education',
          'name': 'Thể dục',
          'slug': 'the-duc',
          'isActive': true,
          'orderPriority': 13,
        },
        {
          'id': 'technology',
          'name': 'Công nghệ',
          'slug': 'cong-nghe',
          'isActive': true,
          'orderPriority': 14,
        },
        {
          'id': 'philosophy',
          'name': 'Triết học',
          'slug': 'triet-hoc',
          'isActive': true,
          'orderPriority': 15,
        },
        {
          'id': 'psychology',
          'name': 'Tâm lý học',
          'slug': 'tam-ly-hoc',
          'isActive': true,
          'orderPriority': 16,
        },
        {
          'id': 'economics',
          'name': 'Kinh tế học',
          'slug': 'kinh-te-hoc',
          'isActive': true,
          'orderPriority': 17,
        },
        {
          'id': 'foreign-languages',
          'name': 'Ngoại ngữ khác',
          'slug': 'ngoai-ngu-khac',
          'isActive': true,
          'orderPriority': 18,
        },
        {
          'id': 'test-prep',
          'name': 'Luyện thi',
          'slug': 'luyen-thi',
          'isActive': true,
          'orderPriority': 19,
        },
        {
          'id': 'skills',
          'name': 'Kỹ năng sống',
          'slug': 'ky-nang-song',
          'isActive': true,
          'orderPriority': 20,
        },
      ];

      // Lấy danh sách slug đã tồn tại
      final existingSlugs = await _categoryProvider.getAllCategorySlugs();

      int createdCount = 0;
      int skippedCount = 0;

      // Tạo từng category
      for (final category in categories) {
        final slug = category['slug'] as String;

        // Nếu category đã tồn tại thì skip
        if (existingSlugs.contains(slug)) {
          skippedCount++;
          continue;
        }

        // Tạo category mới với auto ID
        await _categoryProvider.createCategory(category);
        createdCount++;
      }

      Get.snackbar(
        'Thành công',
        'Đã tạo $createdCount category mới. Bỏ qua $skippedCount category đã tồn tại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tạo categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
