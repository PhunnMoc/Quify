import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/bindings/initial_binding.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/features/auth/data/repositories/auth_repository.dart';
import 'package:quify/firebase_options.dart';
import 'package:quify/routes/app_pages.dart';
import 'package:quify/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute = AppRoutes.login;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  /// Determines the initial route based on user authentication and profile status
  Future<void> _determineInitialRoute() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        initialRoute = AppRoutes.login;
        isInitializing = false;
      });
      return;
    }

    final authRepository = AuthRepository();
    await authRepository.reloadUser();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null) {
      setState(() {
        initialRoute = AppRoutes.login;
        isInitializing = false;
      });
      return;
    }

    if (!refreshedUser.emailVerified) {
      setState(() {
        initialRoute = AppRoutes.emailVerification;
        isInitializing = false;
      });
      return;
    }

    final userData = await authRepository.getUserData(refreshedUser.uid);
    if (userData == null || userData['isSetupProfile'] != true) {
      setState(() {
        initialRoute = AppRoutes.setupProfile;
        isInitializing = false;
      });
      return;
    }

    setState(() {
      initialRoute = AppRoutes.home;
      isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ),
      );
    }

    return GetMaterialApp(
      title: 'Quify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
