// PLACEHOLDER — replace by running:
//
//   firebase login --reauth        # current CLI token is expired
//   flutterfire configure \
//     --project=<your-firebase-project> \
//     --out=lib/firebase_options.dart \
//     --platforms=android,ios
//
// Until then [DefaultFirebaseOptions.currentPlatform] throws and
// `FirebaseBootstrap.ensureInitialized()` falls back to the in-memory
// datasources so the app still runs.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(_notConfigured('web'));
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(_notConfigured('android'));
      case TargetPlatform.iOS:
        throw UnsupportedError(_notConfigured('ios'));
      default:
        throw UnsupportedError(_notConfigured(defaultTargetPlatform.name));
    }
  }

  static String _notConfigured(String platform) =>
      'FirebaseOptions for $platform are not configured. '
      'Run `flutterfire configure` to generate lib/firebase_options.dart.';
}
