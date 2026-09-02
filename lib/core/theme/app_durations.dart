/// Standard animation / debounce durations.
class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Duration debounce = Duration(milliseconds: 350);
  static const Duration snackbar = Duration(seconds: 3);
}
