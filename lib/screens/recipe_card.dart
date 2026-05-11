import 'package:flutter/material.dart';
import '../model/recipe_model.dart';

const _white = Colors.white;
const _walnut = Color(0xFF8B5A2B);
const _grey = Color(0xFF9E9E9E);

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 55,
            child: _ImagePlaceholder(
              category: recipe.category,
              imageUrl: recipe.imageUrl,
            ),
          ),
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded,
                          color: _walnut, size: 14),
                      Text(
                        recipe.costEstimate.toStringAsFixed(2),
                        style: const TextStyle(
                          color: _walnut,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (recipe.prepMinutes != null)
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: _grey, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${recipe.prepMinutes}m',
                              style: const TextStyle(
                                  color: _grey, fontSize: 11),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.category, this.imageUrl});

  final String category;
  final String? imageUrl;

  Color get _bgColor {
    switch (category) {
      case 'Breakfast':
        return const Color(0xFF5D3A1A);
      case 'Vegan':
        return const Color(0xFF1B4332);
      case 'Dinner':
        return const Color(0xFF1A237E);
      case 'High Protein':
        return const Color(0xFF6D0000);
      default:
        return const Color(0xFF3E2723);
    }
  }

  IconData get _icon {
    switch (category) {
      case 'Breakfast':
        return Icons.breakfast_dining_rounded;
      case 'Vegan':
        return Icons.eco_rounded;
      case 'Dinner':
        return Icons.dinner_dining_rounded;
      case 'High Protein':
        return Icons.fitness_center_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity);
    }

    return Container(
      width: double.infinity,
      color: _bgColor,
      child: Stack(
        children: [
          Center(
            child: Icon(
              _icon,
              color: const Color.fromRGBO(255, 255, 255, 0.12),
              size: 68,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: _white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
