import 'package:flutter/material.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
final budgetNotifier = ValueNotifier<double>(100.0);

class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.accent,
    required this.accentLight,
    required this.onSurface,
    required this.subtext,
    required this.border,
    required this.modal,
    required this.divider,
    required this.chipBg,
    required this.chipBorder,
    required this.drawerBg,
    required this.drawerCard,
    required this.drawerCardBorder,
    required this.drawerText,
    required this.drawerNavSelected,
    required this.drawerNavNormal,
    required this.drawerDivider,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color accent;
  final Color accentLight;
  final Color onSurface;
  final Color subtext;
  final Color border;
  final Color modal;
  final Color divider;
  final Color chipBg;
  final Color chipBorder;
  final Color drawerBg;
  final Color drawerCard;
  final Color drawerCardBorder;
  final Color drawerText;
  final Color drawerNavSelected;
  final Color drawerNavNormal;
  final Color drawerDivider;

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const dark = AppColors(
    background: Color(0xFF1A1A1A),
    surface: Color(0xFF2C2C2C),
    surfaceVariant: Color(0xFF242424),
    accent: Color(0xFF8B5A2B),
    accentLight: Color(0xFFAD7244),
    onSurface: Colors.white,
    subtext: Color(0xFF9E9E9E),
    border: Color(0xFF3A3A3A),
    modal: Color(0xFF1E1E1E),
    divider: Color(0xFF333333),
    chipBg: Color(0xFF261508),
    chipBorder: Color(0xFF4A3020),
    drawerBg: Color(0xFF2B1A0A),
    drawerCard: Color(0xFF3A2410),
    drawerCardBorder: Color(0xFF5A3515),
    drawerText: Color(0xFFF0DEC8),
    drawerNavSelected: Color(0xFFCE9B6E),
    drawerNavNormal: Color(0xFFB09070),
    drawerDivider: Color(0xFF4A2810),
  );

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF2F2F2),
    surfaceVariant: Color(0xFFE8E8E8),
    accent: Color(0xFF8B5A2B),
    accentLight: Color(0xFF8B5A2B),
    onSurface: Color(0xFF1A1A1A),
    subtext: Color(0xFF666666),
    border: Color(0xFFDDDDDD),
    modal: Color(0xFFFFFFFF),
    divider: Color(0xFFE0E0E0),
    chipBg: Color(0xFFFFF3E8),
    chipBorder: Color(0xFFD4A07A),
    drawerBg: Color(0xFFF5EDE0),
    drawerCard: Color(0xFFEDD9BD),
    drawerCardBorder: Color(0xFFD4A07A),
    drawerText: Color(0xFF3A1A00),
    drawerNavSelected: Color(0xFF5C2E00),
    drawerNavNormal: Color(0xFF7A4520),
    drawerDivider: Color(0xFFD4A07A),
  );
}

ThemeData buildDarkTheme() => ThemeData(
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.accent,
        brightness: Brightness.dark,
      ).copyWith(surface: AppColors.dark.surface),
    );

ThemeData buildLightTheme() => ThemeData(
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.accent,
        brightness: Brightness.light,
      ).copyWith(surface: AppColors.light.surface),
    );
