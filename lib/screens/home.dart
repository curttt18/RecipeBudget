import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../model/user_model.dart';
import 'budget_slider.dart';
import 'recipelist.dart';

const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);

const _categories = [
  'All',
  'Breakfast',
  'Vegan',
  'Dinner',
  'High Protein',
  'Under 20 Mins',
];

const _mockUser = UserModel(
  userId: 'u1',
  name: 'Jacob',
  email: '',
  globalBudget: 20.0,
);

const List<RecipeModel> _mockRecipes = [
  RecipeModel(recipeId: '1', title: 'Garlic Butter Pasta', costEstimate: 4.50, category: 'Dinner', prepMinutes: 25),
  RecipeModel(recipeId: '2', title: 'Avocado Toast', costEstimate: 5.00, category: 'Breakfast', prepMinutes: 10),
  RecipeModel(recipeId: '3', title: 'Vegan Buddha Bowl', costEstimate: 8.50, category: 'Vegan', prepMinutes: 30),
  RecipeModel(recipeId: '4', title: 'Chicken Fried Rice', costEstimate: 7.00, category: 'Dinner', prepMinutes: 20),
  RecipeModel(recipeId: '5', title: 'Greek Yogurt Parfait', costEstimate: 3.50, category: 'Breakfast', prepMinutes: 5),
  RecipeModel(recipeId: '6', title: 'Lentil Soup', costEstimate: 5.50, category: 'Vegan', prepMinutes: 40),
  RecipeModel(recipeId: '7', title: 'Turkey Power Wrap', costEstimate: 9.00, category: 'High Protein', prepMinutes: 15),
  RecipeModel(recipeId: '8', title: 'Fluffy Egg Omelette', costEstimate: 4.00, category: 'Breakfast', prepMinutes: 12),
  RecipeModel(recipeId: '9', title: 'Black Bean Tacos', costEstimate: 6.50, category: 'Vegan', prepMinutes: 20),
  RecipeModel(recipeId: '10', title: 'Pesto Chicken Breast', costEstimate: 11.00, category: 'High Protein', prepMinutes: 30),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _budget = _mockUser.globalBudget;
  String _category = 'All';

  List<RecipeModel> get _filtered => _mockRecipes.where((r) {
        final inBudget = r.costEstimate <= _budget;
        final bool matchesCategory;
        if (_category == 'All') {
          matchesCategory = true;
        } else if (_category == 'Under 20 Mins') {
          matchesCategory = r.prepMinutes != null && r.prepMinutes! <= 20;
        } else {
          matchesCategory = r.category == _category;
        }
        return inBudget && matchesCategory;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcome(),
          _buildBudgetCard(),
          _buildCategoryChips(),
          _buildFeedHeader(filtered.length),
          if (filtered.isEmpty) _buildEmptyState() else RecipeList(recipes: filtered),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_mockUser.name}',
                style: const TextStyle(
                  color: _white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'What are you cooking today?',
                style: TextStyle(color: _grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x168B5A2B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x668B5A2B), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Current Limit',
                  style: TextStyle(color: _grey, fontSize: 10, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${_budget.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _walnut,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: _walnut, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Budget Control',
                style: TextStyle(
                  color: _white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${_budget.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _walnut,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('\$1', style: TextStyle(color: _grey, fontSize: 11)),
              Expanded(
                child: BudgetSlider(
                  value: _budget,
                  onChanged: (v) => setState(() => _budget = v),
                ),
              ),
              const Text('\$50', style: TextStyle(color: _grey, fontSize: 11)),
            ],
          ),
          Center(
            child: Text(
              'Showing meals under \$${_budget.toStringAsFixed(0)}',
              style: const TextStyle(
                color: _grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final selected = cat == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _walnut : _charcoal,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _walnut : const Color(0xFF3A3A3A),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? _white : _grey,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Recipes for you',
            style: TextStyle(
              color: _white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            '$count result${count == 1 ? '' : 's'}',
            style: const TextStyle(
              color: _walnut,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, color: _walnut, size: 56),
            SizedBox(height: 16),
            Text(
              'No recipes in this range',
              style: TextStyle(
                  color: _white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Try raising your budget or\nchanging the category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
