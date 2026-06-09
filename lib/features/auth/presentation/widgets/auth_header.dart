import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  child: AppContainer(
                    shape: BoxShape.circle,
                    width: 48,
                    height: 48,
                    opacity: 0.8,
                    padding: EdgeInsets.zero,
                    showShadow: false,
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft02,
                        color: context.colors.onSurface,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.v32,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(
                  title,
                  style: context.text.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
