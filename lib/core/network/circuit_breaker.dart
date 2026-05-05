import '../error/network_exceptions.dart';

/// Circuit Breaker pattern implementation.
///
/// Prevents cascading failures by stopping calls to a failing service.
///
/// State machine:
/// - **Closed**: Normal operation. Requests go through. Failures are counted.
///   After [failureThreshold] consecutive failures, transitions to Open.
///
/// - **Open**: All requests are rejected immediately with
///   [ServiceUnavailableException]. After [resetTimeout], transitions
///   to Half-Open.
///
/// - **Half-Open**: A single probe request is allowed. If it succeeds,
///   the circuit closes (resets). If it fails, the circuit opens again.
///
/// Follows docs/ai/ERROR_HANDLING.md:
/// - 5 failures → open for 30s → half-open
/// - Throws ServiceUnavailableException when open
class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  int _halfOpenAttempts = 0;

  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 30),
  });

  /// Current state of the circuit. Exposed for observability / testing.
  CircuitState get state => _state;

  /// Number of consecutive failures recorded. Exposed for observability.
  int get failureCount => _failureCount;

  /// Executes [operation] through the circuit breaker.
  ///
  /// - If the circuit is **closed**, the operation runs normally.
  /// - If the circuit is **open**, checks if [resetTimeout] has elapsed:
  ///   - Yes → transitions to half-open and allows one probe.
  ///   - No → throws [ServiceUnavailableException].
  /// - If the circuit is **half-open**, allows one attempt:
  ///   - Success → closes the circuit.
  ///   - Failure → reopens the circuit.
  Future<T> execute<T>(Future<T> Function() operation) async {
    _updateState();

    if (_state == CircuitState.open) {
      throw const ServerException(
        message: 'Servicio temporalmente no disponible',
      );
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } on Exception catch (e) {
      _onFailure();
      rethrow;
    }
  }

  /// Manually reset the circuit to closed state.
  /// Useful for admin overrides or after manual health checks.
  void reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _lastFailureTime = null;
    _halfOpenAttempts = 0;
  }

  /// Checks if enough time has passed to transition from open to half-open.
  void _updateState() {
    if (_state == CircuitState.open && _lastFailureTime != null) {
      final elapsed = DateTime.now().difference(_lastFailureTime!);
      if (elapsed >= resetTimeout) {
        _state = CircuitState.halfOpen;
        _halfOpenAttempts = 0;
      }
    }
  }

  void _onSuccess() {
    if (_state == CircuitState.halfOpen) {
      // Probe succeeded — close the circuit
      _state = CircuitState.closed;
    }
    _failureCount = 0;
    _halfOpenAttempts = 0;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_state == CircuitState.halfOpen) {
      // Probe failed — reopen the circuit
      _state = CircuitState.open;
      _halfOpenAttempts = 0;
    } else if (_failureCount >= failureThreshold) {
      // Threshold reached — open the circuit
      _state = CircuitState.open;
    }
  }
}

/// States of the Circuit Breaker.
enum CircuitState {
  /// Normal operation — requests flow through.
  closed,

  /// Failing — all requests are rejected.
  open,

  /// Probing — one request is allowed to test recovery.
  halfOpen;
}
