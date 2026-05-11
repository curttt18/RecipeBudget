import 'package:flutter/material.dart';

const _charcoal = Color(0xFF2C2C2C);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'My Saved Recipes',
              style: TextStyle(
                color: _white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recipes you\'ve bookmarked for later.',
              style: TextStyle(color: _grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _buildTabRow(),
            const SizedBox(height: 32),
            _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabRow() {
    return Row(
      children: [
        _TabChip(label: 'Saved', selected: true),
        const SizedBox(width: 10),
        _TabChip(label: 'Cooked', selected: false),
        const SizedBox(width: 10),
        _TabChip(label: 'Planned', selected: false),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _charcoal,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                color: _walnut, size: 44),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nothing saved yet',
            style: TextStyle(
              color: _white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the bookmark icon on any recipe\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _grey, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 180,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'Browse Recipes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _walnut,
                foregroundColor: _white,
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

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? _walnut : _charcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? _walnut : const Color(0xFF3A3A3A),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _white : _grey,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
