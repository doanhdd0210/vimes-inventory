import 'package:flutter/material.dart';

/// Raw brand palette. UI code should prefer `Theme.of(context).colorScheme`;
/// these are for seeding the scheme and for the few brand-fixed accents.
///
/// Colours follow the VIMES identity (vimes.com.vn): a cyan→teal gradient mark
/// on deep-navy ink.
class AppColors {
  const AppColors._();

  /// VIMES teal — primary brand colour.
  static const Color primary = Color(0xFF0F97AE);
  static const Color primaryDark = Color(0xFF0B6E80);

  /// Lighter aqua — top of the logo gradient.
  static const Color brandTealLight = Color(0xFF19C3D6);

  /// Deep navy ink — wordmark / dark CTAs.
  static const Color brandNavy = Color(0xFF0B2536);

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
