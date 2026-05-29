import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase menggunakan URL proyek dan legacy anon API key
  await Supabase.initialize(
    url: 'https://dedqbqjsyykcfsqwpyag.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlZHFicWpzeXlrY2ZzcXdweWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1ODMxMjQsImV4cCI6MjA5NDE1OTEyNH0.Lsx3OXNd_nOl_rie-0wIeff_3q9PCvYYOzvd5mf_bxU',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skincare Recommendation',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Mengubah ke Light Mode untuk mereview gaya baru
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
