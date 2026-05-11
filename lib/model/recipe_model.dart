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
    return RecipeModel(
      recipeId: id,
      title: data['title'] ?? '',
      costEstimate: (data['cost_estimate'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      imageUrl: data['image_url'],
      prepMinutes: data['prep_minutes'],
    );
  }
}
