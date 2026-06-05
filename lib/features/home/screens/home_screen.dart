import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_empty_state.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_title.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_category.dart';
import 'package:recommendation_app/features/home/widgets/home_recommendation.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_provider.dart';
import 'package:recommendation_app/features/home/widgets/home_greeting.dart';
import 'package:recommendation_app/features/home/widgets/home_location.dart';
import 'package:recommendation_app/features/home/widgets/home_uv_index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Cleanser';
  final ScrollController _scrollController = ScrollController();
  int _displayLimit = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        final location = context.read<HomeLocationProvider>();
        final recommendation = context.read<RecommendationProvider>();

        // Mendeteksi lokasi & UV Indeks uv
        location.fetchLocation();

        // Pengambilan jumlah kategori
        final userId = auth.currentUser?.idUser;
        if (userId != null) {
          recommendation.fetchCategoryCounts(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkAndLoadMore();
  }

  void _checkAndLoadMore() {
    if (!mounted) return;
    final recommendation = context.read<RecommendationProvider>();
    final filteredCount = recommendation.recommendations.where((item) {
      final itemCat = item.category.toLowerCase();
      final targetCat = _selectedCategory.toLowerCase();
      if (targetCat == 'moisture') {
        return itemCat == 'moisturizer' || itemCat == 'moisture';
      }
      return itemCat == targetCat;
    }).length;

    if (_displayLimit < filteredCount) {
      if (_scrollController.hasClients) {
        final pos = _scrollController.position;
        if (pos.maxScrollExtent == 0 || pos.pixels >= pos.maxScrollExtent - 200) {
          setState(() {
            _displayLimit += 2;
          });
        }
      }
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

  Widget _buildRecommendation(RecommendationProvider recommendation) {
    if (recommendation.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredRecs = recommendation.recommendations.where((item) {
      final itemCat = item.category.toLowerCase();
      final targetCat = _selectedCategory.toLowerCase();
      if (targetCat == 'moisture') {
        return itemCat == 'moisturizer' || itemCat == 'moisture';
      }
      return itemCat == targetCat;
    }).toList();

    if (filteredRecs.isEmpty) {
      return AppEmptyState(
        height: 250,
        icon: HugeIcons.strokeRoundedClock01,
        title: 'Tidak Ada Rekomendasi',
        description:
            'Belum ada riwayat rekomendasi untuk kategori $_selectedCategory',
      );
    }

    final displayedRecs = filteredRecs.take(_displayLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayedRecs.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HomeRecommendation(recommendation: item),
          ),
        ),
        if (_displayLimit < filteredRecs.length)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
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
    final recommendation = context.watch<RecommendationProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadMore();
    });

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 48),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: HomeGreeting(
                greeting: _getGreeting(),
                fullName: user.namaLengkap,
              ),
            ),
            AppSpacing.v24,

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
            AppSpacing.v24,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AppTitleAction.text(
                title: 'Rekomendasi Saya',
                actionText: 'Lihat Semua',
                onPressed: () {},
              ),
            ),
            AppSpacing.v8,

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                spacing: 8,
                children: [
                  HomeCategory(
                    title: 'Cleanser',
                    count: recommendation.categoryCounts['Cleanser'] ?? 0,
                    isSelected: _selectedCategory == 'Cleanser',
                    onTap: () => setState(() {
                      _selectedCategory = 'Cleanser';
                      _displayLimit = 2;
                    }),
                  ),
                  HomeCategory(
                    title: 'Toner',
                    count: recommendation.categoryCounts['Toner'] ?? 0,
                    isSelected: _selectedCategory == 'Toner',
                    onTap: () => setState(() {
                      _selectedCategory = 'Toner';
                      _displayLimit = 2;
                    }),
                  ),
                  HomeCategory(
                    title: 'Serum',
                    count: recommendation.categoryCounts['Serum'] ?? 0,
                    isSelected: _selectedCategory == 'Serum',
                    onTap: () => setState(() {
                      _selectedCategory = 'Serum';
                      _displayLimit = 2;
                    }),
                  ),
                  HomeCategory(
                    title: 'Moisture',
                    count: recommendation.categoryCounts['Moisture'] ?? 0,
                    isSelected: _selectedCategory == 'Moisture',
                    onTap: () => setState(() {
                      _selectedCategory = 'Moisture';
                      _displayLimit = 2;
                    }),
                  ),
                  HomeCategory(
                    title: 'Sunscreen',
                    count: recommendation.categoryCounts['Sunscreen'] ?? 0,
                    isSelected: _selectedCategory == 'Sunscreen',
                    onTap: () => setState(() {
                      _selectedCategory = 'Sunscreen';
                      _displayLimit = 2;
                    }),
                  ),
                ],
              ),
            ),
            AppSpacing.v20,

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: _buildRecommendation(recommendation),
            ),
          ],
        ),
      ),
    );
  }
}
