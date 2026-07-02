import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_container.dart';
import 'package:recommendation_app/core/widgets/app_divider.dart';
import 'package:recommendation_app/core/widgets/app_radius.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/core/widgets/app_bottom_sheet.dart';

class ProductRecommendationCard extends StatefulWidget {
  final String brandName;
  final String productName;
  final String bpomNumber;
  final String category;
  final String usageTime;
  final double matchScore;
  final String recommendationCategory;
  final double? skinTypeScore;
  final double? activityScore;
  final double? skinConcernScore;
  final double? textureScore;
  final double? finishScore;
  final double? penalty;

  const ProductRecommendationCard({
    super.key,
    required this.brandName,
    required this.productName,
    required this.bpomNumber,
    required this.category,
    required this.usageTime,
    required this.matchScore,
    required this.recommendationCategory,
    this.skinTypeScore,
    this.activityScore,
    this.skinConcernScore,
    this.textureScore,
    this.finishScore,
    this.penalty,
  });

  @override
  State<ProductRecommendationCard> createState() =>
      _ProductRecommendationCardState();
}

class _ProductRecommendationCardState extends State<ProductRecommendationCard> {
  Color _getBrandColor(String brand) {
    const accents = [
      AppColors.accentPurple,
      AppColors.accentOrange,
      AppColors.accentPink,
      AppColors.accentIndigo,
      AppColors.accentBlue,
      AppColors.accentTeal,
      AppColors.accentAmber,
      AppColors.accentRed,
      AppColors.accentLavender,
      AppColors.accentSage,
      AppColors.accentCyan,
    ];
    int hash = 5381;
    for (final c in brand.toLowerCase().codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return accents[hash % accents.length];
  }

  String get _recommendationCategoryLabel {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => 'Sangat Direkomendasikan',
      'recommended' => 'Direkomendasikan',
      'fairly_suitable' => 'Cukup Sesuai',
      _ => 'Sesuai',
    };
  }

