import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Shared, context-free style fragments (decorations, shadows, gradients) used
/// across features so custom containers stay visually consistent.
class AppStyles {
  const AppStyles._();

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static BoxDecoration card({Color? color}) => BoxDecoration(
    color: color ?? AppColors.neutral0,
    borderRadius: AppRadius.allMd,
    boxShadow: cardShadow,
  );

  static BoxDecoration outlined({Color? borderColor}) => BoxDecoration(
    color: AppColors.neutral0,
    borderRadius: AppRadius.allMd,
    border: Border.all(color: borderColor ?? AppColors.neutral300),
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );
}
