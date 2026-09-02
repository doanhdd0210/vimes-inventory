import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Thin logging wrapper. Silent in release unless [forceEnabled]; swap the
/// implementation for Crashlytics / Sentry without touching call sites.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  bool enabled = kDebugMode;

  void d(Object? message) => _log(LogLevel.debug, message);
  void i(Object? message) => _log(LogLevel.info, message);
  void w(Object? message) => _log(LogLevel.warning, message);

  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) return;
    developer.log(
      '$message',
      name: 'vimes.${level.name}',
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}
