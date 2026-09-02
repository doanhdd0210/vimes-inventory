import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// e.g. 02/09/2026
  String get asDate => DateFormat('dd/MM/yyyy').format(this);

  /// e.g. 02/09/2026 13:45
  String get asDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  String get asIso => toUtc().toIso8601String();

  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return asDate;
  }
}
