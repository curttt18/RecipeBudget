import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const _walnut = Color(0xFF8B5A2B);
const _walnutLight = Color(0xFFAD7244);


class _FaqItem {
  const _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

class _FaqSection {
  const _FaqSection({
    required this.icon,
    required this.category,
    required this.items,
  });
  final IconData icon;
  final String category;
  final List<_FaqItem> items;
}

const _sections = [
  _FaqSection(
    icon: Icons.info_outline_rounded,
    category: 'General Information',
    items: [
      _FaqItem(
        'What is Savr?',
        'Savr is a mobile application designed to bridge the gap between culinary creativity and financial clarity. We provide tools to help you discover great recipes, track ingredient costs, and manage your grocery budget so you can eat well without breaking the bank.',
      ),
      _FaqItem(
        'Is Savr free to use?',
        'Yes! The core features of Savr, including basic meal planning and budget tracking, are completely free. Our mission is to make accessible nutrition and smart budgeting available to everyone.',
      ),
      _FaqItem(
        'Do I need an internet connection to use the app?',
        'Savr requires an internet connection to sync your recipes, budgets, and account data securely to the cloud. However, you can still view your recently opened recipes and active grocery lists while offline.',
      ),
    ],
  ),
  _FaqSection(
    icon: Icons.shield_outlined,
    category: 'Account & Security',
    items: [
      _FaqItem(
        'How do I reset my password?',
        'If you forget your password, simply tap the "Forgot Password?" link on the login screen. Enter the email address associated with your account, and we will send you a secure link to create a new password.',
      ),
      _FaqItem(
        'Is my personal and financial data secure?',
        'Absolutely. We use industry-standard cloud infrastructure to securely store your data. Your passwords are encrypted, and we never sell your personal information or dietary preferences to third parties.',
      ),
      _FaqItem(
        'Can I delete my account and data?',
        'Yes. You can permanently delete your account and all associated data by navigating to Profile > Settings > Delete Account. Please note that this action cannot be undone.',
      ),
    ],
  ),
  _FaqSection(
    icon: Icons.restaurant_menu_outlined,
    category: 'Recipes & Budgeting',
    items: [
      _FaqItem(
        'How does the recipe budget calculator work?',
        'When you view or add a recipe, Savr calculates the estimated cost based on the individual ingredients and portion sizes. You can adjust the serving size, and the app will automatically update both the ingredient quantities and the projected cost.',
      ),
      _FaqItem(
        'Can I add my own family recipes to the app?',
        'Yes! You can manually input your own recipes, including the ingredients and instructions. Savr will help you calculate the cost per serving so you can see how your family favorites fit into your weekly budget.',
      ),
      _FaqItem(
        'How accurate are the ingredient prices?',
        'Savr uses a combination of regional average pricing and user-input data to estimate costs. For the most accurate budgeting, you can manually update the price of an ingredient if you find it cheaper at your local store.',
      ),
      _FaqItem(
        'Can I share my budget or recipes with a roommate or family member?',
        'Currently, accounts are individual. However, you can easily export your grocery list or share a link to a specific recipe with anyone outside the app.',
      ),
    ],
  ),
  _FaqSection(
    icon: Icons.support_agent_outlined,
    category: 'Support & Troubleshooting',
    items: [
      _FaqItem(
        'The app is running slowly or crashing. What should I do?',
        'First, ensure you have the latest version of Savr installed from the app store. If the issue persists, try logging out and logging back in, or restarting your device.',
      ),
      _FaqItem(
        'I have an idea for a new feature. How can I share it?',
        'We are built on a foundation of continuous mastery and love hearing from our users! If you have a feature request or feedback, please email our development team directly at support@savrapp.com.',
      ),
    ],
  ),
];


class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _walnut, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & FAQ',
          style: TextStyle(
            color: AppColors.of(context).onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.of(context).border),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: _sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 28),
        itemBuilder: (_, i) => _SectionBlock(section: _sections[i]),
      ),
    );
  }
}


class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});
  final _FaqSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.of(context).chipBg,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.of(context).chipBorder, width: 1),
              ),
              child: Icon(section.icon, color: _walnut, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              section.category.toUpperCase(),
              style: const TextStyle(
                color: _walnut,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.of(context).border, width: 1),
          ),
          child: Column(
            children: section.items
                .asMap()
                .entries
                .map(
                  (e) => Column(
                    children: [
                      _FaqTile(item: e.value),
                      if (e.key < section.items.length - 1)
                        Divider(
                          height: 1,
                          color: AppColors.of(context).divider,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}


class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item});
  final _FaqItem item;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(16),
      splashColor: _walnut.withValues(alpha: 0.08),
      highlightColor: _walnut.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TextStyle(
                      color: _expanded ? _walnutLight : AppColors.of(context).onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: _expanded ? _walnut : AppColors.of(context).subtext,
                    size: 22,
                  ),
                ),
              ],
            ),
            SizeTransition(
              sizeFactor: _fadeAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 30),
                  child: Text(
                    widget.item.answer,
                    style: TextStyle(
                      color: AppColors.of(context).subtext,
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
