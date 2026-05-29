import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AuthTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const AuthTab({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer.bordered(
      height: 58,
      width: double.infinity,
      borderColor: context.colors.surfaceContainerHigh.withValues(alpha: 0.6),
      borderRadius: AppRadius.br32,
      padding: const EdgeInsets.all(5),
      child: Stack(
        children: [
          // Sliding active background indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: AppContainer(
                borderRadius: AppRadius.br32,
                color: context.colors.onSurfaceVariant,
                opacity: 0.05,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          // Row of options
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: context.text.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selectedIndex == 0
                            ? context.colors.primary
                            : context.colors.onSurfaceVariant,
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: context.text.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selectedIndex == 1
                            ? context.colors.primary
                            : context.colors.onSurfaceVariant,
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
