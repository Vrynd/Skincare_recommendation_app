// Model data untuk merepresentasikan satu entri riwayat sesi rekomendasi beserta produk dengan skor tertinggi.
class HistoryItem {
  final String resultId;
  final String sessionId;
  final String recommendationCode;
  final double matchScore;
  final String recommendationCategory;
  final int rankPosition;
  final DateTime createdAt;
  final String productId;
  final String productCode;
  final String brandName;
  final String productName;
  final int spf;
  final String paGrade;
  final String sunscreenType;
  final String texture;
  final String finish;

  const HistoryItem({
    required this.resultId,
    required this.sessionId,
    required this.recommendationCode,
    required this.matchScore,
    required this.recommendationCategory,
    required this.rankPosition,
    required this.createdAt,
    required this.productId,
    required this.productCode,
    required this.brandName,
    required this.productName,
    required this.spf,
    required this.paGrade,
    required this.sunscreenType,
    required this.texture,
    required this.finish,
  });

  /// Mengembalikan nama hari dan jam dalam Bahasa Indonesia (misal: "Senin, 09:00")
  String get formattedDayTime {
    const List<String> days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final dayName = days[createdAt.weekday - 1];
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$dayName, $hour:$minute';
  }

  /// Mengembalikan singkatan nama hari dalam Bahasa Indonesia (misal: "SEN", "SEL", "RAB", "KAM", "JUM", "SAB", "MIN")
  String get formattedDayOfWeekShort {
    const List<String> daysShort = [
      'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'
    ];
    return daysShort[createdAt.weekday - 1];
  }

  /// Mengembalikan jam saja (misal: "09:00")
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Mengembalikan tanggal hari (misal: "20")
  String get formattedDay => createdAt.day.toString();

  /// Mengembalikan singkatan nama bulan (misal: "Jun")
  String get formattedMonthShort {
    const List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return monthsShort[createdAt.month - 1];
  }


  /// Factory untuk membuat model dari data JSON hasil query Supabase
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final products = json['products'] as Map<String, dynamic>? ?? {};
    final sessions = json['recommendation_sessions'] as Map<String, dynamic>? ?? {};

    return HistoryItem(
      resultId: json['recommendation_result_id'] as String? ?? json['recommendation_result_id'] ?? '',
      sessionId: json['recommendation_session_id'] as String? ?? json['recommendation_session_id'] ?? '',
      matchScore: (json['match_score'] as num? ?? 0.0).toDouble(),
      recommendationCategory: json['recommendation_category'] as String? ?? '',
      rankPosition: json['rank_position'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()).toLocal(),
      recommendationCode: sessions['recommendation_code'] as String? ?? '',
      productId: products['product_id'] as String? ?? json['product_id'] as String? ?? '',
      productCode: products['product_code'] as String? ?? '',
      brandName: products['brand_name'] as String? ?? 'Brand Tidak Dikenal',
      productName: products['product_name'] as String? ?? 'Produk Tidak Dikenal',
      spf: products['spf'] as int? ?? 0,
      paGrade: products['pa_grade'] as String? ?? '',
      sunscreenType: products['sunscreen_type'] as String? ?? '',
      texture: products['texture'] as String? ?? '',
      finish: products['finish'] as String? ?? '',
    );
  }

  /// Map model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'recommendation_result_id': resultId,
      'recommendation_session_id': sessionId,
      'match_score': matchScore,
      'recommendation_category': recommendationCategory,
      'rank_position': rankPosition,
      'created_at': createdAt.toIso8601String(),
      'recommendation_sessions': {
        'recommendation_code': recommendationCode,
      },
      'products': {
        'product_id': productId,
        'product_code': productCode,
        'brand_name': brandName,
        'product_name': productName,
        'spf': spf,
        'pa_grade': paGrade,
        'sunscreen_type': sunscreenType,
        'texture': texture,
        'finish': finish,
      }
    };
  }
}
