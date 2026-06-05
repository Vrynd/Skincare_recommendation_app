import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';

class AccountProfile extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String accountStatus;
  final bool isOnline;
  final VoidCallback? onTap;

  const AccountProfile({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.accountStatus,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppContainer(
        borderRadius: AppRadius.br24,
        opacity: 0.8,
        showShadow: false,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfileInfo(
              name: name,
              email: email,
              avatarUrl: avatarUrl,
              isOnline: isOnline,
              onTap: onTap,
            ),
            const AppDivider.dashed(indent: 0),
            _StatusSection(accountStatus: accountStatus),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;
  final VoidCallback? onTap;

  const _ProfileInfo({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AppAvatar(
          //   imageUrl: avatarUrl,
          //   name: name,
          //   isOnline: isOnline,
          //   borderColor: context.colors.tertiary.withValues(alpha: .2),
          //   size: 56,
          // ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Text(
                  name,
                  style: context.text.titleLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  email,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowUpRight01,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  final String accountStatus;

  const _StatusSection({required this.accountStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status Akun',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              accountStatus.toUpperCase(),
              style: context.text.labelSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
