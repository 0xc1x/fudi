import 'package:sentry_flutter/sentry_flutter.dart';

import '../error/fudi_exception.dart';

/// Utility for capturing errors with structured context in Sentry.
///
/// Follows docs/ai/ERROR_HANDLING.md:
/// - Captures FudiException with typed context
/// - Tags errors with their stable code for searchability
/// - Supports both exception and message capture
class FudiErrorReporter {
  /// Captures a FudiException with its typed context.
  static Future<void> captureException(
    FudiException exception, {
    SentryLevel level = SentryLevel.error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extraContext,
  }) async {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: {'level': level},
    );

    // Tag with the error code for searchability in Sentry
    if (exception.code != null) {
      Sentry.configureScope((scope) {
        scope.setTag('error_code', exception.code!);
      });
    }
  }

  /// Captures a non-exception message (warnings, info).
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.warning,
    String? category,
  }) async {
    Sentry.captureMessage(
      message,
      level: level,
    );
  }
}
