/// Model data untuk menampung bahan kosmetik (ingredients) dari Supabase.
class IngredientModel {
  final String ingredientId;
  final String ingredientCode;
  final String ingredientName;
  final String? category;

  const IngredientModel({
    required this.ingredientId,
    required this.ingredientCode,
    required this.ingredientName,
    this.category,
  });

  /// Factory untuk membuat model dari data JSON hasil query Supabase
  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      ingredientId: json['ingredient_id'] as String,
      ingredientCode: json['ingredient_code'] as String,
      ingredientName: json['ingredient_name'] as String,
      category: json['category'] as String?,
    );
  }

  /// Map ke JSON untuk penyimpanan jika diperlukan
  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'ingredient_code': ingredientCode,
      'ingredient_name': ingredientName,
      'category': category,
    };
  }
}
