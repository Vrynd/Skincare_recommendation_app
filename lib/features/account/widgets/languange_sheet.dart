import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';

class LanguangeSheet extends StatelessWidget {
  final String currentValue;
  final Function(String) onSelected;

  const LanguangeSheet({
    super.key,
    required this.currentValue,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentValue,
    required Function(String) onSelected,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: LanguangeSheet(
        currentValue: currentValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Bahasa Indonesia',
        'subtitle': 'Gunakan Bahasa Indonesia sebagai bahasa utama',
        'value': 'Indonesia',
        'icon': HugeIcons.strokeRoundedTranslation,
      },
      {
        'title': 'English',
        'subtitle': 'Use English as your primary language',
        'value': 'English',
        'icon': HugeIcons.strokeRoundedGlobal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              'Pilih Bahasa',
              style: context.text.titleLarge?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            Text(
              'Pilih bahasa yang paling nyaman untuk Anda gunakan di dalam aplikasi.',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.outline,
              ),
            ),
          ],
        ),
        AppContainer(
          padding: EdgeInsets.zero,
          borderColor: context.colors.outline.withValues(alpha: 0.2),
          child: Column(
            children: options.map((option) {
              final bool isActive = currentValue == option['value'];
              final bool isLast = options.last == option;

              return Column(
                children: [
                  AppTile.modern(
                    icon: option['icon'],
                    title: option['title'],
                    subtitle: option['subtitle'],
                    onTap: () {
                      onSelected(option['value']);
                      Navigator.pop(context);
                    },
                    trailing: isActive
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                            color: context.colors.primary,
                            size: 20,
                          )
                        : null,
                  ),
                  if (!isLast)
                    AppDivider.dashed(
                      indent: 0,
                      endIndent: 0,
                      color: context.colors.outline.withValues(alpha: 0.6),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
