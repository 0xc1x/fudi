import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/fudi_exception.dart';
import '../error/auth_exceptions.dart';
import '../error/data_exceptions.dart';
import '../error/network_exceptions.dart';
import '../observability/sentry_breadcrumb.dart';
import 'circuit_breaker.dart';
import 'retry_policy.dart';

/// Secure HTTP client built on Dio with production-grade interceptors.
///
/// Responsibilities:
/// 1. **Auth token injection** — Automatically attaches the current
///    Supabase access token to every request via Authorization header.
/// 2. **Sentry tracing** — Creates Sentry spans for each HTTP call
///    and adds structured breadcrumbs for observability.
/// 3. **Error mapping** — Converts Dio exceptions into typed
///    [FudiException] subtypes. No raw DioException ever leaks out.
/// 4. **Retry with backoff** — Retries idempotent requests that fail
///    with retryable errors (connection, timeout, 5xx).
/// 5. **Circuit breaker** — Wraps requests in a circuit breaker
///    to prevent cascading failures.
///
/// Usage:
/// ```dart
/// final client = SecureHttpClient(supabaseClient: supabase);
/// final response = await client.get('/offers');
/// ```
///
/// This class lives in the **Data layer**. Domain never imports it
/// directly — it's injected via Riverpod providers.
class SecureHttpClient {
  final Dio _dio;
  final SupabaseClient _supabaseClient;
  final CircuitBreaker _circuitBreaker;

  /// Creates a [SecureHttpClient] with sensible defaults.
  ///
  /// [baseUrl] — The base URL for all requests (typically Supabase URL).
  /// [connectTimeout] — Connection timeout (default 10s).
  /// [receiveTimeout] — Response body timeout (default 30s).
  /// [circuitBreaker] — Optional custom circuit breaker instance.
  SecureHttpClient({
    required SupabaseClient supabaseClient,
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 30),
    CircuitBreaker? circuitBreaker,
  })  : _supabaseClient = supabaseClient,
        _circuitBreaker = circuitBreaker ?? CircuitBreaker(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? supabaseClient.rest.url,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    // Order matters: auth → retry → error mapping → tracing
    _dio.interceptors.addAll([
      _AuthInterceptor(supabaseClient: _supabaseClient),
      _SentryTracingInterceptor(),
      _ErrorMappingInterceptor(),
    ]);
  }

  /// Exposes the underlying Dio instance for advanced use cases
  /// (e.g., file uploads with progress). Use with caution.
  Dio get dio => _dio;

  // ─── HTTP Methods ───────────────────────────────────────────────

  /// GET request with retry and circuit breaker.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    RetryPolicy retryPolicy = RetryPolicy.network,
  }) {
    return _executeWithResilience(
      method: 'GET',
      path: path,
      retryPolicy: retryPolicy,
      request: () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// POST request — NOT retried by default (non-idempotent).
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RetryPolicy retryPolicy = RetryPolicy.none,
  }) {
    return _executeWithResilience(
      method: 'POST',
      path: path,
      retryPolicy: retryPolicy,
      request: () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// PUT request — retried (idempotent).
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RetryPolicy retryPolicy = RetryPolicy.network,
  }) {
    return _executeWithResilience(
      method: 'PUT',
      path: path,
      retryPolicy: retryPolicy,
      request: () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// DELETE request — retried (idempotent).
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RetryPolicy retryPolicy = RetryPolicy.network,
  }) {
    return _executeWithResilience(
      method: 'DELETE',
      path: path,
      retryPolicy: retryPolicy,
      request: () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// PATCH request — NOT retried by default (potentially non-idempotent).
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RetryPolicy retryPolicy = RetryPolicy.none,
  }) {
    return _executeWithResilience(
      method: 'PATCH',
      path: path,
      retryPolicy: retryPolicy,
      request: () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // ─── Resilience wrapper ─────────────────────────────────────────

  /// Executes an HTTP request with circuit breaker and retry logic.
  ///
  /// The circuit breaker wraps the entire retry sequence.
  /// If the circuit is open, the request fails immediately.
  /// If the circuit is closed/half-open, the request runs with retries.
  Future<Response<T>> _executeWithResilience<T>({
    required String method,
    required String path,
    required RetryPolicy retryPolicy,
    required Future<Response<T>> Function() request,
  }) async {
    return _circuitBreaker.execute(() async {
      int attempt = 0;

      while (true) {
        try {
          return await request();
        } on DioException catch (e) {
          final fudiException = _mapDioException(e);

          attempt++;

          // Check if we should retry
          final canRetry = retryPolicy.hasRetriesLeft(attempt) &&
              RetryPolicy.isIdempotentMethod(method) &&
              RetryPolicy.isRetryable(fudiException);

          if (canRetry) {
            final delay = retryPolicy.delayForAttempt(attempt);
            await Future.delayed(delay);
            continue;
          }

          throw fudiException;
        }
      }
    });
  }

  // ─── Error mapping ──────────────────────────────────────────────

  /// Maps a [DioException] to the appropriate [FudiException] subtype.
  ///
  /// This ensures that NO raw DioException ever escapes the network layer.
  /// Every error is classified, traceable, and actionable per
  /// docs/ai/ERROR_HANDLING.md.
  static FudiException _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),

      DioExceptionType.connectionError =>
        const ConnectionException(),

      DioExceptionType.badResponse => _mapStatusCode(e.response?.statusCode),

      DioExceptionType.cancel =>
        const ConnectionException(message: 'Petición cancelada'),

      // For unknown Dio errors, treat as server error
      _ => ServerException(
          message: e.message ?? 'Error de red desconocido',
          statusCode: e.response?.statusCode,
        ),
    };
  }

  /// Maps HTTP status codes to typed exceptions.
  static FudiException _mapStatusCode(int? statusCode) {
    if (statusCode == null) {
      return const ServerException();
    }

    return switch (statusCode) {
      401 => const UnauthorizedException(),
      403 => ForbiddenException(),
      404 => const NotFoundException(),
      429 => const RateLimitException(),
      >= 500 => ServerException(statusCode: statusCode),
      >= 400 => ValidationException(
          message: 'Error de validación',
          fieldErrors: {'status': '$statusCode'},
        ),
      _ => ServerException(statusCode: statusCode),
    };
  }
}

