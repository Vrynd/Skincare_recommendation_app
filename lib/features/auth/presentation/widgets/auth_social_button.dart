import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/widgets/app_button.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';

class AuthSocialButton extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  const AuthSocialButton({super.key, this.onGoogleTap, this.onAppleTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> socialProviders = [
      {
        'title': 'Google',
        'icon': HugeIcons.strokeRoundedGoogle,
        'onTap': onGoogleTap,
        'iconColor': Colors.redAccent,
      },
      {
        'title': 'Apple',
        'icon': HugeIcons.strokeRoundedApple,
        'onTap': onAppleTap,
        'iconColor': null,
      },
    ];

    // 2. Petakan list data menjadi baris widget secara dinamis
    return Row(
      children: socialProviders.map((provider) {
        final isLast = socialProviders.last == provider;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0.0 : 16.0),
            child: AppButton.outline(
              borderRadius: AppRadius.br32,
              icon: provider['icon'],
              title: provider['title'],
              onTap: provider['onTap'],
              iconColor: provider['iconColor'],
            ),
          ),
        );
      }).toList(),
    );
  }
}
