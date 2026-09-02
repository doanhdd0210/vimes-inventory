import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/flavors/flavor.dart';
import 'package:vimes_inventory/core/flavors/flavor_config.dart';

void main() {
  tearDown(FlavorConfig.reset);

  test('Flavor.fromName maps known names and defaults to dev', () {
    expect(Flavor.fromName('prod'), Flavor.prod);
    expect(Flavor.fromName('staging'), Flavor.staging);
    expect(Flavor.fromName('dev'), Flavor.dev);
    expect(Flavor.fromName('nonsense'), Flavor.dev);
    expect(Flavor.fromName(null), Flavor.dev);
  });

  test('initialize resolves per-flavor defaults', () {
    final config = FlavorConfig.initialize(flavor: Flavor.staging);

    expect(config.isStaging, isTrue);
    expect(config.appName, contains('Staging'));
    expect(config.apiBaseUrl, contains('staging'));
    expect(config.enableLogging, isTrue);
    expect(FlavorConfig.instance, same(config));
  });

  test('prod disables logging by default', () {
    final config = FlavorConfig.initialize(flavor: Flavor.prod);
    expect(config.enableLogging, isFalse);
  });

  test('firebaseTemporarilyDisabled forces useFirebase off', () {
    final config = FlavorConfig.initialize(
      flavor: Flavor.prod,
      useFirebase: true,
    );
    expect(
      config.useFirebase,
      isFalse,
      reason: 'temporary kill-switch must win over the per-call flag',
    );
    expect(FlavorConfig.firebaseTemporarilyDisabled, isTrue);
  });

  test('reset clears the singleton', () {
    FlavorConfig.initialize(flavor: Flavor.dev);
    expect(FlavorConfig.isInitialized, isTrue);
    FlavorConfig.reset();
    expect(FlavorConfig.isInitialized, isFalse);
  });
}
