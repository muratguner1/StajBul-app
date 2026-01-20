import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class LogService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void info(String message) {
    if (kDebugMode) {
      _logger.i(message);
    } else {
      FirebaseCrashlytics.instance.log('INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    } else {
      FirebaseCrashlytics.instance.log('WARNING: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);

    if (!kDebugMode) {
      FirebaseCrashlytics.instance
          .recordError(error, stackTrace, reason: message, fatal: false);
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }
}
