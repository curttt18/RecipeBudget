import 'package:flutter/material.dart';

const _black = Color(0xFF1A1A1A);
const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _walnutLight = Color(0xFFAD7244);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);
const _greyDark = Color(0xFF3A3A3A);

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _walnut, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Savr',
          style: TextStyle(
            color: _white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _greyDark),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            _buildDivider(),
            _buildSection(
              icon: Icons.menu_book_rounded,
              title: 'Our Story',
              child: _buildStory(),
            ),
            _buildDivider(),
            _buildSection(
              icon: Icons.diamond_outlined,
              title: 'Core Values',
              child: _buildCoreValues(),
            ),
            _buildDivider(),
            _buildSection(
              icon: Icons.groups_rounded,
              title: 'Meet the Team',
              child: _buildTeam(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF222222), _black],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _walnut, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x508B5A2B),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/mainlogo.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Savr',
            style: TextStyle(
              color: _white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF4A3020), width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFF261508),
            ),
            child: const Text(
              'Savor the meal.  Save the money.',
              style: TextStyle(
                color: _walnutLight,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Version 1.0.0',
            style: TextStyle(color: _grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF261508),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFF4A3020), width: 1),
                ),
                child: Icon(icon, color: _walnut, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: _walnut,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Our Story ─────────────────────────────────────────────────────────────

  Widget _buildStory() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _greyDark, width: 1),
      ),
      child: const Text(
        'We believe that eating well shouldn\'t require sacrificing your financial goals. '
        'Savr was born out of a simple frustration: it is incredibly difficult to plan meals, '
        'track ingredient costs, and stay on budget without sacrificing flavor or nutrition.\n\n'
        'We built Savr to bridge the gap between culinary creativity and financial clarity. '
        'Whether you are a student stretching a weekly allowance or a household looking to '
        'optimize grocery spending, Savr provides the tools you need to make smart, '
        'data-driven decisions in the kitchen.',
        style: TextStyle(
          color: _grey,
          fontSize: 13.5,
          height: 1.75,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Core Values ───────────────────────────────────────────────────────────

  Widget _buildCoreValues() {
    return Column(
      children: [
        _ValueCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Continuous Mastery',
          body: 'We are dedicated to constantly refining our craft — from the code that powers '
              'our application to the user experience we deliver. We believe in growth, '
              'authenticity, and pushing the boundaries of our technical skills.',
        ),
        const SizedBox(height: 12),
        _ValueCard(
          icon: Icons.restaurant_menu_rounded,
          title: 'Accessible Nutrition',
          body: 'Great food and smart budgeting should be accessible to everyone, '
              'not just financial experts or professional chefs.',
        ),
        const SizedBox(height: 12),
        _ValueCard(
          icon: Icons.insights_rounded,
          title: 'Empowerment Through Data',
          body: 'We give you the numbers you need to take control of your plate '
              'and your wallet.',
        ),
      ],
    );
  }

  // ── Team ─────────────────────────────────────────────────────────────────

  Widget _buildTeam() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            'Savr is built by a dedicated team of developers passionate about creating '
            'meaningful, full-stack mobile solutions.',
            style: TextStyle(color: _grey, fontSize: 13, height: 1.6),
          ),
        ),
        _TeamCard(
          initials: 'AJ',
          name: 'Angelo Jacob Valeros',
          role: 'Lead Developer',
          description:
              'Focused on front-end engineering, full-stack integration, and continuous '
              'technical mastery, ensuring Savr delivers a seamless, high-performance experience.',
        ),
        const SizedBox(height: 12),
        _TeamCard(
          initials: 'JA',
          name: 'Julian Alfonso Cabansag',
          role: 'Backend Developer',
          description:
              'Driving the database synchronization and backend architecture to keep your '
              'recipes, budgets, and saved data secure and accessible.',
        ),
        const SizedBox(height: 12),
        _TeamCard(
          initials: 'SC',
          name: 'Steven Curt Reyes',
          role: 'QA, Deployment & Documentation',
          description:
              'Collaborating across the stack to document core features, optimize the user '
              'journey, test features, and bring the Savr vision to life.',
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        children: [
          const Divider(color: _greyDark, thickness: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant, color: _walnut, size: 14),
              const SizedBox(width: 8),
              Text(
                'Made with care by the Savr Team · 2025',
                style: TextStyle(
                  color: _grey.withAlpha(160),
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF252525),
      thickness: 1,
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}

// ── Value Card ────────────────────────────────────────────────────────────────

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyDark, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF261508),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF4A3020), width: 1),
            ),
            child: Icon(icon, color: _walnut, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 12.5,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Team Card ─────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.initials,
    required this.name,
    required this.role,
    required this.description,
  });

  final String initials;
  final String name;
  final String role;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3A2010),
                  border: Border.all(color: _walnut, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: _walnutLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261508),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF4A3020), width: 1),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color: _walnutLight,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: _grey,
              fontSize: 12.5,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
