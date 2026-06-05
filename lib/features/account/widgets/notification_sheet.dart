import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';

class NotificationSheet extends StatelessWidget {
  final String currentValue;
  final Function(String) onSelected;

  const NotificationSheet({
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
      child: NotificationSheet(
        currentValue: currentValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        'title': 'Aktif',
        'subtitle': 'Terima semua notifikasi promo dan transaksi',
        'value': 'Aktif',
        'icon': HugeIcons.strokeRoundedNotification01,
      },
      {
        'title': 'Nonaktif',
        'subtitle': 'Matikan semua notifikasi aplikasi',
        'value': 'Nonaktif',
        'icon': HugeIcons.strokeRoundedNotificationOff01,
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
              'Pengaturan Notifikasi',
              style: context.text.titleLarge?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            Text(
              'Pilih jenis notifikasi yang ingin Anda terima untuk pengalaman terbaik.',
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
