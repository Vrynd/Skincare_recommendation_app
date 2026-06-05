import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';

class ThemeSheet extends StatelessWidget {
  final String currentValue;
  final Function(String) onSelected;

  const ThemeSheet({
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
      child: ThemeSheet(
        currentValue: currentValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Terang',
        'subtitle': 'Tampilan aplikasi dengan warna cerah',
        'value': 'Terang',
        'icon': HugeIcons.strokeRoundedSun03,
      },
      {
        'title': 'Gelap',
        'subtitle': 'Tampilan aplikasi dengan warna gelap yang nyaman',
        'value': 'Gelap',
        'icon': HugeIcons.strokeRoundedMoon02,
      },
      {
        'title': 'Ikuti Sistem',
        'subtitle': 'Sesuaikan tema dengan pengaturan perangkat Anda',
        'value': 'Sistem',
        'icon': HugeIcons.strokeRoundedSettings03,
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
              'Mode Tema',
              style: context.text.titleLarge?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            Text(
              'Pilih nuansa visual yang paling sesuai untuk kenyamanan mata dan aktivitas Anda.',
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
