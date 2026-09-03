import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thin wrapper over [TextFormField] with a consistent label + external error
/// string (errors come from the bloc, not a [Form]).
class ReceiptField extends StatelessWidget {
  const ReceiptField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.hintText,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final int maxLines;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}

/// Allows digits plus one separator (`.` or `,`) for quantity / price entry.
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 3});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty) return newValue.copyWith(text: '');
    final regex = RegExp(
      r'^\d*\.?\d{0,'
      '$decimalRange'
      r'}$',
    );
    if (!regex.hasMatch(text)) return oldValue;
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Parses a user-typed number, tolerating `,` as the decimal mark and grouping
/// dots. Returns null for blank / unparseable.
num? parseNum(String raw) {
  final cleaned = raw.trim().replaceAll(' ', '');
  if (cleaned.isEmpty) return null;
  // "1.234,5" (vi grouping) or "1234.5"
  final normalised = cleaned.contains(',')
      ? cleaned.replaceAll('.', '').replaceAll(',', '.')
      : cleaned;
  return num.tryParse(normalised);
}
