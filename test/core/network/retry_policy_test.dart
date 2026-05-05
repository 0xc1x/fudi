import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/network/retry_policy.dart';
import 'package:fudi/core/error/network_exceptions.dart';
import 'package:fudi/core/error/payment_exceptions.dart';
import 'package:fudi/core/error/auth_exceptions.dart';
import 'package:fudi/core/error/business_exceptions.dart';

void main() {
  group('RetryPolicy', () {
    group('predefined policies', () {
      test('network policy has 3 max attempts', () {
        expect(RetryPolicy.network.maxAttempts, 3);
      });

      test('payment policy has 2 max attempts', () {
        expect(RetryPolicy.payment.maxAttempts, 2);
      });

      test('none policy has 1 max attempt', () {
        expect(RetryPolicy.none.maxAttempts, 1);
      });

      test('payment policy has longer initial delay than network', () {
        expect(
          RetryPolicy.payment.initialDelay,
          greaterThan(RetryPolicy.network.initialDelay),
        );
      });
    });

    group('isIdempotentMethod', () {
      test('GET is idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('GET'), true);
      });

      test('PUT is idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('PUT'), true);
      });

      test('DELETE is idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('DELETE'), true);
      });

      test('HEAD is idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('HEAD'), true);
      });

      test('OPTIONS is idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('OPTIONS'), true);
      });

      test('POST is NOT idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('POST'), false);
      });

      test('PATCH is NOT idempotent', () {
        expect(RetryPolicy.isIdempotentMethod('PATCH'), false);
      });

      test('case insensitive', () {
        expect(RetryPolicy.isIdempotentMethod('get'), true);
        expect(RetryPolicy.isIdempotentMethod('Post'), false);
      });
    });

    group('isRetryable', () {
      test('ConnectionException is retryable', () {
        expect(RetryPolicy.isRetryable(const ConnectionException()), true);
      });

      test('TimeoutException is retryable', () {
        expect(RetryPolicy.isRetryable(const TimeoutException()), true);
      });

      test('ServerException is retryable', () {
        expect(RetryPolicy.isRetryable(const ServerException()), true);
      });

      test('RateLimitException is retryable', () {
        expect(RetryPolicy.isRetryable(const RateLimitException()), true);
      });

      test('PaymentTimeoutException is retryable', () {
        expect(RetryPolicy.isRetryable(const PaymentTimeoutException()), true);
      });

      test('PaymentGatewayUnavailableException is retryable', () {
        expect(RetryPolicy.isRetryable(const PaymentGatewayUnavailableException()), true);
      });

      test('UnauthorizedException is NOT retryable', () {
        expect(RetryPolicy.isRetryable(const UnauthorizedException()), false);
      });

      test('PaymentRejectedException is NOT retryable', () {
        expect(RetryPolicy.isRetryable(const PaymentRejectedException()), false);
      });

      test('OfferUnavailableException is NOT retryable', () {
        expect(RetryPolicy.isRetryable(const OfferUnavailableException()), false);
      });
    });

    group('delayForAttempt', () {
      test('attempt 0 returns zero delay', () {
        expect(RetryPolicy.network.delayForAttempt(0), Duration.zero);
      });

      test('attempt 1 returns initial delay with jitter', () {
        final delay = RetryPolicy.network.delayForAttempt(1);
        expect(delay.inMilliseconds, greaterThanOrEqualTo(1000));
        expect(delay.inMilliseconds, lessThanOrEqualTo(1500));
      });

      test('delay increases with attempts (exponential)', () {
        final delay1 = RetryPolicy.network.delayForAttempt(1);
        final delay2 = RetryPolicy.network.delayForAttempt(2);
        expect(delay2.inMilliseconds, greaterThanOrEqualTo(delay1.inMilliseconds - 500));
      });

      test('delay is capped at maxDelay', () {
        final policy = RetryPolicy(
          maxAttempts: 20,
          initialDelay: const Duration(seconds: 1),
          backoffMultiplier: 10.0,
          maxDelay: const Duration(seconds: 30),
        );
        final delay = policy.delayForAttempt(10);
        expect(delay.inMilliseconds, lessThanOrEqualTo(30500));
      });
    });

    group('hasRetriesLeft', () {
      test('returns true when attempts remain', () {
        expect(RetryPolicy.network.hasRetriesLeft(0), true);
        expect(RetryPolicy.network.hasRetriesLeft(1), true);
        expect(RetryPolicy.network.hasRetriesLeft(2), true);
      });

      test('returns false when max attempts reached', () {
        expect(RetryPolicy.network.hasRetriesLeft(3), false);
        expect(RetryPolicy.network.hasRetriesLeft(4), false);
      });

      test('none policy has no retries after first attempt', () {
        expect(RetryPolicy.none.hasRetriesLeft(0), true);
        expect(RetryPolicy.none.hasRetriesLeft(1), false);
      });
    });
  });
}
