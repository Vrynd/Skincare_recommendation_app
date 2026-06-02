import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/features/navigations/provider/navigation_provider.dart';

class FloatingDock extends StatelessWidget {
  const FloatingDock({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    return AppContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: AppRadius.br32,
      showShadow: true,
      width: null,
      color: context.colors.surfaceContainerLowest,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          _buildDockItem(
            context,
            index: 0,
            currentIndex: currentIndex,
            icon: HugeIcons.strokeRoundedHome01,
            label: 'Home',
            onTap: () => navProvider.changeIndex(0),
          ),
          _buildDockItem(
            context,
            index: 1,
            currentIndex: currentIndex,
            icon: HugeIcons.strokeRoundedAnalytics02,
            label: 'Statistik',
            onTap: () => navProvider.changeIndex(1),
          ),
          _buildDockItem(
            context,
            index: 2,
            currentIndex: currentIndex,
            icon: HugeIcons.strokeRoundedUser,
            label: 'Akun Saya',
            onTap: () => navProvider.changeIndex(2),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required List<List<dynamic>> icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 52,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: isSelected
              ? context.colors.onSurface
              : context.colors.surfaceContainerHigh.withValues(alpha: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              color: isSelected ? context.colors.surface : context.colors.outline,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
