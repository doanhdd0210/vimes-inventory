import 'bootstrap.dart';
import 'core/flavors/flavor.dart';

/// Default entry point (plain `flutter run`). Mirrors `main_dev.dart`.
/// Pick a flavor explicitly with `-t`:
///   flutter run -t lib/main_dev.dart
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_prod.dart
/// (No `--flavor` needed — flavors are Dart-level in this base. Add native
/// product flavors / iOS schemes only when you need per-env app IDs.)
Future<void> main() => bootstrap(Flavor.dev);
