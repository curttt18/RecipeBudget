import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/meal_plan_model.dart';
import '../model/recipe_model.dart';
import '../services/database.dart';

const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _walnutLight = Color(0xFFAD7244);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);
const _greyDark = Color(0xFF3A3A3A);

String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
}

// ── Page ──────────────────────────────────────────────────────────────────────

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  String? _userId;
  bool _initDone = false;
  List<RecipeModel> _recipes = [];
  StreamSubscription<List<RecipeModel>>? _recipeSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Try the custom sequential ID first; fall back to Firebase Auth UID
    // so Google Sign-In users (who have no tbl_users doc) don't get stuck
    String? id = await DatabaseService.getCurrentUserID();
    id ??= FirebaseAuth.instance.currentUser?.uid;
    if (!mounted) return;
    setState(() {
      _userId = id;
      _initDone = true;
    });
    _recipeSub = DatabaseService.recipesStream().listen((list) {
      if (mounted) setState(() => _recipes = list);
    });
  }

  @override
  void dispose() {
    _recipeSub?.cancel();
    super.dispose();
  }

  void _showCreateModal() {
    if (_userId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePlanSheet(
        userId: _userId!,
        availableRecipes: _recipes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Center(
        child: CircularProgressIndicator(color: _walnut),
      );
    }
    if (_userId == null) {
      return const Center(
        child: Text('Unable to load user. Please log out and sign in again.',
            style: TextStyle(color: _grey, fontSize: 13),
            textAlign: TextAlign.center),
      );
    }

    return Stack(
      children: [
        StreamBuilder<List<MealPlanModel>>(
          stream: DatabaseService.mealPlansStream(_userId!),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _walnut),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Failed to load meal plans.\n${snap.error}',
                    style: const TextStyle(color: _grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final plans = snap.data ?? [];
            if (plans.isEmpty) return _buildEmpty();
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _MealPlanCard(
                plan: plans[i],
                recipes: _recipes,
                onDelete: () => DatabaseService.deleteMealPlan(plans[i].docId),
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: _walnut,
            foregroundColor: _white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: _showCreateModal,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF261508),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4A3020), width: 1.5),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _walnut,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No meal plans yet',
            style: TextStyle(
              color: _white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to schedule your first meal plan',
            style: TextStyle(color: _grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Meal plan card ─────────────────────────────────────────────────────────────

class _MealPlanCard extends StatelessWidget {
  const _MealPlanCard({
    required this.plan,
    required this.recipes,
    required this.onDelete,
  });

  final MealPlanModel plan;
  final List<RecipeModel> recipes;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final linked = recipes
        .where((r) => plan.recipeIds.contains(r.recipeId))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _greyDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: date badge + delete ────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF261508),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4A3020)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: _walnut, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      _fmtDate(plan.schedule),
                      style: const TextStyle(
                        color: _walnutLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: _grey, size: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Plan name ───────────────────────────────────────────────────
          Text(
            plan.planName,
            style: const TextStyle(
              color: _white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          // ── Plan details ────────────────────────────────────────────────
          if (plan.planDetails.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan.planDetails,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _grey,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],

          // ── Notes chip ──────────────────────────────────────────────────
          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes_rounded, color: _walnut, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      plan.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Linked recipes ──────────────────────────────────────────────
          if (linked.isNotEmpty || plan.recipeIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFF333333)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.restaurant_menu_rounded,
                    color: _walnut, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    linked.isNotEmpty
                        ? linked.map((r) => r.title).join(', ')
                        : '${plan.recipeIds.length} recipe${plan.recipeIds.length == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _walnutLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _charcoal,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Plan',
          style: TextStyle(
              color: _white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${plan.planName}"? This cannot be undone.',
          style: const TextStyle(color: _grey, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Create plan bottom sheet ───────────────────────────────────────────────────

class _CreatePlanSheet extends StatefulWidget {
  const _CreatePlanSheet({
    required this.userId,
    required this.availableRecipes,
  });

  final String userId;
  final List<RecipeModel> availableRecipes;

  @override
  State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _nameCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _schedule = DateTime.now().add(const Duration(days: 1));
  final Set<String> _selectedIds = {};
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _detailsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _schedule,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _walnut,
            onPrimary: _white,
            surface: _charcoal,
            onSurface: _white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _schedule = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Plan name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await DatabaseService.createMealPlan(
      userId: widget.userId,
      planName: _nameCtrl.text.trim(),
      planDetails: _detailsCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      schedule: _schedule,
      recipeIds: _selectedIds.toList(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Fixed header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: _greyDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'New Meal Plan',
                    style: TextStyle(
                      color: _white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fill in the details to schedule your meal',
                    style: TextStyle(color: _grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFF2E2E2E)),
                ],
              ),
            ),

            // ── Scrollable form ──────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  MediaQuery.of(ctx).viewInsets.bottom + 32,
                ),
                children: [
                  // Plan Name
                  _Field(
                    controller: _nameCtrl,
                    label: 'Plan Name',
                    hint: 'e.g. Healthy Week 1',
                    icon: Icons.edit_calendar_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Schedule date picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: _charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _greyDark),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: _walnut, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Schedule Date',
                                  style:
                                      TextStyle(color: _grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                _fmtDate(_schedule),
                                style: const TextStyle(
                                  color: _white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded,
                              color: _grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Plan Details
                  _Field(
                    controller: _detailsCtrl,
                    label: 'Plan Details',
                    hint: 'Describe the meals included...',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _Field(
                    controller: _notesCtrl,
                    label: 'Notes',
                    hint: 'Any additional notes or reminders...',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),

                  // Link Recipes
                  if (widget.availableRecipes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF261508),
                            borderRadius: BorderRadius.circular(9),
                            border:
                                Border.all(color: const Color(0xFF4A3020)),
                          ),
                          child: const Icon(
                              Icons.restaurant_menu_rounded,
                              color: _walnut,
                              size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'LINK RECIPES',
                          style: TextStyle(
                            color: _walnut,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedIds.isEmpty
                              ? 'Optional'
                              : '${_selectedIds.length} selected',
                          style:
                              const TextStyle(color: _grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableRecipes.map((r) {
                        final sel = _selectedIds.contains(r.recipeId);
                        return GestureDetector(
                          onTap: () => setState(() {
                            sel
                                ? _selectedIds.remove(r.recipeId)
                                : _selectedIds.add(r.recipeId);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? _walnut : _charcoal,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel ? _walnut : _greyDark,
                              ),
                            ),
                            child: Text(
                              r.title,
                              style: TextStyle(
                                color: sel ? _white : _grey,
                                fontSize: 12.5,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _walnut,
                        disabledBackgroundColor:
                            _walnut.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: _white, strokeWidth: 2),
                            )
                          : const Text(
                              'Create Meal Plan',
                              style: TextStyle(
                                color: _white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared form field ──────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFF555555), fontSize: 13),
        labelStyle: const TextStyle(color: _grey, fontSize: 13),
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 42),
                child: Icon(icon, color: _walnut, size: 20),
              )
            : Icon(icon, color: _walnut, size: 20),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: _charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _greyDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _greyDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _walnut, width: 1.5),
        ),
      ),
    );
  }
}
