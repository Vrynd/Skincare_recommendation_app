/// Model data untuk menampung masalah kulit (skin_concerns) dari Supabase.
class SkinConcernModel {
  final String skinConcernId;
  final String skinConcernCode;
  final String skinConcernName;
  final String? description;

  const SkinConcernModel({
    required this.skinConcernId,
    required this.skinConcernCode,
    required this.skinConcernName,
    this.description,
  });

  /// Factory untuk membuat model dari data JSON hasil query Supabase
  factory SkinConcernModel.fromJson(Map<String, dynamic> json) {
    return SkinConcernModel(
      skinConcernId: json['skin_concern_id'] as String,
      skinConcernCode: json['skin_concern_code'] as String,
      skinConcernName: json['skin_concern_name'] as String,
      description: json['description'] as String?,
    );
  }

  /// Map ke JSON untuk penyimpanan jika diperlukan
  Map<String, dynamic> toJson() {
    return {
      'skin_concern_id': skinConcernId,
      'skin_concern_code': skinConcernCode,
      'skin_concern_name': skinConcernName,
      'description': description,
    };
  }

  /// Mendapatkan nama masalah kulit ramah pengguna dalam Bahasa Indonesia
  String get displayName => getDisplay(skinConcernName);

  static String getDisplay(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'acne':
      case 'jerawat':
      case 'kulit berjerawat':
        return 'Kulit Berjerawat';
      case 'hyperpigmentation':
      case 'hiperpigmentasi/noda hitam/kulit kusam':
      case 'kulit kusam':
        return 'Kulit Kusam';
      default:
        return name ?? '-';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinConcernModel && other.skinConcernId == skinConcernId;
  }

  @override
  int get hashCode => skinConcernId.hashCode;
}
