import 'package:go_router/go_router.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:recommendation_app/features/navigations/screens/navigation_screen.dart';

class AppRouter {
  // Rute Path Fisik
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String homePath = '/home';

  // Rute Nama Logis (Named Routing)
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgot-password';
  static const String homeName = 'home';

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
      ],
    );
  }
}
