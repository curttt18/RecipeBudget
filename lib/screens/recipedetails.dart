import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../services/database.dart';

const _bg = Color(0xFF1A1A1A);
const _surface = Color(0xFF242424);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);
const _border = Color(0xFF333333);

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    required this.isSaved,
    this.userId,
  });

  final RecipeModel recipe;
  final bool isSaved;
  final String? userId;

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late bool _isSaved;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  Future<void> _toggleSave() async {
    if (widget.userId == null || _saving) return;
    setState(() => _saving = true);
    try {
      if (_isSaved) {
        await DatabaseService.unsaveRecipe(
          recipeId: widget.recipe.recipeId,
          userId: widget.userId!,
        );
      } else {
        await DatabaseService.saveRecipe(
          recipeId: widget.recipe.recipeId,
          userId: widget.userId!,
        );
      }
      if (mounted) setState(() => _isSaved = !_isSaved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color get _categoryColor {
    switch (widget.recipe.category) {
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

  IconData get _categoryIcon {
    switch (widget.recipe.category) {
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

  // Split a single instructions string ("Step 1 - ...\nStep 2 - ...") into steps.
  List<String> _parseSteps(List<String> raw) {
    if (raw.length == 1 && raw[0].contains(RegExp(r'Step \d+'))) {
      return raw[0]
          .split(RegExp(r'Step \d+\s*[-–]\s*[^:]*:\s*', multiLine: true))
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final steps = _parseSteps(recipe.instructions);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(recipe),
                  const SizedBox(height: 20),
                  _buildStatsRow(recipe),
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader('Ingredients', Icons.list_alt_rounded),
                    const SizedBox(height: 12),
                    _buildIngredientsList(recipe.ingredients),
                  ],
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                        'Instructions', Icons.format_list_numbered_rounded),
                    const SizedBox(height: 12),
                    _buildStepsList(steps),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Sliver app bar with hero image ────────────────────────────────────────

  SliverAppBar _buildAppBar(RecipeModel recipe) {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      backgroundColor: const Color(0xFF2C2C2C),
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: _white, size: 20),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipe.imageUrl != null
                ? Image.network(
                    recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
            // Bottom gradient so title stays readable
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xDD000000)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Category badge — top-right
            Positioned(
              top: 56,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _walnut, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_categoryIcon, color: _walnut, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      recipe.category,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _categoryColor,
      child: Center(
        child: Icon(
          _categoryIcon,
          color: Colors.white.withValues(alpha: 0.12),
          size: 100,
        ),
      ),
    );
  }

  // ── Title + cost ───────────────────────────────────────────────────────────

  Widget _buildTitleRow(RecipeModel recipe) {
    return Text(
      recipe.title,
      style: const TextStyle(
        color: _white,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── Stat chips ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(RecipeModel recipe) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.attach_money_rounded,
          label: '₱${recipe.costEstimate.toStringAsFixed(2)}',
          sublabel: 'Est. Cost',
          iconColor: _walnut,
          accentColor: _walnut,
        ),
        if (recipe.prepMinutes != null) ...[
          const SizedBox(width: 12),
          _StatChip(
            icon: Icons.timer_outlined,
            label: '${recipe.prepMinutes} min',
            sublabel: 'Cook Time',
            iconColor: _grey,
            accentColor: _grey,
          ),
        ],
      ],
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: _walnut,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _walnut, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Ingredients ────────────────────────────────────────────────────────────

  Widget _buildIngredientsList(List<String> ingredients) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: ingredients.asMap().entries.map((e) {
          final isLast = e.key == ingredients.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.fromLTRB(0, 5, 12, 0),
                      decoration: const BoxDecoration(
                        color: _walnut,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(
                          color: _white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    color: Color(0xFF2E2E2E), height: 1, thickness: 0.5),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Instructions ───────────────────────────────────────────────────────────

  Widget _buildStepsList(List<String> steps) {
    return Column(
      children: steps.asMap().entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 12, top: 1),
                decoration: const BoxDecoration(
                  color: _walnut,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      color: _white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  e.value.trim(),
                  style: const TextStyle(
                    color: _white,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Save FAB ───────────────────────────────────────────────────────────────

  Widget _buildSaveButton(BuildContext context) {
    final saved = _isSaved;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _saving ? null : _toggleSave,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: saved ? const Color(0xFF2C2C2C) : _walnut,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: saved ? const Color(0xFFE57373) : _walnut,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (saved ? const Color(0xFFE57373) : _walnut)
                    .withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _saving
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: _white, strokeWidth: 2),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      saved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: saved ? const Color(0xFFE57373) : _white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      saved ? 'Saved to Favorites' : 'Save Recipe',
                      style: TextStyle(
                        color: saved ? const Color(0xFFE57373) : _white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Stat chip widget ──────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.iconColor,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color iconColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(color: _grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