  Color get _recommendationCategoryColor {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => AppColors.success,
      'recommended' => AppColors.accentBlue,
      'fairly_suitable' => AppColors.accentOrange,
      _ => AppColors.info,
    };
  }

  int get _starCount {
    return switch (widget.recommendationCategory.toLowerCase()) {
      'highly_recommended' => 4,
      'recommended' => 3,
      'fairly_suitable' => 2,
      _ => 1,
    };
  }

  Widget _buildStars(BuildContext context) {
    final filled = _starCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: List.generate(4, (index) {
        final isFilled = index < filled;
        return Icon(
          Icons.star_rounded,
          color: isFilled ? AppColors.accentAmber : context.colors.onSurfaceVariant.withValues(alpha: 0.2),
          size: 18,
        );
      }),
    );
  }

  String _formatUsageTime(String time) {
    return switch (time.toLowerCase()) {
      'morning_day' => 'Pagi / Siang',
      'morning_and_night' => 'Pagi & Malam',
      'night' => 'Malam Hari',
      _ => time.replaceAll('_', ' ').split(' ').map((w) {
          if (w.isEmpty) return '';
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        }).join(' '),
    };
  }

  void _showBreakdownSheet(BuildContext context) {
    final brandColor = _getBrandColor(widget.brandName);

    final skinType = widget.skinTypeScore ?? 25.0;
    final activity = widget.activityScore ?? 25.0;
    final concern = widget.skinConcernScore ?? 20.0;
    final texture = widget.textureScore ?? 15.0;
    final finish = widget.finishScore ?? 15.0;
    final penaltyVal = widget.penalty ?? 0.0;
    final finalScore = widget.matchScore;

    // Hitung kontribusi setiap kriteria dari total skor akhir (%)
    // contoh: total=80, skinType=20 → kontribusi = (20/80)*100 = 25%
    double contrib(double score) =>
        finalScore > 0 ? (score / finalScore) * 100 : 0;

    final criteria = [
      (
        icon: HugeIcons.strokeRoundedDroplet,
        color: AppColors.accentPurple,
        label: 'Tipe Kulit',
        score: skinType,
        pct: contrib(skinType),
      ),
      (
        icon: HugeIcons.strokeRoundedActivity01,
        color: AppColors.accentBlue,
        label: 'Aktivitas Harian',
        score: activity,
        pct: contrib(activity),
      ),
      (
        icon: HugeIcons.strokeRoundedAlert01,
        color: AppColors.accentOrange,
        label: 'Masalah Kulit',
        score: concern,
        pct: contrib(concern),
      ),
      (
        icon: HugeIcons.strokeRoundedSparkles,
        color: AppColors.accentTeal,
        label: 'Tekstur',
        score: texture,
        pct: contrib(texture),
      ),
      (
        icon: HugeIcons.strokeRoundedCircle,
        color: AppColors.accentPink,
        label: 'Hasil Akhir',
        score: finish,
        pct: contrib(finish),
      ),
    ];

    AppBottomSheet.show(
      context: context,
      showHandle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────
          Text(
            widget.brandName.toUpperCase(),
            style: context.text.labelSmall?.copyWith(
              color: brandColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          AppSpacing.v4,
          Text(
            widget.productName,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.v20,

          // ── Total Skor Card ─────────────────────────────
          AppContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: AppRadius.br24,
            color: brandColor,
            opacity: 0.08,
            showBorder: false,
            showShadow: false,
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: finalScore / 100,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            context.colors.outline.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${finalScore.toInt()}',
                          style: context.text.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                            height: 1,
                          ),
                        ),
                        Text(
                          '%',
                          style: context.text.labelSmall?.copyWith(
                            color: brandColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.h20,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Kesesuaian',
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      AppSpacing.v4,
                      Text(
                        'Rincian di bawah menunjukkan berapa persen setiap kriteria berkontribusi pada skor ${finalScore.toInt()}% ini.',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.outline,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v20,

          // ── Mini stacked bar (visual ikhtisar) ─────────
          ClipRRect(
            borderRadius: AppRadius.br8,
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (final c in criteria)
                    Flexible(
                      flex: (c.pct * 10).toInt().clamp(1, 1000),
                      child: Container(color: c.color),
                    ),
                  if (penaltyVal > 0)
                    Flexible(
                      flex: ((penaltyVal / finalScore) * 100 * 10)
                          .toInt()
                          .clamp(1, 1000),
                      child: Container(
                          color: AppColors.accentRed.withValues(alpha: 0.5)),
                    ),
                  Flexible(
                    flex: ((100 - finalScore) * 10).toInt().clamp(1, 1000),
                    child: Container(
                        color: context.colors.outline.withValues(alpha: 0.08)),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.v20,

          // ── Label Seksi ─────────────────────────────────
          Text(
            'KONTRIBUSI PER KRITERIA',
            style: context.text.labelSmall?.copyWith(
              color: context.colors.outline,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          AppSpacing.v12,

          // ── Daftar Kriteria ──────────────────────────────
          for (int i = 0; i < criteria.length; i++) ...[
            _buildBreakdownItem(
              context: context,
              icon: criteria[i].icon,
              iconColor: criteria[i].color,
              title: criteria[i].label,
              rawScore: criteria[i].score,
              contributionPct: criteria[i].pct,
              totalScore: finalScore,
            ),
            if (i < criteria.length - 1)
              const AppDivider.dashed(
                  indent: 0, endIndent: 0, thickness: 0.6),
          ],

          // ── Penalti ──────────────────────────────────────
          if (penaltyVal > 0) ...[
            const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 0.6),
            _buildBreakdownItem(
              context: context,
              icon: HugeIcons.strokeRoundedAlertCircle,
              iconColor: AppColors.accentRed,
              title: 'Pengurangan / Penalti',
              rawScore: -penaltyVal,
              contributionPct: (penaltyVal / finalScore) * 100,
              totalScore: finalScore,
              isPenalty: true,
            ),
          ],

          AppSpacing.v16,
          const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 0.8),
          AppSpacing.v12,

          // ── Info Tambahan ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waktu Penggunaan',
                style: context.text.labelLarge?.copyWith(
                    color: context.colors.outline),
              ),
              Text(
                _formatUsageTime(widget.usageTime),
                style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface),
              ),
            ],
          ),
          AppSpacing.v8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor BPOM',
                style: context.text.labelLarge?.copyWith(
                    color: context.colors.outline),
              ),
              Text(
                widget.bpomNumber,
                style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface),
              ),
            ],
          ),
          AppSpacing.v24,

          // ── Tutup ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor:
                    context.colors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.br16),
              ),
              child: Text(
                'Tutup Detail',
                style: context.text.labelLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required BuildContext context,
    required dynamic icon,
    required Color iconColor,
    required String title,
    required double rawScore,
    required double contributionPct,
    required double totalScore,
    bool isPenalty = false,
  }) {
    // Persentase kontribusi dari total akhir (mis. 20/80 * 100 = 25%)
    final displayPct = contributionPct.abs();
    // Bar fill: seberapa penuh bar relatif terhadap max kemungkinan kriteria ini
    // Tampilkan bar berdasarkan pct kontribusi dari 100% total
    final barFill = (displayPct / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Icon bulat
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: HugeIcon(icon: icon, color: iconColor, size: 18),
          ),
          AppSpacing.h12,
          // Label + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      isPenalty
                          ? '-${displayPct.toStringAsFixed(1)}%'
                          : '${displayPct.toStringAsFixed(1)}%',
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPenalty
                            ? AppColors.accentRed
                            : iconColor,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                ClipRRect(
                  borderRadius: AppRadius.br8,
                  child: LinearProgressIndicator(
                    value: barFill,
                    minHeight: 5,
                    backgroundColor:
                        context.colors.outline.withValues(alpha: 0.08),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                            isPenalty
                                ? AppColors.accentRed.withValues(alpha: 0.6)
                                : iconColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor(widget.brandName);

    return AppContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.br24,
      showShadow: false,
      child: InkWell(
        onTap: () => _showBreakdownSheet(context),
        borderRadius: AppRadius.br24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Body: brand, nama produk, ilustrasi kategori ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.brandName.toUpperCase(),
                          style: context.text.labelSmall?.copyWith(
                            color: brandColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        AppSpacing.v4,
                        Text(
                          widget.productName,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h16,
                  // Nilai skor kecocokan (e.g. 90%)
                  AppContainer(
                    width: 52,
                    height: 52,
                    color: brandColor,
                    opacity: 0.08,
                    showBorder: false,
                    showShadow: false,
                    borderRadius: BorderRadius.circular(16),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${widget.matchScore.toInt()}',
                            style: context.text.titleLarge?.copyWith(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: '%',
                            style: context.text.labelSmall?.copyWith(
                              color: brandColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider edge-to-edge: diletakkan di luar Padding, bukan di dalamnya
            const AppDivider.dashed(indent: 0, endIndent: 0, thickness: 1),

            // ── Footer: kategori (warna brand) + tingkat kecocokan ────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kategori rekomendasi
                  AppContainer(
                    width: null,
                    showBorder: false,
                    showShadow: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: _recommendationCategoryColor,
                    opacity: 0.12,
                    borderRadius: BorderRadius.circular(6),
                    child: Text(
                      _recommendationCategoryLabel.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        color: _recommendationCategoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
 
                  // Rating bintang
                  _buildStars(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
