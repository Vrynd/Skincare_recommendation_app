import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_avatar.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? initialName;
  final double scrollOffset;
  final double toolbarHeight;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final Widget? leading;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    required this.title,
    this.initialName,
    this.scrollOffset = 0.0,
    this.toolbarHeight = 65.0,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.leading,
    this.leadingWidth,
    this.automaticallyImplyLeading = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return AppBar(
      leading: leading,
      leadingWidth: leadingWidth,
      automaticallyImplyLeading: automaticallyImplyLeading,
      toolbarHeight: toolbarHeight,
      elevation: (scrollOffset / 40.0).clamp(0.0, 1.0) * 1.5,
      scrolledUnderElevation: 0,
      shadowColor: context.colors.shadow.withValues(
        alpha: (scrollOffset / 40.0).clamp(0.0, 1.0) * 0.12,
      ),
      backgroundColor: context.colors.lightBackground,
      title: Text(
        title,
        style: context.text.headlineMedium?.copyWith(
          color: context.colors.onSurface,
        ),
      ),
      actions: actions ?? [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: AppContainer(
            opacity: 0.8,
            width: null,
            height: 50,
            showShadow: false,
            borderRadius: AppRadius.br32,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onNotificationPressed,
                    borderRadius: BorderRadius.circular(100),
                    child: AppContainer(
                      color: Colors.transparent,
                      showBorder: false,
                      showShadow: false,
                      width: 46,
                      height: 46,
                      padding: EdgeInsets.zero,
                      shape: BoxShape.circle,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedNotificationBubble,
                          size: 22,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                AppAvatar(
                  fullName: user?.namaLengkap,
                  initialName: initialName,
                  size: 46,
                  onTap: onProfilePressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
