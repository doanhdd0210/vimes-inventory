import 'package:flutter/material.dart';

/// Type ramp used to build the [TextTheme]. Prefer
/// `Theme.of(context).textTheme.*` in widgets; reach for these only when you
/// need a style outside a [BuildContext].
class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Roboto';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextTheme textThemeFor(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return base.copyWith(
      displayLarge: base.displayLarge?.merge(displayLarge),
      titleLarge: base.titleLarge?.merge(titleLarge),
      titleMedium: base.titleMedium?.merge(titleMedium),
      bodyLarge: base.bodyLarge?.merge(bodyLarge),
      bodyMedium: base.bodyMedium?.merge(bodyMedium),
      labelLarge: base.labelLarge?.merge(labelLarge),
      bodySmall: base.bodySmall?.merge(caption),
    );
  }
}
