import 'package:flutter/material.dart';
import 'package:recommendation_app/core/themes/app_colors.dart';

/// Enum representasi kategori risiko Indeks UV berdasarkan standar WHO.
enum UVRiskLevel {
  low(
    min: 0.0,
    max: 2.0,
    name: 'Rendah',
    description: 'Risiko bahaya minimal bagi rata-rata orang.',
    recommendedSpf: 15,
    color: AppColors.accentSage,
  ),
  moderate(
    min: 2.1,
    max: 5.0,
    name: 'Sedang',
    description: 'Risiko bahaya sedang akibat paparan matahari tanpa pelindung.',
    recommendedSpf: 15,
    color: AppColors.accentAmber,
  ),
  high(
    min: 5.1,
    max: 7.0,
    name: 'Tinggi',
    description: 'Risiko bahaya tinggi. Diperlukan perlindungan kulit.',
    recommendedSpf: 30,
    color: AppColors.accentOrange,
  ),
  veryHigh(
    min: 7.1,
    max: 10.0,
    name: 'Sangat Tinggi',
    description: 'Risiko bahaya sangat tinggi. Perlindungan ekstra sangat penting.',
    recommendedSpf: 30,
    color: AppColors.accentRed,
  ),
  extreme(
    min: 10.1,
    max: 100.0,
    name: 'Ekstrem',
    description: 'Risiko bahaya luar biasa tinggi. Hindari terpapar matahari tanpa pelindung lengkap.',
    recommendedSpf: 50,
    color: AppColors.accentLavender,
  );

  final double min;
  final double max;
  final String name;
  final String description;
  final int recommendedSpf;
  final Color color;

  const UVRiskLevel({
    required this.min,
    required this.max,
    required this.name,
    required this.description,
    required this.recommendedSpf,
    required this.color,
  });

  /// Mengambil instansi tingkat risiko secara dinamis berdasarkan nilai Indeks UV aktual
  static UVRiskLevel fromIndex(double index) {
    if (index <= 2.0) return UVRiskLevel.low;
    if (index <= 5.0) return UVRiskLevel.moderate;
    if (index <= 7.0) return UVRiskLevel.high;
    if (index <= 10.0) return UVRiskLevel.veryHigh;
    return UVRiskLevel.extreme;
  }
}
