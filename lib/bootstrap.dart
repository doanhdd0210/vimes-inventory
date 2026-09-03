import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/flavors/flavor.dart';
import 'core/flavors/flavor_config.dart';
import 'core/helpers/app_logger.dart';
import 'features/auth/presentation/auth_cubit.dart';

/// Single composition root shared by every flavor entry point.
Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final config = FlavorConfig.initialize(flavor: flavor);
      AppLogger.instance.enabled = config.enableLogging;
      AppLogger.instance.i('Booting ${config.appName} (${flavor.name})');

      final firebaseReady = config.useFirebase
          ? await FirebaseBootstrap.ensureInitialized()
          : false;

      await configureDependencies(useFirebase: firebaseReady);

      // Instantiate the auth holder now so it is listening before the router
      // reads it for the first redirect.
      sl<AuthCubit>();

      FlutterError.onError = (details) {
        AppLogger.instance.e(
          details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };

      runApp(const VimesApp());
    },
    (error, stackTrace) => AppLogger.instance.e(
      'Uncaught zone error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}
