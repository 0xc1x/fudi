import 'dart:math';

import '../error/network_exceptions.dart';
import '../error/payment_exceptions.dart';

/// Retry policy with exponential backoff.
///
/// Follows docs/ai/ERROR_HANDLING.md:
/// - 3 retries max for network operations
/// - 2 retries for payment operations (more conservative)
/// - Only retries idempotent HTTP methods (GET, PUT, DELETE)
/// - Exponential backoff: 1s → 2s → 4s (capped at maxDelay)
/// - Jitter to avoid thundering herd on shared services
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });

  /// Standard network retry policy — 3 attempts, 1s initial, 2x backoff.
  static const network = RetryPolicy(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
  );

  /// Payment retry policy — more conservative, 2 attempts, 2s initial.
  static const payment = RetryPolicy(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 3.0,
  );

  /// No retry — for non-idempotent or fast-fail operations.
  static const none = RetryPolicy(
    maxAttempts: 1,
    initialDelay: Duration.zero,
  );

  /// Whether the given HTTP method is idempotent and safe to retry.
  ///
  /// POST is NOT idempotent — creating a resource twice is different
  /// from creating it once. GET, PUT, DELETE are safe to retry.
  static bool isIdempotentMethod(String method) {
    const idempotent = {'GET', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'};
    return idempotent.contains(method.toUpperCase());
  }

  /// Whether the given exception is retryable.
  ///
  /// Connection and timeout errors are always retryable.
  /// Server errors (5xx) are retryable.
  /// Rate limits are retryable (after backoff).
  /// Payment timeouts are retryable with the payment policy.
  static bool isRetryable(Exception e) {
    return switch (e) {
      ConnectionException() => true,
      TimeoutException() => true,
      ServerException() => true,
      RateLimitException() => true,
      PaymentTimeoutException() => true,
      PaymentGatewayUnavailableException() => true,
      _ => false,
    };
  }

  /// Calculates the delay before the next retry attempt.
  ///
  /// Uses exponential backoff with jitter:
  /// delay = min(initialDelay * multiplier^attempt, maxDelay) + jitter
  ///
  /// Jitter is a random value between 0 and 500ms to prevent
  /// synchronized retry storms across multiple clients.
  Duration delayForAttempt(int attempt) {
    if (attempt <= 0) return Duration.zero;

    final exponentialDelay = initialDelay *
        pow(backoffMultiplier, attempt - 1).toInt();
    final cappedDelay = exponentialDelay > maxDelay ? maxDelay : exponentialDelay;

    // Add jitter: random 0–500ms
    final jitter = Random().nextInt(500);
    return Duration(milliseconds: cappedDelay.inMilliseconds + jitter);
  }

  /// Whether more retries are available for the given attempt number.
  bool hasRetriesLeft(int currentAttempt) => currentAttempt < maxAttempts;
}
