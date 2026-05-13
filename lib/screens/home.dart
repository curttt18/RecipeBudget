import 'dart:async';

import 'package:flutter/material.dart';

import '../model/recipe_model.dart';
import '../services/database.dart';
import '../theme/app_theme.dart';
import 'budget_slider.dart';
import 'recipedetails.dart';
import 'recipelist.dart';

const _walnut = Color(0xFF8B5A2B);

const _categories = [
  'All',
  'Breakfast',
  'Vegan',
  'Dinner',
  'High Protein',
  'Under 20 Mins',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _budget = 100.0;
  String _category = 'All';
  String _userName = '';
  String? _currentUserID;
  Set<String> _savedIds = {};
  StreamSubscription<Set<String>>? _savedSub;
  StreamSubscription<Map<String, dynamic>?>? _userSub;

  @override
  void initState() {
    super.initState();
    _userSub = DatabaseService.userDataStream().listen(_onUserData);
  }

  void _onUserData(Map<String, dynamic>? data) {
    if (!mounted || data == null) return;

    final budget = (data['budget'] as num?)?.toDouble() ?? 100.0;
    final name = (data['displayName'] ?? '').toString();
    final userId = (data['userID'] ?? '').toString();

    budgetNotifier.value = budget;

    setState(() {
      _budget = budget;
      _userName = name;
    });

    if (_currentUserID == null && userId.isNotEmpty) {
      _currentUserID = userId;
      _savedSub =
          DatabaseService.savedRecipeIDsStream(userId).listen((ids) {
        if (mounted) setState(() => _savedIds = ids);
      });
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _savedSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleSave(String recipeId, bool isSaved) async {
    if (_currentUserID == null) return;
    if (isSaved) {
      await DatabaseService.unsaveRecipe(
          recipeId: recipeId, userId: _currentUserID!);
    } else {
      await DatabaseService.saveRecipe(
          recipeId: recipeId, userId: _currentUserID!);
    }
  }

  void _openDetails(BuildContext context, RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailsPage(
          recipe: recipe,
          isSaved: _savedIds.contains(recipe.recipeId),
          userId: _currentUserID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecipeModel>>(
      stream: DatabaseService.recipesStream(),
      builder: (context, snapshot) {
        final allRecipes = snapshot.data ?? [];
        final filtered = allRecipes.where((r) {
          if (r.costEstimate > _budget) return false;
          if (_category == 'All') return true;
          if (_category == 'Under 20 Mins') {
            return r.prepMinutes != null && r.prepMinutes! <= 20;
          }
          return r.category == _category;
        }).toList();

        final loading =
            snapshot.connectionState == ConnectionState.waiting &&
                allRecipes.isEmpty;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcome(),
              _buildBudgetCard(),
              _buildCategoryChips(),
              _buildFeedHeader(filtered.length, loading),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: _walnut),
                  ),
                )
              else if (filtered.isEmpty)
                _buildEmptyState()
              else
                RecipeList(
                  recipes: filtered,
                  savedIds: _savedIds,
                  onToggleSave: _toggleSave,
                  onTap: (r) => _openDetails(context, r),
                ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildWelcome() {
    final displayName = _userName.isEmpty ? 'there' : _userName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $displayName',
                  style: TextStyle(
                    color: AppColors.of(context).onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'What are you cooking today?',
                  style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x168B5A2B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x668B5A2B), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current Limit',
                  style: TextStyle(
                      color: AppColors.of(context).subtext, fontSize: 10, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  '₱${_budget.toStringAsFixed(0)}',
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
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.of(context).border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: _walnut, size: 16),
              const SizedBox(width: 8),
              Text(
                'Budget Control',
                style: TextStyle(
                    color: AppColors.of(context).onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '₱${_budget.toStringAsFixed(0)}',
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
          if (_budget > 0) ...[
            Row(
              children: [
                Text('₱1',
                    style: TextStyle(color: AppColors.of(context).subtext, fontSize: 11)),
                Expanded(
                  child: BudgetSlider(
                    value: _budget,
                    min: 1,
                    max: _budget > 500 ? _budget : 500,
                    onChanged: (v) => setState(() => _budget = v),
                  ),
                ),
                Text('₱${(_budget > 500 ? _budget : 500).toStringAsFixed(0)}',
                    style: TextStyle(color: AppColors.of(context).subtext, fontSize: 11)),
              ],
            ),
            Center(
              child: Text(
                'Showing meals under ₱${_budget.toStringAsFixed(0)}',
                style: TextStyle(
                  color: AppColors.of(context).subtext,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Set your budget in profile settings\nunder budget settings button',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF8B5A2B),
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
          separatorBuilder: (_, i) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final selected = cat == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _walnut : AppColors.of(context).surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        selected ? _walnut : AppColors.of(context).border,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.of(context).subtext,
                    fontSize: 12.5,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildFeedHeader(int count, bool loading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Recipes for you',
            style: TextStyle(
              color: AppColors.of(context).onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (loading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  color: _walnut, strokeWidth: 2),
            )
          else
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, color: _walnut, size: 56),
            const SizedBox(height: 16),
            Text(
              'No recipes in this range',
              style: TextStyle(
                  color: AppColors.of(context).onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Try raising your budget or\nchanging the category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
