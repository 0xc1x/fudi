import 'package:meta/meta.dart';

/// Base: Every Fudi error inherits from here.
///
/// It follows the guidelines in docs/ai/ERROR_HANDLING.md:
/// - Classifiable: Via its type and hierarchy.
/// - Traceable: Via the code and context for Sentry.
/// - Actionable: Via the userMessage and recovery suggestions.
@immutable
sealed class FudiException implements Exception {
  final String message;
  final String? code; // Stable code for searching in Sentry/Logs
  final Map<String, dynamic> context; // Additional structured context

  const FudiException({
    required this.message,
    this.code,
    this.context = const {},
  });

  @override
  String toString() => 'FudiException(code: $code, message: $message, context: $context)';
}
