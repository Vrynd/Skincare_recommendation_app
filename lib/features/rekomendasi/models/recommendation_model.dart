// Model data untuk menampung riwayat rekomendasi skincare milik pengguna.
class RecommendationModel {
  final String resultId;
  final String sessionId;
  final String? recommendationCode;
  final String productName;
  final String brandName;
  final String category;
  final DateTime createdAt;

  const RecommendationModel({
    required this.resultId,
    required this.sessionId,
    this.recommendationCode,
    required this.productName,
    required this.brandName,
    required this.category,
    required this.createdAt,
  });

  /// Factory untuk membuat model dari data JSON hasil query Supabase
  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final products = json['products'] as Map<String, dynamic>? ?? {};
    final sessions = json['recommendation_sessions'] as Map<String, dynamic>? ?? {};

    return RecommendationModel(
      resultId: json['recommendation_result_id'] as String,
      sessionId: json['recommendation_session_id'] as String,
      recommendationCode: sessions['recommendation_code'] as String?,
      productName: (products['product_name'] as String?) ?? 'Produk Tidak Dikenal',
      brandName: (products['brand_name'] as String?) ?? 'Brand Tidak Dikenal',
      category: (products['category'] as String?) ?? 'Kategori',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
