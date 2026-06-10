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

  Widget _buildHorizontalSunscreens(
    List<Map<String, dynamic>> products,
    bool isLoading,
  ) {
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (context, index) => AppSpacing.h16,
        itemBuilder: (context, index) {
          return HomeRecommendationCard(product: products[index], width: 250);
        },
      ),
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

    // Ambil 3 rekomendasi sunscreen acak sesuai UV Indeks saat ini
    final randomSunscreens = recommendation.getRandomSunscreensForUv(
      location.uvIndex,
      count: 3,
    );

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(title: _getGreeting(), scrollOffset: _scrollOffset),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 48),
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
                title: 'Rekomendasi Hari Ini',
                subtitle: 'Sunscreen pelindung terbaik untuk cuaca saat ini',
              ),
            ),
            AppSpacing.v16,

            _buildHorizontalSunscreens(
              randomSunscreens,
              recommendation.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
