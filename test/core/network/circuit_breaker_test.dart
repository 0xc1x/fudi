import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/network/circuit_breaker.dart';
import 'package:fudi/core/error/network_exceptions.dart';

void main() {
  group('CircuitBreaker', () {
    late CircuitBreaker circuitBreaker;

    setUp(() {
      circuitBreaker = CircuitBreaker(
        failureThreshold: 3,
        resetTimeout: const Duration(milliseconds: 100),
      );
    });

    group('initial state', () {
      test('starts in closed state', () {
        expect(circuitBreaker.state, CircuitState.closed);
      });

      test('failure count starts at zero', () {
        expect(circuitBreaker.failureCount, 0);
      });
    });

    group('closed state', () {
      test('successful operation stays closed', () async {
        final result = await circuitBreaker.execute(() => Future.value(42));
        expect(result, 42);
        expect(circuitBreaker.state, CircuitState.closed);
        expect(circuitBreaker.failureCount, 0);
      });

      test(
        'failure increments count but stays closed under threshold',
        () async {
          try {
            await circuitBreaker.execute(
              () => Future.error(const ConnectionException()),
            );
          } on ConnectionException {
            // expected
          }
          expect(circuitBreaker.failureCount, 1);
          expect(circuitBreaker.state, CircuitState.closed);
        },
      );

      test('reaches threshold and opens circuit', () async {
        for (var i = 0; i < 3; i++) {
          try {
            await circuitBreaker.execute(
              () => Future.error(const ConnectionException()),
            );
          } on ConnectionException {
            // expected
          }
        }
        expect(circuitBreaker.state, CircuitState.open);
        expect(circuitBreaker.failureCount, 3);
      });
    });

    group('open state', () {
      setUp(() async {
        for (var i = 0; i < 3; i++) {
          try {
            await circuitBreaker.execute(
              () => Future.error(const ConnectionException()),
            );
          } on ConnectionException {
            // expected
          }
        }
      });

      test('rejects requests immediately when open', () async {
        expect(circuitBreaker.state, CircuitState.open);
        expect(
          () => circuitBreaker.execute(() => Future.value(42)),
          throwsA(isA<ServerException>()),
        );
      });

      test('transitions to half-open after reset timeout', () async {
        expect(circuitBreaker.state, CircuitState.open);
        await Future.delayed(const Duration(milliseconds: 150));
        final result = await circuitBreaker.execute(() => Future.value(42));
        expect(result, 42);
        expect(circuitBreaker.state, CircuitState.closed);
      });
    });

    group('half-open state', () {
      setUp(() async {
        for (var i = 0; i < 3; i++) {
          try {
            await circuitBreaker.execute(
              () => Future.error(const ConnectionException()),
            );
          } on ConnectionException {
            // expected
          }
        }
        await Future.delayed(const Duration(milliseconds: 150));
      });

      test('successful probe closes the circuit', () async {
        final result = await circuitBreaker.execute(() => Future.value('ok'));
        expect(result, 'ok');
        expect(circuitBreaker.state, CircuitState.closed);
        expect(circuitBreaker.failureCount, 0);
      });

      test('failed probe reopens the circuit', () async {
        try {
          await circuitBreaker.execute(
            () => Future.error(const ConnectionException()),
          );
        } on ConnectionException {
          // expected
        }
        expect(circuitBreaker.state, CircuitState.open);
      });
    });

    group('reset', () {
      test('manual reset returns to closed state', () async {
        for (var i = 0; i < 3; i++) {
          try {
            await circuitBreaker.execute(
              () => Future.error(const ConnectionException()),
            );
          } on ConnectionException {
            // expected
          }
        }
        expect(circuitBreaker.state, CircuitState.open);

        circuitBreaker.reset();
        expect(circuitBreaker.state, CircuitState.closed);
        expect(circuitBreaker.failureCount, 0);
      });
    });

    group('custom configuration', () {
      test('respects custom failure threshold', () async {
        final cb = CircuitBreaker(
          failureThreshold: 5,
          resetTimeout: const Duration(seconds: 30),
        );
        for (var i = 0; i < 4; i++) {
          try {
            await cb.execute(() => Future.error(const ConnectionException()));
          } on ConnectionException {
            // expected
          }
        }
        expect(cb.state, CircuitState.closed);
        await cb
            .execute(() => Future.error(const ConnectionException()))
            .catchError((_) => 0);
        expect(cb.state, CircuitState.open);
      });
    });
  });
}
