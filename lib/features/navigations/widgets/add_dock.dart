import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/routes/app_router.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AddDock extends StatelessWidget {
  const AddDock({super.key});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: AppRadius.br32,
      showShadow: true,
      customShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ],
      width: 64,
      height: 64,
      color: context.colors.surfaceContainerLowest,
      child: Center(
        child: GestureDetector(
          onTap: () => context.push(AppRouter.createRecommendationPath),
          child: AppContainer(
            height: 52,
            width: 52,
            shape: BoxShape.circle,
            color: context.colors.onSurface,
            showBorder: false,
            showShadow: false,
            padding: EdgeInsets.zero,
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPlusSign,
                color: context.colors.surface,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
