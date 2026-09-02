import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../helpers/app_logger.dart';

/// Initialises Firebase once. If `firebase_options.dart` has not been generated
/// yet (`flutterfire configure`), initialisation is skipped and [isAvailable]
/// stays false so the DI container wires the in-memory datasources instead.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialised = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<bool> ensureInitialized() async {
    if (_initialised) return _available;
    _initialised = true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _available = true;
    } catch (error, stackTrace) {
      _available = false;
      AppLogger.instance.w(
        'Firebase not initialised — running with local datasources. '
        'Cause: $error',
      );
      AppLogger.instance.d(stackTrace);
    }
    return _available;
  }
}
