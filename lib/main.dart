import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/rekomendasi_provider.dart';
import 'package:recommendation_app/features/navigations/provider/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase menggunakan URL proyek dan legacy anon API key
  await Supabase.initialize(
    url: 'https://dedqbqjsyykcfsqwpyag.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlZHFicWpzeXlrY2ZzcXdweWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1ODMxMjQsImV4cCI6MjA5NDE1OTEyNH0.Lsx3OXNd_nOl_rie-0wIeff_3q9PCvYYOzvd5mf_bxU',
  );

  // Buat instance AuthProvider agar bisa dipass ke Router dan Provider tree
  final authProvider = AuthProvider()..initializeAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => HomeLocationProvider()),
        ChangeNotifierProvider(create: (_) => RekomendasiProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MyApp(authProvider: authProvider),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  late final GoRouter _router = AppRouter.createRouter(authProvider);

  MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skincare Recommendation',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Mengubah ke Light Mode untuk mereview gaya baru
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

