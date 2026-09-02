import 'bootstrap.dart';
import 'core/flavors/flavor.dart';

/// Default entry point (used by `flutter run` without `--target`). Mirrors
/// `main_dev.dart`. Use the flavor-specific entry points for real builds:
///   flutter run --flavor dev     -t lib/main_dev.dart
///   flutter run --flavor staging -t lib/main_staging.dart
///   flutter run --flavor prod    -t lib/main_prod.dart
Future<void> main() => bootstrap(Flavor.dev);
