import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/meal_plan_model.dart';
import '../model/recipe_model.dart';
import '../services/database.dart';
import '../theme/app_theme.dart';

const _walnut = Color(0xFF8B5A2B);

String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
}

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
      return Center(
        child: Text('Unable to load user. Please log out and sign in again.',
            style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
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
                    style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
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
            foregroundColor: Colors.white,
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
              color: AppColors.of(context).chipBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.of(context).chipBorder, width: 1.5),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _walnut,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No meal plans yet',
            style: TextStyle(
              color: AppColors.of(context).onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to schedule your first meal plan',
            style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

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
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.of(context).chipBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.of(context).chipBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: _walnut, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      _fmtDate(plan.schedule),
                      style: TextStyle(
                        color: AppColors.of(context).accentLight,
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
                    color: AppColors.of(context).background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: AppColors.of(context).subtext, size: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            plan.planName,
            style: TextStyle(
              color: AppColors.of(context).onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (plan.planDetails.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan.planDetails,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.of(context).subtext,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],

          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.of(context).background,
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
                      style: TextStyle(color: AppColors.of(context).subtext, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (linked.isNotEmpty || plan.recipeIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.of(context).divider),
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
                    style: TextStyle(
                      color: AppColors.of(context).accentLight,
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
        backgroundColor: AppColors.of(context).surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Plan',
          style: TextStyle(
              color: AppColors.of(context).onSurface, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${plan.planName}"? This cannot be undone.',
          style: TextStyle(color: AppColors.of(context).subtext, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.of(context).subtext)),
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
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
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
        decoration: BoxDecoration(
          color: AppColors.of(ctx).modal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
                        color: AppColors.of(ctx).border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'New Meal Plan',
                    style: TextStyle(
                      color: AppColors.of(ctx).onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fill in the details to schedule your meal',
                    style: TextStyle(color: AppColors.of(ctx).subtext, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: AppColors.of(ctx).divider),
                ],
              ),
            ),

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
                  _Field(
                    controller: _nameCtrl,
                    label: 'Plan Name',
                    hint: 'e.g. Healthy Week 1',
                    icon: Icons.edit_calendar_rounded,
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.of(ctx).surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.of(ctx).border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: _walnut, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Schedule Date',
                                  style:
                                      TextStyle(color: AppColors.of(ctx).subtext, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                _fmtDate(_schedule),
                                style: TextStyle(
                                  color: AppColors.of(ctx).onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.of(ctx).subtext, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _Field(
                    controller: _detailsCtrl,
                    label: 'Plan Details',
                    hint: 'Describe the meals included...',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  _Field(
                    controller: _notesCtrl,
                    label: 'Notes',
                    hint: 'Any additional notes or reminders...',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),

                  if (widget.availableRecipes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.of(ctx).chipBg,
                            borderRadius: BorderRadius.circular(9),
                            border:
                                Border.all(color: AppColors.of(ctx).chipBorder),
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
                              TextStyle(color: AppColors.of(ctx).subtext, fontSize: 11),
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
                              color: sel ? _walnut : AppColors.of(ctx).surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel ? _walnut : AppColors.of(ctx).border,
                              ),
                            ),
                            child: Text(
                              r.title,
                              style: TextStyle(
                                color: sel ? Colors.white : AppColors.of(ctx).subtext,
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
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Create Meal Plan',
                              style: TextStyle(
                                color: Colors.white,
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
      style: TextStyle(color: AppColors.of(context).onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
        labelStyle: TextStyle(color: AppColors.of(context).subtext, fontSize: 13),
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 42),
                child: Icon(icon, color: _walnut, size: 20),
              )
            : Icon(icon, color: _walnut, size: 20),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppColors.of(context).surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _walnut, width: 1.5),
        ),
      ),
    );
  }
}
