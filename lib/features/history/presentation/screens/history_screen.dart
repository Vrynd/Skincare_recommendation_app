import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_bar.dart';
import 'package:recommendation_app/core/widgets/app_search_bar.dart';
import 'package:recommendation_app/core/widgets/app_scaffold.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_empty_state.dart';
import 'package:recommendation_app/features/auth/provider/auth_provider.dart';
import 'package:recommendation_app/features/history/models/history_item.dart';
import 'package:recommendation_app/features/history/provider/history_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<HistoryProvider>().loadHistory(auth.currentUser!.idUser);
      }
    });
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

  void _tapToDelete(HistoryItem item) {
    DeleteSheet.show(
      context: context,
      title: 'Hapus Riwayat',
      description:
          'Apakah Anda yakin ingin menghapus "${item.productName}" dari riwayat rekomendasi Anda?',
      confirmText: 'Ya, Hapus',
      isDanger: true,
      icon: HugeIcons.strokeRoundedDelete02,
      onConfirm: () async {
        final success = await context.read<HistoryProvider>().deleteSession(
          item.sessionId,
        );
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Riwayat berhasil dihapus')),
          );
        }
      },
    );
  }

  List<Widget> _buildHistoryList(
    BuildContext context,
    HistoryProvider provider,
  ) {
    final children = <Widget>[];
    // Stats
    children.add(
      HistoryStats(
        totalHistory: provider.totalHistory,
        averageMatch: provider.averageMatch,
      ),
    );
    children.add(AppSpacing.v24);

    if (provider.isLoading && provider.historyItems.isEmpty) {
      children.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (provider.historyItems.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: AppEmptyState(
            icon: HugeIcons.strokeRoundedClock01,
            title: 'Belum Ada Riwayat',
            description: provider.searchQuery.isNotEmpty
                ? 'Tidak menemukan riwayat yang cocok dengan kata kunci.'
                : 'Riwayat pencarian rekomendasi sunscreen Anda akan muncul di sini.',
          ),
        ),
      );
    } else {
      provider.groupedHistory.forEach((monthYear, items) {
        // Month group header
        children.add(
          TitleDate(
            title: monthYear,
            padding: const EdgeInsets.only(top: 12, bottom: 12),
          ),
        );

        // Group items
        for (final item in items) {
          children.add(
            HistoryTile(
              time: item.formattedTime,
              label: item.brandName,
              title: item.productName,
              onTap: () {},
              onTapMore: () => _tapToDelete(item),
            ),
          );
          children.add(AppSpacing.v8);
        }
        children.add(AppSpacing.v8);
      });
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return AppScaffold(
      backgroundColor: context.colors.lightBackground,
      appBar: AppAppBar(
        title: 'Riwayat Rekomendasi',
        scrollOffset: _scrollOffset,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthProvider>();
          if (auth.currentUser != null) {
            await context.read<HistoryProvider>().loadHistory(
              auth.currentUser!.idUser,
            );
          }
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
          children: [
            AppSearchBar(
              controller: _searchController,
              onChanged: (val) {
                historyProvider.setSearchQuery(val);
              },
              onFilterTap: () {
                debugPrint('Filter diketuk: ${_searchController.text}');
              },
            ),
            AppSpacing.v12,
            ..._buildHistoryList(context, historyProvider),
          ],
        ),
      ),
    );
  }
}
