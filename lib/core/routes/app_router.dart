import 'package:go_router/go_router.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:recommendation_app/features/navigations/screens/navigation_screen.dart';
import 'package:recommendation_app/features/rekomendasi/screens/create_recommendation_screen.dart';
import 'package:recommendation_app/features/rekomendasi/screens/result_recommendation_screen.dart';

class AppRouter {
  // Rute Path Fisik
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String homePath = '/home';
  static const String createRecommendationPath = '/create-recommendation';
  static const String recommendationResultPath = '/recommendation-result';

  // Rute Nama Logis (Named Routing)
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgot-password';
  static const String homeName = 'home';
  static const String createRecommendationName = 'create-recommendation';
  static const String recommendationResultName = 'recommendation-result';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: loginPath,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isLoading) return null;

        final isLoggedIn = authProvider.isAuthenticated;
        final isOnAuthPage = state.matchedLocation == loginPath;

        if (isLoggedIn) {
          return isOnAuthPage ? homePath : null;
        }
        return isOnAuthPage ? null : loginPath;
      },
      routes: [
        GoRoute(
          path: loginPath,
          name: loginName,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: homePath,
          name: homeName,
          builder: (context, state) => const NavigationScreen(),
        ),
        GoRoute(
          path: createRecommendationPath,
          name: createRecommendationName,
          builder: (context, state) => const CreateRecommendationScreen(),
        ),
        GoRoute(
          path: '$recommendationResultPath/:sessionId',
          name: recommendationResultName,
          builder: (context, state) {
            final sessionId = state.pathParameters['sessionId']!;
            return ResultRecommendationScreen(sessionId: sessionId);
          },
        ),
      ],
    );
  }
}
