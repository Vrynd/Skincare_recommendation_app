import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_tile.dart';
import 'package:recommendation_app/features/auth/models/user_model.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/account/widgets/account_header.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const AppScaffold(
        body: Center(
          child: Text('Data pengguna tidak ditemukan.'),
        ),
      );
    }

    final fullName = user.namaLengkap ?? 'Pengguna';
    final email = user.email ?? '-';
    final initials = _getInitials(fullName);

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // 1. Header
            const AccountHeader(),
            AppSpacing.v24,

            // 2. Profile Card
            AppContainer.bordered(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.br24,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showProfileDetailsBottomSheet(context, user),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    spacing: 16,
                    children: [
                      // Avatar
                      AppContainer(
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(16),
                        color: context.colors.primary.withValues(alpha: 0.1),
                        showBorder: false,
                        showShadow: false,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text(
                            initials,
                            style: context.text.headlineSmall?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              fullName,
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface,
                              ),
                            ),
                            Text(
                              email,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight02,
                        color: context.colors.outline,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppSpacing.v24,

            // 3. Grup 1: Personalisasi
            _buildSectionHeader(context, 'Personalisasi'),
            AppSpacing.v8,
            AppContainer.bordered(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.br24,
              child: Column(
                children: [
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedNotification01,
                    title: 'Notifikasi',
                    value: 'Aktif',
                    onTap: () {},
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedPaintBoard,
                    title: 'Tema',
                    value: 'Terang',
                    onTap: () {},
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedTranslate,
                    title: 'Bahasa',
                    value: 'Indonesia',
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
            AppSpacing.v24,

            // 4. Grup 2: Keamanan
            _buildSectionHeader(context, 'Keamanan'),
            AppSpacing.v8,
            AppContainer.bordered(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.br24,
              child: Column(
                children: [
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedKey01,
                    title: 'Ganti Password',
                    onTap: () {},
                    showDivider: true,
                  ),
                  AppTile.modern(
                    icon: HugeIcons.strokeRoundedShield01,
                    title: 'Autentikasi',
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
            AppSpacing.v24,

            // 5. Logout
            AppContainer.bordered(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.br24,
              child: AppTile.modern(
                icon: HugeIcons.strokeRoundedLogout01,
                title: 'Keluar Sesi',
                isDanger: true,
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: context.text.labelMedium?.copyWith(
          color: context.colors.outline,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 'P';
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _showProfileDetailsBottomSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppContainer(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          color: context.colors.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          showShadow: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Text(
                'Detail Profil',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              
              // Larger initials avatar
              AppContainer(
                width: 72,
                height: 72,
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.1),
                showBorder: false,
                showShadow: false,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Text(
                    _getInitials(user.namaLengkap ?? 'Pengguna'),
                    style: context.text.headlineMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Details list
              AppContainer.bordered(
                padding: EdgeInsets.zero,
                borderRadius: AppRadius.br24,
                child: Column(
                  children: [
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedUser,
                      title: 'Nama Lengkap',
                      value: user.namaLengkap ?? '-',
                      showDivider: true,
                    ),
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedMail01,
                      title: 'Email',
                      value: user.email ?? '-',
                      showDivider: true,
                    ),
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedKey01,
                      title: 'ID Pengguna',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.idUser));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID Pengguna disalin ke papan klip'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.idUser.length > 8
                                ? '${user.idUser.substring(0, 8)}...'
                                : user.idUser,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.outline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCopyLink,
                            color: context.colors.outline,
                            size: 16,
                          ),
                        ],
                      ),
                      showDivider: true,
                    ),
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedUserSharing,
                      title: 'Peran Akun',
                      value: user.role == UserRole.admin ? 'Administrator' : 'Pengguna Standar',
                      showDivider: true,
                    ),
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedShieldUser,
                      title: 'Status Akun',
                      value: user.statusAkun ? 'Aktif' : 'Nonaktif',
                      valueColor: user.statusAkun ? AppColors.success : AppColors.accentRed,
                      showDivider: true,
                    ),
                    AppTile.modern(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      title: 'Tanggal Bergabung',
                      value: _formatIndonesianDate(user.createdAt),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: context.colors.onSurface,
                    foregroundColor: context.colors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.br32,
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    // Konfirmasi Logout dengan Dialog yang indah
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.br24),
          title: const Text('Keluar Sesi'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda saat ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(color: context.colors.outline),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await authProvider.signOut();
    }
  }
}
