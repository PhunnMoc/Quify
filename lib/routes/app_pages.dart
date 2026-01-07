import 'package:get/get.dart';
import 'package:quify/features/auth/binding/auth_binding.dart';
import 'package:quify/features/auth/presentation/views/email_verification_view.dart';
import 'package:quify/features/auth/presentation/views/login_view.dart';
import 'package:quify/features/auth/presentation/views/register_view.dart';
import 'package:quify/features/auth/presentation/views/setup_profile_view.dart';
import 'package:quify/features/game/presentation/views/game_view.dart';
import 'package:quify/features/game/presentation/views/lobby_view.dart';
import 'package:quify/features/game/presentation/views/result_view.dart';
import 'package:quify/features/home/binding/home_binding.dart';
import 'package:quify/features/home/presentation/views/home_view.dart';
import 'package:quify/features/profile/binding/profile_binding.dart';
import 'package:quify/features/profile/presentation/views/edit_profile_view.dart';
import 'package:quify/features/quiz/binding/quiz_binding.dart';
import 'package:quify/features/quiz/presentation/views/create_quiz_view.dart';
import 'package:quify/features/quiz/presentation/views/edit_quiz_view.dart';
import 'package:quify/features/quiz/presentation/views/quiz_detail_view.dart';
import 'package:quify/features/quiz/presentation/views/hot_quizzes_view.dart';
import 'package:quify/features/quiz/presentation/views/all_categories_view.dart';
import 'package:quify/features/quiz/presentation/views/category_quizzes_view.dart';
import 'package:quify/features/admin/data/models/category_model.dart';
import 'package:quify/routes/app_routes.dart';

/// Application route configuration
/// Maps route names to their corresponding views and bindings
class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => EmailVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.setupProfile,
      page: () => SetupProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.createQuiz,
      page: () => const CreateQuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.quizDetail,
      page: () {
        final quizId = Get.arguments as String;
        return QuizDetailView(quizId: quizId);
      },
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.editQuiz,
      page: () {
        final quizId = Get.arguments as String;
        return EditQuizView(quizId: quizId);
      },
      binding: QuizBinding(),
    ),
    GetPage(name: AppRoutes.hotQuizzes, page: () => const HotQuizzesView()),
    GetPage(
      name: AppRoutes.allCategories,
      page: () => const AllCategoriesView(),
    ),
    GetPage(
      name: AppRoutes.categoryQuizzes,
      page: () {
        final category = Get.arguments as CategoryModel;
        return CategoryQuizzesView(category: category);
      },
    ),
    // Game Routes
    GetPage(
      name: AppRoutes.lobby,
      page: () => const LobbyView(),
      // binding: GameBinding(), // Removed to prevent overwriting existing controller
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameView(),
      // binding: GameBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultView(),
      // binding: GameBinding(),
    ),
  ];
}
