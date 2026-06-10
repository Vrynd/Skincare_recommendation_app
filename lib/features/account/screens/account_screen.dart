import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/account/widgets/confirm_sheet.dart';
import 'package:recommendation_app/features/account/widgets/group_title.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';
import 'package:recommendation_app/features/account/widgets/account_profile.dart';
import 'package:recommendation_app/features/account/widgets/languange_sheet.dart';
import 'package:recommendation_app/features/account/widgets/notification_sheet.dart';
import 'package:recommendation_app/features/account/widgets/theme_sheet.dart';
import 'package:recommendation_app/features/navigations/provider/navigation_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _notificationStatus = 'Aktif';
  String _language = 'Indonesia';
  String _themeMode = 'Terang';

  void _goToChangePassword() {}

  void _goToAuthentication() async {}

  void _goToPrivacy() async {}

  void _tapToNotification() async {
    NotificationSheet.show(
      context: context,
      currentValue: _notificationStatus,
      onSelected: (value) {
        setState(() {
          _notificationStatus = value;
        });
      },
    );
  }

  void _tapToLanguage() async {
    LanguangeSheet.show(
      context: context,
      currentValue: _language,
      onSelected: (value) {
        setState(() {
          _language = value;
        });
      },
    );
  }

  void _tapToTheme() async {
    ThemeSheet.show(
      context: context,
      currentValue: _themeMode,
      onSelected: (value) {
        setState(() {
          _themeMode = value;
        });
      },
    );
  }

  void _tapToLogout() async {
    bool confirmed = false;
    await ConfirmSheet.show(
      context: context,
      title: 'Keluar Akun',
      description:
          'Apakah Anda yakin ingin keluar dari akun Alexandria? Anda perlu masuk kembali nanti.',
      confirmText: 'Ya, Keluar',
      isDanger: true,
      icon: HugeIcons.strokeRoundedLogout01,
      onConfirm: () {
        confirmed = true;
      },
    );

    if (confirmed) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        final nav = context.read<NavigationProvider>();
        nav.changeIndex(0);
        auth.signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }
    final fullName = user.namaLengkap ?? 'Pengguna';
    final email = user.email ?? 'email@domain.com';

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(
        title: 'Akun Saya',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            AccountProfile(
              name: fullName,
              email: email,
              avatarUrl: user.fotoProfile,
              isOnline: true,
              accountStatus: user.statusAkun == true ? 'Aktif' : 'Nonaktif',
              // onTap: () => _showProfileDetail(),
            ),
            AppSpacing.v20,

            const GroupTitle(title: 'Personalisasi'),
            AppContainer(
              padding: EdgeInsets.zero,
              showShadow: false,
              opacity: 0.8,
              child: Column(
                children: [
                  AppTile.modern(
                    icon: _notificationStatus == 'Aktif'
                        ? HugeIcons.strokeRoundedNotification01
                        : HugeIcons.strokeRoundedNotificationOff01,
                    iconColor: AppColors.accentAmber,
                    title: 'Notifikasi',
                    value: _notificationStatus,
                    onTap: () => _tapToNotification(),
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: _language == 'Indonesia'
                        ? HugeIcons.strokeRoundedTranslation
                        : HugeIcons.strokeRoundedGlobal,
                    iconColor: AppColors.accentBlue,
                    title: 'Bahasa',
                    value: _language,
                    onTap: () => _tapToLanguage(),
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: _themeMode == 'Terang'
                        ? HugeIcons.strokeRoundedSun03
                        : _themeMode == 'Gelap'
                        ? HugeIcons.strokeRoundedMoon02
                        : HugeIcons.strokeRoundedSettings03,
                    iconColor: AppColors.accentPink,
                    title: 'Mode Tema',
                    value: _themeMode,
                    onTap: () => _tapToTheme(),
                  ),
                ],
              ),
            ),
            AppSpacing.v20,

            const GroupTitle(title: 'Privasi & Keamanan'),
            AppContainer(
              showShadow: false,
              opacity: 0.8,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedKey01,
                    iconColor: AppColors.accentTeal,
                    title: 'Ganti Kata Sandi',
                    onTap: () => _goToChangePassword(),
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedUserIdVerification,
                    iconColor: AppColors.accentLavender,
                    title: 'Autentikasi Akun',
                    onTap: () => _goToAuthentication(),
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedSecurityCheck,
                    iconColor: AppColors.accentIndigo,
                    title: 'Privasi & Keamanan',
                    onTap: () => _goToPrivacy(),
                  ),
                ],
              ),
            ),
            AppSpacing.v20,

            AppContainer(
              showShadow: false,
              opacity: 0.8,
              padding: EdgeInsets.zero,
              child: AppTile.modern(
                icon: HugeIcons.strokeRoundedLogout01,
                title: 'Keluar',
                isDanger: true,
                onTap: () => _tapToLogout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
