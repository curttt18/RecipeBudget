import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetSlider extends StatelessWidget {
  const BudgetSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1.0,
    this.max = 50.0,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFF8B5A2B),
        inactiveTrackColor: AppColors.of(context).border,
        thumbColor: const Color(0xFF8B5A2B),
        overlayColor: const Color(0x268B5A2B),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        onChanged: onChanged,
      ),
    );
  }
}
