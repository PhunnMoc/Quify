import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/features/home/controller/home_controller.dart';
import 'package:quify/features/home/presentation/views/tabs/home_tab.dart';
import 'package:quify/features/home/presentation/views/tabs/library_tab.dart';
import 'package:quify/features/home/presentation/views/tabs/profile_tab.dart';
import 'package:quify/features/home/presentation/views/tabs/search_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeTab(),
      const SearchTab(),
      const LibraryTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: tabs),
      ),
      bottomNavigationBar: Obx(
        () => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _CustomBottomNavBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
            ),
            // Floating CREATE Button
            // Tâm của nút (32px từ bottom của FAB) nằm ngang với top của bottom nav
            Builder(
              builder: (context) {
                // Bottom nav Container bắt đầu từ bottom: 0
                // Top của Container = chiều cao của Container
                // Chiều cao = SafeArea bottom + padding top 8 + content ~41 + padding bottom 8
                final safeAreaBottom = MediaQuery.of(context).padding.bottom;
                const contentHeight = 8.0 + 41.0 + 8.0 - 8.0; // 57px
                final bottomNavTop = safeAreaBottom + contentHeight;
                // Tâm FAB (32px từ bottom của FAB) cần ở top của bottom nav
                // Bottom của FAB = bottomNavTop - 32
                return Positioned(
                  bottom: bottomNavTop - 32,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Navigate to create quiz page
                      Get.snackbar(
                        'Tạo mới',
                        'Tính năng đang phát triển',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            children: [
              // Home
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: AppStrings.home,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              // Search
              Expanded(
                child: _NavItem(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  label: AppStrings.search,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              // Spacer for CREATE button (invisible placeholder)
              const SizedBox(width: 64),
              // Library
              Expanded(
                child: _NavItem(
                  icon: Icons.library_books_outlined,
                  selectedIcon: Icons.library_books,
                  label: AppStrings.library,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
              // Profile
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: AppStrings.profile,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
