/// App-wide constant values that are not flavor-specific.
class AppConstants {
  const AppConstants._();

  static const Duration httpTimeout = Duration(seconds: 30);
  static const Duration cacheTtl = Duration(minutes: 5);

  static const int pageSize = 20;
  static const int maxRetries = 3;

  static const String defaultLocale = 'vi_VN';
  static const String currencySymbol = '₫';
}
