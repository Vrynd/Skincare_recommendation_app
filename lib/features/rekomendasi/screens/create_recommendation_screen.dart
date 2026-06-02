import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_navigation.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class CreateRecommendationScreen extends StatelessWidget {
  const CreateRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 48),
          children: [
            const AppNavigation(),
            AppSpacing.v24,
            const SizedBox(
              height: 400,
              child: Center(
                child: Text('Konten Halaman Rekomendasi Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
