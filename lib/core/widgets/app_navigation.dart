import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';

class AppNavigation extends StatelessWidget implements PreferredSizeWidget {
  /// Judul halaman. Jika null, akan ditentukan secara otomatis secara dinamis.
  final String? title;

  /// Widget kustom untuk aksi sisi kanan.
  /// Jika null, secara default akan menampilkan kontainer sirkular kosong untuk simetri visual.
  final Widget? rightAction;

  /// Callback kustom saat tombol kembali ditekan.
  /// Jika null, aksi bawaan adalah Navigator.maybePop(context).
  final VoidCallback? onBackTap;

  /// Apakah tombol kembali harus ditampilkan. Default bernilai true.
  final bool showBackButton;

  /// Tinggi dari bar navigasi. Default bernilai 56.0.
  final double height;

  /// Ukuran diameter tombol sirkular (kiri dan kanan). Default bernilai 48.0.
  final double buttonSize;

  /// Apakah tombol navigasi menggunakan gaya transparan/seamless tanpa border. Default bernilai false.
  final bool seamless;

  const AppNavigation({
    super.key,
    this.title,
    this.rightAction,
    this.onBackTap,
    this.showBackButton = true,
    this.height = 56.0,
    this.buttonSize = 48.0,
    this.seamless = false,
  });

  @override
  Widget build(BuildContext context) {
    final derivedTitle = title ?? _deriveTitle(context);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (showBackButton)
            _NavigationCircleButton(
              size: buttonSize,
              seamless: seamless,
              onTap: onBackTap ?? () => _handleBackPress(context),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft02,
                color: context.colors.onSurface,
                size: 24,
              ),
            )
          else
            SizedBox(width: buttonSize, height: buttonSize),
          const SizedBox(width: 12),
          Expanded(child: _NavigationTitle(title: derivedTitle)),
          const SizedBox(width: 12),
          rightAction ??
              _NavigationCircleButton(size: buttonSize, seamless: seamless),
        ],
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      Navigator.maybePop(context);
    }
  }

  String _deriveTitle(BuildContext context) {
    // 1. Coba dapatkan dari GoRouterState
    try {
      final state = GoRouterState.of(context);
      final name = state.name;
      if (name != null && name.isNotEmpty) {
        return _formatRouteName(name);
      }
      final path = state.matchedLocation;
      if (path.isNotEmpty && path != '/') {
        final lastSegment = path
            .split('/')
            .lastWhere((e) => e.isNotEmpty, orElse: () => '');
        if (lastSegment.isNotEmpty) {
          return _formatRouteName(lastSegment);
        }
      }
    } catch (_) {
      // GoRouter state tidak ditemukan / tidak aktif di konteks ini
    }

    // 2. Coba dapatkan dari nama rute ModalRoute
    final route = ModalRoute.of(context);
    final routeName = route?.settings.name;
    if (routeName != null && routeName.isNotEmpty && routeName != '/') {
      final cleanName = routeName.startsWith('/')
          ? routeName.substring(1)
          : routeName;
      final lastSegment = cleanName
          .split('/')
          .lastWhere((e) => e.isNotEmpty, orElse: () => '');
      if (lastSegment.isNotEmpty) {
        return _formatRouteName(lastSegment);
      }
      return _formatRouteName(cleanName);
    }

    // 3. Fallback: Ekstraksi dinamis dari tipe kelas widget halaman terdekat (Screen / Page)
    return _deriveTitleFromAncestors(context);
  }

  String _deriveTitleFromAncestors(BuildContext context) {
    String? screenName;
    context.visitAncestorElements((element) {
      final widgetName = element.widget.runtimeType.toString();
      if (widgetName.endsWith('Screen') || widgetName.endsWith('Page')) {
        screenName = widgetName;
        return false; // Menghentikan pencarian ke atas
      }
      return true; // Lanjutkan pencarian ke atas
    });

    if (screenName != null) {
      var name = screenName!;
      if (name.endsWith('Screen')) {
        name = name.substring(0, name.length - 6);
      } else if (name.endsWith('Page')) {
        name = name.substring(0, name.length - 4);
      }
      return _formatRouteName(name);
    }

    return 'Halaman';
  }

  String _formatRouteName(String name) {
    // 1. Kamus penerjemahan judul halaman ke Bahasa Indonesia
    final normalized = name.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
    const translations = {
      'createrecommendation': 'Buat Rekomendasi',
      'home': 'Beranda',
      'login': 'Masuk',
      'register': 'Daftar',
      'forgotpassword': 'Lupa Kata Sandi',
      'navigation': 'Navigasi',
      'history': 'Riwayat',
      'analytics': 'Statistik',
    };

    if (translations.containsKey(normalized)) {
      return translations[normalized]!;
    }

    // 2. Pemisahan berdasarkan camelCase, strip, atau underscore sebagai fallback
    final words = name
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(RegExp(r'(?=[A-Z])|\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return name;

    return words
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _NavigationCircleButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final double size;
  final bool seamless;

  const _NavigationCircleButton({
    this.child,
    this.onTap,
    required this.size,
    this.seamless = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasTap = onTap != null;

    return AppContainer(
      width: size,
      height: size,
      shape: BoxShape.circle,
      padding: EdgeInsets.zero,
      color: seamless
          ? Colors.transparent
          : context.colors.surfaceContainerLowest,
      borderColor: context.colors.outline.withValues(alpha: 0.12),
      showBorder: !seamless,
      showShadow: false,
      clipBehavior: Clip.antiAlias,
      child: hasTap
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Center(child: child),
              ),
            )
          : child != null
          ? Center(child: child)
          : null,
    );
  }
}

class _NavigationTitle extends StatelessWidget {
  final String title;

  const _NavigationTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.colors.onSurface,
      ),
    );
  }
}
