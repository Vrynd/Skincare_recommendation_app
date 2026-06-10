import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class HistoryTile extends StatelessWidget {
  final String date;
  final String month;
  final String label;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onTapMore;

  const HistoryTile({
    super.key,
    required this.date,
    required this.month,
    required this.label,
    required this.title,
    this.onTap,
    this.onTapMore,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      padding: EdgeInsets.zero,
      opacity: 0.8,
      showShadow: false,
      borderRadius: AppRadius.br24,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.br24,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              AppContainer(
                color: context.colors.onSurfaceVariant,
                opacity: 0.06,
                showBorder: false,
                showShadow: false,
                width: 50,
                height: 50,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        month.toUpperCase(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: context.text.titleLarge?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: context.text.labelMedium?.copyWith(
                            color: context.colors.outline,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTapMore,
                            borderRadius: BorderRadius.circular(100),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 0.0,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedMoreHorizontal,
                                size: 18,
                                color: context.colors.outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      title,
                      style: context.text.titleLarge?.copyWith(
                        color: context.colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