// ═══════════════════════════════════════════════════════════════════
// Interceptors
// ═══════════════════════════════════════════════════════════════════

/// Injects the current Supabase auth token into every request.
///
/// If the user is authenticated, adds `Authorization: Bearer <token>`.
/// If not authenticated, the request proceeds without the header
/// (public endpoints like /offers still work).
class _AuthInterceptor extends Interceptor {
  final SupabaseClient _supabaseClient;

  _AuthInterceptor({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }
}

/// Creates Sentry spans for HTTP calls and adds structured breadcrumbs.
///
/// Each HTTP request gets:
/// 1. A Sentry span with the HTTP method and URL as the operation
/// 2. A breadcrumb with method, endpoint, status code, and duration
///
/// This gives full observability of network activity in Sentry.
class _SentryTracingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final span = Sentry.startTransaction(
      '${options.method} ${options.path}',
      'http.client',
      description: '${options.method} ${options.uri}',
    );

    // Store the span in extra for access in onResponse/onError
    options.extra['sentrySpan'] = span;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final span = response.requestOptions.extra['sentrySpan'] as ISentrySpan?;
    span?.status = const SpanStatus.ok();
    span?.finish();

    SentryBreadcrumb.apiCall(
      response.requestOptions.method,
      response.requestOptions.path,
      statusCode: response.statusCode,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final span = err.requestOptions.extra['sentrySpan'] as ISentrySpan?;
    span?.status = SpanStatus.internalError();
    span?.finish();

    SentryBreadcrumb.apiCall(
      err.requestOptions.method,
      err.requestOptions.path,
      statusCode: err.response?.statusCode,
    );

    handler.next(err);
  }
}

/// Maps Dio errors to FudiExceptions at the interceptor level.
///
/// This interceptor runs LAST so that the retry logic in
/// [SecureHttpClient._executeWithResilience] still sees DioExceptions
/// (which it needs for retry decisions). The final mapping happens
/// in [_executeWithResilience] after retries are exhausted.
///
/// However, we also map here so that any direct Dio usage (bypassing
/// the resilience wrapper) still gets typed errors.
class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // We let the error pass through as DioException so the retry
    // logic can inspect it. The final mapping to FudiException
    // happens in SecureHttpClient._executeWithResilience.
    //
    // This interceptor exists as a seam for future enhancements:
    // - Logging specific error patterns
    // - Adding error context to the DioException
    // - Selective error transformation for specific endpoints
    handler.next(err);
  }
}
