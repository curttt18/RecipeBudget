import 'dart:async';
import 'package:flutter/material.dart';
import 'model/recipe_model.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/recipedetails.dart';
import 'screens/recipelist.dart';
import 'screens/register.dart';
import 'screens/meal_plan.dart';
import 'screens/settings.dart';
import 'services/database.dart';

class SavrApp extends StatelessWidget {
  const SavrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B),
          brightness: Brightness.dark,
        ),
      ),
      home: const RegisterPage(),
    );
  }
}

// ── Main scaffold ──────────────────────────────────────────────────────────────

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  static const _titles = ['Savr', 'Browse Recipes', 'My Recipes', 'Meal Plan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF8B5A2B)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF8B5A2B)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: const Color(0xFF1A1A1A),
                  appBar: AppBar(
                    backgroundColor: const Color(0xFF2C2C2C),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Color(0xFF8B5A2B), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        fontSize: 20,
                      ),
                    ),
                    centerTitle: true,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                          height: 1, color: const Color(0xFF3A3A3A)),
                    ),
                  ),
                  body: const SettingsPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _SavrDrawer(
        currentIndex: _currentIndex,
        onNavigate: (i) {
          setState(() => _currentIndex = i);
          Navigator.pop(context);
        },
      ),
      // IndexedStack preserves each page's scroll and state across tab switches
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          _RecipeBrowserPage(),
          MyRecipesPage(),
          MealPlanPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF333333), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFF242424),
          selectedItemColor: const Color(0xFF8B5A2B),
          unselectedItemColor: const Color(0xFF9E9E9E),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_rounded),
              label: 'My Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Meal Plan',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wooden drawer ──────────────────────────────────────────────────────────────

class _SavrDrawer extends StatelessWidget {
  const _SavrDrawer({required this.currentIndex, required this.onNavigate});

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2B1A0A),
      child: Column(
        children: [
          _buildHeader(),
          _buildProfile(),
          const _WoodDivider(),
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onNavigate(0),
          ),
          _NavItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Browse Recipes',
            selected: currentIndex == 1,
            onTap: () => onNavigate(1),
          ),
          _NavItem(
            icon: Icons.bookmark_rounded,
            label: 'My Recipes',
            selected: currentIndex == 2,
            onTap: () => onNavigate(2),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Meal Plan',
            selected: currentIndex == 3,
            onTap: () => onNavigate(3),
          ),
          const Spacer(),
          const _WoodDivider(),
          _NavItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            isDestructive: true,
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 210,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/sidebarlogo.jpg', fit: BoxFit.cover),
          // Gradient fades image into the wood background at the bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x202B1A0A),
                  Color(0xBB2B1A0A),
                  Color(0xFF2B1A0A),
                ],
                stops: [0.0, 0.62, 1.0],
              ),
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Savr',
                  style: TextStyle(
                    color: Color(0xFFF0DEC8),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cut costs, not flavor.',
                  style: TextStyle(
                    color: Color(0xFF8B5A2B),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2410),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5A3515), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5A2B),
              border: Border.all(color: const Color(0xFFAD7244), width: 1.5),
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jacob',
                  style: TextStyle(
                    color: Color(0xFFF0DEC8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Budget: ₱20.00 / meal',
                  style: TextStyle(
                    color: Color(0xFFB09070),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}

// ── Drawer components ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFE57373)
        : selected
            ? const Color(0xFFCE9B6E)
            : const Color(0xFFB09070);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x225A3515),
        highlightColor: const Color(0x115A3515),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: selected
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFF8B5A2B), width: 3),
                  ),
                  color: Color(0x1E5A3515),
                )
              : null,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WoodDivider extends StatelessWidget {
  const _WoodDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF4A2810),
      thickness: 1,
      indent: 20,
      endIndent: 20,
      height: 24,
    );
  }
}

// ── Browse recipes page ────────────────────────────────────────────────────────

class _RecipeBrowserPage extends StatefulWidget {
  const _RecipeBrowserPage();

  @override
  State<_RecipeBrowserPage> createState() => _RecipeBrowserPageState();
}

class _RecipeBrowserPageState extends State<_RecipeBrowserPage> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _currentUserID;
  Set<String> _savedIds = {};
  StreamSubscription<Set<String>>? _savedSub;

  static const _filterGroups = <String, List<String>>{
    'Meal Type': ['Breakfast', 'Lunch', 'Dinner'],
    'Diet Plan': ['Vegan', 'High Protein', 'Gluten Free'],
    'Cuisine Type': ['Mexican', 'Asian', 'American', 'Italian'],
  };

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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF444444),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Filter Recipes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF8B5A2B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ..._filterGroups.entries.map((group) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.key.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8B5A2B),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: group.value.map((cat) {
                          final active = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory =
                                  active ? null : cat);
                              setSheetState(() {});
                              if (!active) Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFF8B5A2B)
                                    : const Color(0xFF2C2C2C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? const Color(0xFF8B5A2B)
                                      : const Color(0xFF3A3A3A),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF9E9E9E),
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecipeModel>>(
      stream: DatabaseService.recipesStream(),
      builder: (context, snapshot) {
        final recipes = snapshot.data ?? [];
        final filtered = recipes.where((r) {
          final matchSearch = _searchQuery.isEmpty ||
              r.title.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchCat = _selectedCategory == null ||
              r.category == _selectedCategory;
          return matchSearch && matchCat;
        }).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search + filter button ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF9E9E9E), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Color(0xFF8B5A2B), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF3A3A3A), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF8B5A2B), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedCategory != null
                                  ? const Color(0xFF8B5A2B)
                                  : const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCategory != null
                                    ? const Color(0xFF8B5A2B)
                                    : const Color(0xFF3A3A3A),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: _selectedCategory != null
                                  ? Colors.white
                                  : const Color(0xFF9E9E9E),
                              size: 20,
                            ),
                          ),
                          if (_selectedCategory != null)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Active filter chip ──────────────────────────────────────
              if (_selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A2010),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF8B5A2B), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.filter_list_rounded,
                                color: Color(0xFF8B5A2B), size: 13),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCategory!,
                              style: const TextStyle(
                                color: Color(0xFFAD7244),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = null),
                              child: const Icon(Icons.close_rounded,
                                  color: Color(0xFF8B5A2B), size: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Header row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory ?? 'All Recipes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: Color(0xFF8B5A2B), strokeWidth: 2),
                      )
                    else
                      Text(
                        '${filtered.length} recipe${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Color(0xFF8B5A2B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Failed to load recipes. Check your connection.',
                    style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                  ),
                )
              else if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5A2B)),
                  ),
                )
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded,
                            color: Color(0xFF555555), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _selectedCategory != null
                              ? 'No "$_selectedCategory" recipes found.'
                              : _searchQuery.isEmpty
                                  ? 'No recipes found.'
                                  : 'No results for "$_searchQuery".',
                          style: const TextStyle(
                              color: Color(0xFF9E9E9E), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                RecipeList(
                  recipes: filtered,
                  savedIds: _savedIds,
                  onToggleSave: _toggleSave,
                  onTap: (recipe) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailsPage(
                        recipe: recipe,
                        isSaved: _savedIds.contains(recipe.recipeId),
                        userId: _currentUserID,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
