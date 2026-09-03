import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// VIMES brand mark — a cyan→teal gradient rounded square with a stacked-layers
/// glyph, optionally followed by the "VIMES" wordmark. Drawn in code (not a
/// bitmap) so it stays crisp at any size and ships no asset.
class VimesLogo extends StatelessWidget {
  const VimesLogo({this.size = 40, this.showWordmark = false, super.key});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandTealLight, AppColors.primaryDark],
        ),
      ),
      child: Icon(Icons.layers_rounded, size: size * 0.56, color: Colors.white),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.34),
        Text(
          'VIMES',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.03,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
