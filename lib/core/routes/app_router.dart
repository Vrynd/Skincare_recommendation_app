import 'package:go_router/go_router.dart';
import 'package:recommendation_app/features/auth/screens/auth_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const AuthScreen()),
    ],
  );
}
