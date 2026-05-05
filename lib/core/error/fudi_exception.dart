import 'package:meta/meta.dart';

/// Severity levels for Fudi exceptions.
///
/// Used by Sentry for alerting and by the UI to decide presentation style.
enum ErrorSeverity {
  /// Transient issue — retry is likely to succeed. UI: SnackBar.
  low,

  /// Feature-blocking but not app-breaking. UI: Dialog with alternative action.
  medium,

  /// App-breaking or data-loss risk. UI: Full-screen error.
  high,

  /// Unrecoverable crash. UI: Error screen with restart.
  fatal,
}

/// Base: Every Fudi error inherits from here.
///
/// It follows the guidelines in docs/ai/ERROR_HANDLING.md:
/// - Classifiable: Via its type and hierarchy + [severity] + [feature].
/// - Traceable: Via the [code] and [context] for Sentry.
/// - Actionable: Via the `userMessage` extension and `recovery` extension.
@immutable
sealed class FudiException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic> context;
  final ErrorSeverity severity;
  final String feature;

  const FudiException({
    required this.message,
    this.code,
    this.context = const {},
    this.severity = ErrorSeverity.medium,
    this.feature = 'core',
  });

  @override
  String toString() => 'FudiException(code: $code, severity: $severity, feature: $feature, message: $message)';
}
