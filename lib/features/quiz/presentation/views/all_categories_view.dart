import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/features/quiz/controller/public_quiz_controller.dart';
import 'package:quify/routes/app_routes.dart';

class AllCategoriesView extends StatefulWidget {
  const AllCategoriesView({super.key});

  @override
  State<AllCategoriesView> createState() => _AllCategoriesViewState();
}

class _AllCategoriesViewState extends State<AllCategoriesView> {
  final controller = Get.find<PublicQuizController>();

  @override
  void initState() {
    super.initState();
    // Load all categories if not already loaded or if previously empty
    controller.loadAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả danh mục'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allCategories.isEmpty) {
          return const Center(child: Text('Chưa có danh mục nào'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.paddingM),
          itemCount: controller.allCategories.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimens.marginS),
          itemBuilder: (context, index) {
            final category = controller.allCategories[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    category.name.isNotEmpty ? category.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${category.totalQuizzes} quiz'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.toNamed(AppRoutes.categoryQuizzes, arguments: category);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

