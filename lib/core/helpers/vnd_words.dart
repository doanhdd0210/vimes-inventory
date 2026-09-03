/// Converts a VND amount to Vietnamese words — for the "Tổng số tiền
/// (viết bằng chữ)" line of accounting forms.
///
/// ```dart
/// VndWords.of(1234000); // 'Một triệu hai trăm ba mươi tư nghìn đồng'
/// VndWords.of(0);        // 'Không đồng'
/// ```
class VndWords {
  const VndWords._();

  static const _digits = [
    'không',
    'một',
    'hai',
    'ba',
    'bốn',
    'năm',
    'sáu',
    'bảy',
    'tám',
    'chín',
  ];

  /// Scale words for each 3-digit group, least significant first.
  static const _scales = ['', 'nghìn', 'triệu', 'tỷ'];

  static String of(num amount) {
    final rounded = amount.round();
    if (rounded == 0) return 'Không đồng';

    final negative = rounded < 0;
    var n = rounded.abs();

    // Split into 3-digit groups, least significant first.
    final groups = <int>[];
    while (n > 0) {
      groups.add(n % 1000);
      n ~/= 1000;
    }

    final parts = <String>[];
    for (var i = groups.length - 1; i >= 0; i--) {
      final group = groups[i];
      if (group == 0) continue;

      final words = _threeDigits(group, forceHundreds: i != groups.length - 1);
      final scale = _scaleFor(i);
      parts.add(scale.isEmpty ? words : '$words $scale');
    }

    final joined = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    final text = '${negative ? 'Âm ' : ''}$joined đồng';
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _scaleFor(int groupIndex) {
    if (groupIndex < _scales.length) return _scales[groupIndex];
    // 4th group and beyond: "tỷ", "nghìn tỷ", "triệu tỷ", "tỷ tỷ", ...
    final billions = groupIndex ~/ 3;
    final remainder = groupIndex % 3;
    final head = _scales[remainder];
    final tail = List.filled(billions, 'tỷ').join(' ');
    return head.isEmpty ? tail : '$head $tail';
  }

  static String _threeDigits(int value, {required bool forceHundreds}) {
    final hundreds = value ~/ 100;
    final tens = (value % 100) ~/ 10;
    final units = value % 10;
    final buffer = <String>[];

    if (hundreds > 0 || forceHundreds) {
      buffer
        ..add(_digits[hundreds])
        ..add('trăm');
    }

    if (tens == 0) {
      if (units > 0 && buffer.isNotEmpty) buffer.add('lẻ');
      if (units > 0) buffer.add(_digits[units]);
    } else if (tens == 1) {
      buffer.add('mười');
      if (units == 1) {
        buffer.add('một');
      } else if (units == 5) {
        buffer.add('lăm');
      } else if (units > 0) {
        buffer.add(_digits[units]);
      }
    } else {
      buffer
        ..add(_digits[tens])
        ..add('mươi');
      if (units == 1) {
        buffer.add('mốt');
      } else if (units == 4) {
        buffer.add('tư');
      } else if (units == 5) {
        buffer.add('lăm');
      } else if (units > 0) {
        buffer.add(_digits[units]);
      }
    }

    return buffer.join(' ');
  }
}
