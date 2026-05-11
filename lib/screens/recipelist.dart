import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import 'recipe_card.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({
    super.key,
    required this.recipes,
    this.savedIds = const {},
    this.onToggleSave,
  });

  final List<RecipeModel> recipes;
  final Set<String> savedIds;
  final void Function(String recipeId, bool isSaved)? onToggleSave;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: recipes.length,
      itemBuilder: (_, i) {
        final recipe = recipes[i];
        final saved = savedIds.contains(recipe.recipeId);
        return RecipeCard(
          recipe: recipe,
          isSaved: saved,
          onToggleSave: onToggleSave != null
              ? () => onToggleSave!(recipe.recipeId, saved)
              : null,
        );
      },
    );
  }
}
