import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/features/game/controller/game_controller.dart';
import 'package:quify/features/home/controller/home_controller.dart';
import 'package:quify/routes/app_routes.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  final authRepository = AuthRepository();
  final TextEditingController _pinController = TextEditingController();
  String? _displayName;
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();

    // Listen for tab changes to reload data
    ever(_homeController.shouldReloadUserData, (reload) {
      if (reload) {
        _loadUserData();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  // Reload when the widget is rebuilt or dependencies change,
  // but since we are in a tab that might be kept alive, we need a way to know when it's visible.
  // A simple way in GetX when returning from another screen (like Profile edit) is to check if we can listen to something.
  // However, since Profile edit is a separate route, when we pop back, the HomeTab might not rebuild if it's in an IndexedStack.
  // But wait, the Profile Tab is separate.
  // If the user edits profile in AccountTab -> EditProfileView, then returns to AccountTab, then switches to HomeTab.
  // HomeTab is in IndexedStack, so it keeps state.

  // We can expose a method to refresh or listen to a global user stream.
  // Let's use `Get.find<ProfileController>()` if it exists, or better, `AuthController`.

  // Actually, simplest is to just call `_loadUserData()` whenever the build method runs? No, that's too frequent.
  // Let's rely on `Get.find<HomeController>()` to notify tabs?

  // Alternative: Wrap `_displayName` in an `Obx` if we move it to a controller.
  // For now, let's keep it local but maybe use `FocusNode` or just check visibility?

  // Let's try to reload every time the widget is built? No.

  // The user asked: "Khi user đổi họ tên thì khi quay lại home hãy fetch lại thông tin".
  // "Quay lại home" implies either:
  // 1. Popping back from a screen pushed ON TOP of Home.
  // 2. Switching tabs back to Home.

  // If it's a pushed screen (like Create Quiz), `then()` can be used.
  // But Edit Profile is likely accessed from Account Tab.
  // So the user goes Home -> Account -> Edit Profile -> Back to Account -> Switch to Home.
  // In this case, `HomeTab` is just sitting in the `IndexedStack`.

  // We can make `HomeTab` check for updates when it becomes visible.
  // Or we can simple use a StreamBuilder or Obx if we have a reactive user source.
  // `AuthController` seems to be the place.

  // Let's check `AuthController`.

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await authRepository.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _displayName =
              userData['fullName'] as String? ??
              userData['username'] as String?;
        });
      }
    }
  }

  void _joinGame() {
    if (_pinController.text.isNotEmpty) {
      // Logic to join game
      final gameController = Get.put(GameController());
      gameController.joinGame(_pinController.text);
    } else {
      Get.snackbar(
        "Lỗi",
        "Vui lòng nhập mã PIN",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào, ${_displayName ?? 'Khách'}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sẵn sàng chơi chưa?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Join Game Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tham gia Game",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 5,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: "Nhập mã PIN",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Tham gia",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Tính năng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Feature Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _FeatureCard(
                    icon: Icons.add_circle_outline,
                    title: "Tạo Quiz",
                    color: Colors.blue,
                    onTap: () => Get.toNamed(AppRoutes.createQuiz),
                  ),
                  _FeatureCard(
                    icon: Icons.library_books,
                    title: "Thư viện",
                    color: Colors.orange,
                    onTap: () {
                      final homeController =
                          Get.find<
                            HomeController
                          >(); // Assuming HomeController is available
                      homeController.changeTab(2); // Switch to Library
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
