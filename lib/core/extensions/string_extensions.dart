extension StringX on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;

  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(
    RegExp(r'\s+'),
  ).where((w) => w.isNotEmpty).map((w) => w.capitalized).join(' ');

  String truncate(int max, {String ellipsis = '…'}) =>
      length <= max ? this : '${substring(0, max).trimRight()}$ellipsis';

  String? get nullIfBlank => isBlank ? null : this;

  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(trim());
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  bool get isNotNullOrBlank => !isNullOrBlank;
  String orEmpty() => this ?? '';
}
