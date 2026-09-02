import 'package:flutter/material.dart';

/// Raw brand palette. UI code should prefer `Theme.of(context).colorScheme`;
/// these are for seeding the scheme and for the few brand-fixed accents.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF003D33);
  static const Color secondary = Color(0xFFFFB300);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF7F8FA);
  static const Color neutral100 = Color(0xFFEEF0F3);
  static const Color neutral300 = Color(0xFFCBD2D9);
  static const Color neutral500 = Color(0xFF7B8794);
  static const Color neutral700 = Color(0xFF3E4C59);
  static const Color neutral900 = Color(0xFF1F2933);
}
