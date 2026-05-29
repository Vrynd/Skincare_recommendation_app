import 'package:go_router/go_router.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/auth/screens/auth_screen.dart';
import 'package:recommendation_app/features/home/screens/home_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  /// Membuat GoRouter yang reaktif terhadap perubahan status autentikasi.
  /// Menggunakan `refreshListenable` agar redirect dievaluasi ulang
  /// setiap kali `AuthProvider` memanggil `notifyListeners()`.
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isOnAuthPage = state.matchedLocation == login;

        // Jika sedang loading (inisialisasi awal), jangan redirect
        if (authProvider.isLoading) return null;

        // User sudah login tapi masih di halaman auth → arahkan ke home
        if (isLoggedIn && isOnAuthPage) return home;

        // User belum login tapi mencoba akses halaman selain auth → arahkan ke login
        if (!isLoggedIn && !isOnAuthPage) return login;

        return null;
      },
      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}
