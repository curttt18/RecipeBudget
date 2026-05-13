import 'dart:async';
import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../services/database.dart';
import '../theme/app_theme.dart';
import 'recipe_card.dart';
import 'recipedetails.dart';

const _walnut = Color(0xFF8B5A2B);

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

const _filterCategories = ['All', 'Breakfast', 'Lunch', 'Dinner'];

class _MyRecipesPageState extends State<MyRecipesPage> {
  String? _currentUserID;
  Set<String> _savedIds = {};
  StreamSubscription<Set<String>>? _savedSub;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    DatabaseService.getCurrentUserID().then((id) {
      if (!mounted || id == null) return;
      setState(() => _currentUserID = id);
      _savedSub = DatabaseService.savedRecipeIDsStream(id).listen((ids) {
        if (mounted) setState(() => _savedIds = ids);
      });
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'My Saved Recipes',
              style: TextStyle(
                color: AppColors.of(context).onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Recipes you\'ve bookmarked for later.',
              style:
                  TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _filterCategories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _walnut : AppColors.of(context).surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _walnut : AppColors.of(context).border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.of(context).subtext,
                          fontSize: 13,
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
            const SizedBox(height: 20),
            if (_currentUserID == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(color: _walnut),
                ),
              )
            else
              StreamBuilder<List<RecipeModel>>(
                stream: DatabaseService.recipesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      (snapshot.data?.isEmpty ?? true)) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(color: _walnut),
                      ),
                    );
                  }

                  final saved = (snapshot.data ?? [])
                      .where((r) =>
                          _savedIds.contains(r.recipeId) &&
                          (_selectedCategory == 'All' ||
                              r.category == _selectedCategory))
                      .toList();

                  if (saved.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: saved.length,
                    itemBuilder: (_, i) {
                      final recipe = saved[i];
                      return RecipeCard(
                        recipe: recipe,
                        isSaved: true,
                        onToggleSave: () =>
                            _toggleSave(recipe.recipeId, true),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailsPage(
                              recipe: recipe,
                              isSaved: true,
                              userId: _currentUserID,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.of(context).border, width: 1.5),
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                color: _walnut, size: 44),
          ),
          const SizedBox(height: 20),
          Text(
            'Nothing saved yet',
            style: TextStyle(
              color: AppColors.of(context).onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon on any recipe\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.of(context).subtext,
                fontSize: 13,
                height: 1.6),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 180,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: widget.onBrowse,
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'Browse Recipes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _walnut,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
