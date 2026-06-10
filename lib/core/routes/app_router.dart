import 'package:go_router/go_router.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:recommendation_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:recommendation_app/features/navigations/screens/navigation_screen.dart';
import 'package:recommendation_app/features/rekomendasi/screens/create_recommendation_screen.dart';
import 'package:recommendation_app/features/rekomendasi/screens/result_recommendation_screen.dart';

class AppRouter {
  // Rute Path Fisik
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String homePath = '/home';
  static const String createRecommendationPath = '/create-recommendation';
  static const String recommendationResultPath = '/recommendation-result';

  // Rute Nama Logis (Named Routing)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgot-password';
  static const String homeName = 'home';
  static const String createRecommendationName = 'create-recommendation';
  static const String recommendationResultName = 'recommendation-result';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splashPath,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isLoading) {
          return splashPath;
        }

        final isLoggedIn = authProvider.isAuthenticated;

        if (isLoggedIn) {
          final isOnAuthPage = state.matchedLocation == loginPath ||
              state.matchedLocation == splashPath;
          return isOnAuthPage ? homePath : null;
        } else {
          final isOnLoginPage = state.matchedLocation == loginPath;
          return isOnLoginPage ? null : loginPath;
        }
      },
      routes: [
        GoRoute(
          path: splashPath,
          name: splashName,
          builder: (context, state) => const SplashScreen(),
        ),
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
