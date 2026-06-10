import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_search_bar.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/history/presentation/widgets/delete_sheet.dart';
import 'package:recommendation_app/features/history/presentation/widgets/history_stats.dart';
import 'package:recommendation_app/features/history/presentation/widgets/history_tile.dart';
import 'package:recommendation_app/features/history/presentation/widgets/title_date.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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

  void _tapToDelete(String productName) {
    DeleteSheet.show(
      context: context,
      title: 'Hapus Riwayat',
      description:
          'Apakah Anda yakin ingin menghapus produk ini dari riwayat rekomendasi Anda?',
      confirmText: 'Ya, Hapus',
      isDanger: true,
      icon: HugeIcons.strokeRoundedDelete02,
      onConfirm: () {
        debugPrint('$productName dihapus');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(
        title: 'Riwayat Rekomendasi',
        initialName: 'Rv',
        scrollOffset: _scrollOffset,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverSearchHeaderDelegate(
              scrollOffset: _scrollOffset,
              builder: (context, isPinned) {
                return Container(
                  decoration: BoxDecoration(
                    color: context.colors.lightBackground,
                    boxShadow: isPinned
                        ? [
                            BoxShadow(
                              color: context.colors.shadow.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: AppSearchBar(
                    controller: _searchController,
                    onFilterTap: () {
                      debugPrint('Filter diketuk: ${_searchController.text}');
                    },
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HistoryStats(totalHistory: '48', averageMatch: '92%'),
                AppSpacing.v24,

                TitleDate(
                  title: 'Senin, 09:00',
                  padding: const EdgeInsets.only(bottom: 12),
                ),
                HistoryTile(
                  date: '20',
                  month: 'Jun',
                  label: 'Skintific',
                  title: '5X Ceramide Serum Sunscreen SPF50',
                  onTap: () {},
                  onTapMore: () => _tapToDelete('Skintific'),
                ),
                AppSpacing.v24,
                TitleDate(
                  title: 'Selasa, 12:00',
                  padding: const EdgeInsets.only(bottom: 12),
                ),
                HistoryTile(
                  date: '25',
                  month: 'Jun',
                  label: 'Azarine',
                  title: 'Hydrasoothe Sunscreen Gel SPF45',
                  onTap: () {},
                  onTapMore: () => _tapToDelete('Azarine'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double scrollOffset;
  final Widget Function(BuildContext context, bool isPinned) builder;

  _SliverSearchHeaderDelegate({
    required this.scrollOffset,
    required this.builder,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = scrollOffset > 0.0;
    return builder(context, isPinned);
  }

  @override
  double get maxExtent => 78.0;

  @override
  double get minExtent => 78.0;

  @override
  bool shouldRebuild(covariant _SliverSearchHeaderDelegate oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset;
  }
}
