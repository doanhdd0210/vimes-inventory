import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';

/// A titled card that groups related form fields.
class FormSection extends StatelessWidget {
  const FormSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A read-only label/value pair shown as a filled chip. Full width, and the
/// value wraps instead of being clipped so long names ("Công ty CP …") stay
/// readable.
class ReadonlyField extends StatelessWidget {
  const ReadonlyField({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Icon(icon, size: 16, color: context.colors.outline),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.colors.outline,
                  ),
                ),
                Text(
                  value.isEmpty ? '—' : value,
                  style: context.texts.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays two fields side by side when there is room, and stacks them once the
/// available width drops below [breakpoint] logical pixels — so a long value is
/// never squeezed into half a narrow screen or clipped.
class ResponsiveFieldPair extends StatelessWidget {
  const ResponsiveFieldPair({
    required this.first,
    required this.second,
    this.spacing = 12,
    this.breakpoint = 340,
    super.key,
  });

  final Widget first;
  final Widget second;
  final double spacing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: spacing),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
