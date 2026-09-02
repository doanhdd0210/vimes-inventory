import 'flavor.dart';

/// Per-flavor values resolved once at startup and read everywhere via
/// [FlavorConfig.instance]. Set it up from a flavor entry point
/// (`main_dev.dart`, `main_staging.dart`, `main_prod.dart`) before `runApp`.
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.useFirebase,
    required this.enableLogging,
  });

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final bool useFirebase;
  final bool enableLogging;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    final value = _instance;
    assert(value != null, 'FlavorConfig.initialize() was not called');
    return value ?? _fallback();
  }

  static bool get isInitialized => _instance != null;

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;

  static FlavorConfig initialize({
    required Flavor flavor,
    String? appName,
    String? apiBaseUrl,
    String? firebaseProjectId,
    bool? useFirebase,
    bool? enableLogging,
  }) {
    final config = FlavorConfig._(
      flavor: flavor,
      appName: appName ?? _defaultAppName(flavor),
      apiBaseUrl: apiBaseUrl ?? _defaultApiBaseUrl(flavor),
      firebaseProjectId: firebaseProjectId ?? _defaultFirebaseProjectId(flavor),
      useFirebase: useFirebase ?? true,
      enableLogging: enableLogging ?? flavor != Flavor.prod,
    );
    _instance = config;
    return config;
  }

  static void reset() => _instance = null;

  static FlavorConfig _fallback() => FlavorConfig._(
    flavor: Flavor.dev,
    appName: _defaultAppName(Flavor.dev),
    apiBaseUrl: _defaultApiBaseUrl(Flavor.dev),
    firebaseProjectId: _defaultFirebaseProjectId(Flavor.dev),
    useFirebase: true,
    enableLogging: true,
  );

  static String _defaultAppName(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'VIMES Inventory Dev',
    Flavor.staging => 'VIMES Inventory Staging',
    Flavor.prod => 'VIMES Inventory',
  };

  static String _defaultApiBaseUrl(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'https://dev.api.vimes.example.com',
    Flavor.staging => 'https://staging.api.vimes.example.com',
    Flavor.prod => 'https://api.vimes.example.com',
  };

  static String _defaultFirebaseProjectId(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'vimes-inventory-dev',
    Flavor.staging => 'vimes-inventory-staging',
    Flavor.prod => 'vimes-inventory',
  };
}
