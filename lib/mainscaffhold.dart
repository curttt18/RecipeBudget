import 'package:flutter/material.dart';
import 'model/recipe_model.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/recipelist.dart';
import 'screens/register.dart';
import 'screens/settings.dart';

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

  static const _titles = ['Savr', 'Browse Recipes', 'My Recipes', 'Settings'];

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
            onPressed: () {},
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
          SettingsPage(),
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
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
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
            icon: Icons.settings_rounded,
            label: 'Settings',
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
                  'Budget: \$20.00 / meal',
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

const List<RecipeModel> _allRecipes = [
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

class _RecipeBrowserPage extends StatelessWidget {
  const _RecipeBrowserPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8B5A2B), size: 20),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text(
                  'All Recipes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_allRecipes.length} recipes',
                  style: const TextStyle(
                    color: Color(0xFF8B5A2B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          RecipeList(recipes: _allRecipes),
        ],
      ),
    );
  }
}
