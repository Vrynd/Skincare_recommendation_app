import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_title.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_location.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_index.dart';
import 'package:recommendation_app/features/home/widgets/home_recommendation_card.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  int _displayedCount = 8;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeLocationProvider>().fetchLocation();
        context.read<RecommendationProvider>().fetchActiveSunscreens();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset <= 40.0) {
        setState(() {
          _scrollOffset = offset;
        });
      } else if (_scrollOffset < 40.0) {
        setState(() {
          _scrollOffset = 40.0;
        });
      }

      // Lazy loading trigger saat scroll mendekati batas bawah
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    }
  }

  void _loadMoreProducts() {
    final recommendation = context.read<RecommendationProvider>();
    final location = context.read<HomeLocationProvider>();
    final allProducts = recommendation.getSunscreensForUv(location.uvIndex);

    if (!_isLoadingMore && _displayedCount < allProducts.length) {
      setState(() {
        _isLoadingMore = true;
      });

      // Micro-delay agar animasi indikator lazy loading berjalan mulus
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            _displayedCount = (_displayedCount + 4).clamp(0, allProducts.length);
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Selamat pagi 👋';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat siang 🌤️';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore ⛅';
    } else {
      return 'Selamat malam 🌙';
    }
  }

  Widget _buildProductGrid(
    List<Map<String, dynamic>> products,
    bool isLoading,
  ) {
    if (isLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleProducts = products.take(_displayedCount).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              return HomeRecommendationCard(product: visibleProducts[index]);
            },
          ),
        ),
        if (_isLoadingMore) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final location = context.watch<HomeLocationProvider>();
    final recommendation = context.watch<RecommendationProvider>();

    // Ambil daftar sunscreen yang diprioritaskan sesuai UV Indeks saat ini
    final allSunscreens = recommendation.getSunscreensForUv(location.uvIndex);

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(title: _getGreeting(), scrollOffset: _scrollOffset),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 124),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppContainer(
                color: context.colors.primaryContainer,
                borderRadius: AppRadius.br32,
                padding: EdgeInsets.zero,
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [const HomeLocation(), const HomeUVIndex()],
                ),
              ),
            ),
            AppSpacing.v32,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppTitleAction.none(
                title: 'Daftar Produk',
                subtitle: 'Koleksi sunscreen pilihan untuk perlindungan kulit harian Anda',
              ),
            ),
            AppSpacing.v16,

            _buildProductGrid(
              allSunscreens,
              recommendation.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
