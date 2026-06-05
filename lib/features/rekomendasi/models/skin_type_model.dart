/// Model data untuk menampung jenis kulit (skin_types) dari Supabase.
class SkinTypeModel {
  final String skinTypeId;
  final String skinTypeCode;
  final String skinTypeName;
  final String? description;

  const SkinTypeModel({
    required this.skinTypeId,
    required this.skinTypeCode,
    required this.skinTypeName,
    this.description,
  });

  /// Factory untuk membuat model dari data JSON hasil query Supabase
  factory SkinTypeModel.fromJson(Map<String, dynamic> json) {
    return SkinTypeModel(
      skinTypeId: json['skin_type_id'] as String,
      skinTypeCode: json['skin_type_code'] as String,
      skinTypeName: json['skin_type_name'] as String,
      description: json['description'] as String?,
    );
  }

  /// Map ke JSON untuk penyimpanan jika diperlukan
  Map<String, dynamic> toJson() {
    return {
      'skin_type_id': skinTypeId,
      'skin_type_code': skinTypeCode,
      'skin_type_name': skinTypeName,
      'description': description,
    };
  }

  /// Mendapatkan nama jenis kulit ramah pengguna dalam Bahasa Indonesia
  String get displayName => getDisplay(skinTypeName);

  static String getDisplay(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'oily':
        return 'Kulit Berminyak';
      case 'dry':
        return 'Kulit Kering';
      case 'combination':
        return 'Kulit Kombinasi';
      case 'normal':
        return 'Kulit Normal';
      case 'sensitive':
        return 'Kulit Sensitif';
      default:
        return name ?? '-';
    }
  }
}
