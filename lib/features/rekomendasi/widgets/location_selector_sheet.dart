import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';
import 'package:recommendation_app/features/rekomendasi/provider/recommendation_form_provider.dart';
import 'package:recommendation_app/features/rekomendasi/services/city_search_service.dart';

class LocationSelectorSheet extends StatefulWidget {
  const LocationSelectorSheet({super.key});

  static void show(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    AppBottomSheet.show(
      context: context,
      showHandle: true,
      wrapInScrollView: false,
      height: screenHeight * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const LocationSelectorSheet(),
    );
  }

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CityModel> _cities = CitySearchService.popularCities;
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _cities = CitySearchService.popularCities;
        _isSearching = false;
      });
      return;
    }

    // Instan filter lokal dulu
    final localFiltered = CitySearchService.popularCities.where((c) {
      return c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.province.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _cities = localFiltered;
      _isSearching = query.length >= 3;
    });

    // Debounced search untuk Open-Meteo API jika query >= 3 huruf
    if (query.length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
        final results = await CitySearchService.search(query);
        if (mounted) {
          setState(() {
            _cities = results;
            _isSearching = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecommendationFormProvider>();
    final locationProvider = context.watch<HomeLocationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Judul & Keterangan ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Pilih Lokasi Proteksi UV',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            if (formProvider.isCustomLocation)
              InkWell(
                onTap: () {
                  formProvider.resetToGpsLocation(locationProvider);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedGps01,
                        color: context.colors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pakai GPS',
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.v4,
        Text(
          'Cari kota tujuan untuk menyesuaikan target proteksi sunscreen.',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.outline,
            height: 1.4,
          ),
        ),
        AppSpacing.v16,

        // ── Kolom Pencarian Kota ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppRadius.br16,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.15),
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: context.text.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Cari nama kota atau kabupaten...',
              hintStyle: context.text.bodyMedium?.copyWith(
                color: context.colors.outline,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colors.outline,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : (_isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        AppSpacing.v16,

        // ── Label Daftar Kota ─────────────────────────────────────────
        Text(
          _searchController.text.trim().isEmpty
              ? 'KOTA POPULER DI INDONESIA'
              : 'HASIL PENCARIAN',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.outline,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        AppSpacing.v8,

        // ── List Kota (Scrollable, Mengisi sisa ruang leluasa ke bawah) ─
        Expanded(
          child: _cities.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Kota tidak ditemukan. Coba ketik nama kota lain.',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                  ),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = formProvider.isCustomLocation &&
                        formProvider.customLocationName == city.displayName;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.primary.withValues(alpha: 0.15)
                              : context.colors.outline.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedLocation01,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        city.name,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onSurface,
                        ),
                      ),
                      subtitle: city.province.isNotEmpty
                          ? Text(
                              city.province,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.outline,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: context.colors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        formProvider.setCustomLocation(
                          name: city.displayName,
                          latitude: city.latitude,
                          longitude: city.longitude,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
