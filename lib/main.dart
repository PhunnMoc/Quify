import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quify/firebase_options.dart';

void main() async {
  // 1. Đảm bảo Binding được khởi tạo trước khi gọi code bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  // Nếu lệnh này chạy lỗi, app sẽ dừng lại và báo lỗi đỏ ở Console
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Chạy App sau khi kết nối thành công
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Kiểm tra kết nối")),
        body: const Center(
          child: Text(
            "Firebase Connected!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
