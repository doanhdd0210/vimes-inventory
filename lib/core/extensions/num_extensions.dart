import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension NumX on num {
  /// 1234567 -> "1.234.567 ₫"
  String get asCurrencyVnd => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  ).format(this);

  /// 1234567 -> "1.234.567"
  String get asDecimal => NumberFormat.decimalPattern('vi_VN').format(this);

  String asCompact() => NumberFormat.compact(locale: 'vi_VN').format(this);

  Duration get ms => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());

  /// Vertical gap: `12.gapH`
  SizedBox get gapH => SizedBox(height: toDouble());

  /// Horizontal gap: `12.gapW`
  SizedBox get gapW => SizedBox(width: toDouble());
}
