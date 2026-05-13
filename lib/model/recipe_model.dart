class RecipeModel {
  const RecipeModel({
    required this.recipeId,
    required this.title,
    required this.costEstimate,
    required this.category,
    this.ingredients = const [],
    this.instructions = const [],
    this.imageUrl,
    this.prepMinutes,
  });

  final String recipeId;
  final String title;
  final double costEstimate;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final int? prepMinutes;

  factory RecipeModel.fromFirestore(Map<String, dynamic> data, String id) {
    final raw = data['instructions'];
    final instructionsList = raw is String
        ? [raw]
        : List<String>.from(raw ?? []);

    return RecipeModel(
      recipeId: id,
      title: data['title'] ?? '',
      costEstimate: (data['cost_estimate'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: instructionsList,
      imageUrl: data['image_url'],
      prepMinutes: data['cooking_time'] != null
          ? (data['cooking_time'] as num).toInt() ~/ 1000
          : (data['prep_minutes'] as num?)?.toInt(),
    );
  }
}
