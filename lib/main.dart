import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/bindings/initial_binding.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/firebase_options.dart';
import 'package:quify/routes/app_pages.dart';
import 'package:quify/routes/app_routes.dart';

void main() async {
  // 1. Đảm bảo Binding được khởi tạo trước khi gọi code bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Chạy App sau khi kết nối thành công
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quify',
      debugShowCheckedModeBanner: false, // Bỏ banner debug
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
    );
  }

  String _getInitialRoute() {
    // Check if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AppRoutes.home;
    }
    return AppRoutes.login;
  }
}
