class UserModel {
  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.globalBudget,
    this.savedRecipes = const [],
    this.mealPlans = const [],
  });

  final String userId;
  final String name;
  final String email;
  final double globalBudget;
  final List<String> savedRecipes;
  final List<String> mealPlans;

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      userId: (data['userID'] ?? id).toString(),
      name: data['displayName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      globalBudget: (data['budget'] ?? data['global_budget'] ?? 0).toDouble(),
      savedRecipes: List<String>.from(data['saved_recipes'] ?? []),
      mealPlans: List<String>.from(data['meal_plans'] ?? []),
    );
  }
}
