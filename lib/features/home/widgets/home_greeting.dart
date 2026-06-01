import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';

class HomeGreeting extends StatelessWidget {
  final String greeting;
  final String? fullName;

  const HomeGreeting({super.key, required this.greeting, this.fullName});

  @override
  Widget build(BuildContext context) {
    final nameToDisplay = _getDisplayName(fullName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _GreetingText(greeting: greeting, displayName: nameToDisplay),
        ),
        const SizedBox(width: 16),
        _GreetingAvatar(name: nameToDisplay),
      ],
    );
  }

  String _getDisplayName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Pengguna';
    }
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return parts[0];
  }
}

class _GreetingText extends StatelessWidget {
  final String greeting;
  final String displayName;

  const _GreetingText({required this.greeting, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          displayName,
          style: context.text.headlineMedium?.copyWith(
            color: context.colors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _GreetingAvatar extends StatelessWidget {
  final String name;

  const _GreetingAvatar({required this.name});

  static const List<Color> _avatarColors = [
    AppColors.accentPurple,
    AppColors.accentOrange,
    AppColors.accentPink,
    AppColors.accentIndigo,
    AppColors.accentBlue,
    AppColors.accentTeal,
    AppColors.accentAmber,
    AppColors.accentRed,
    AppColors.accentLavender,
    AppColors.accentSage,
    AppColors.accentCyan,
  ];

  Color _getAvatarColor(String name) {
    if (name.trim().isEmpty) return _avatarColors[0];
    final hash = name.hashCode.abs();
    return _avatarColors[hash % _avatarColors.length];
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'P';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(name);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColor,
        border: Border.all(color: context.colors.onPrimary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: context.text.titleLarge?.copyWith(
            color: context.colors.onPrimary,
          ),
        ),
      ),
    );
  }
}
