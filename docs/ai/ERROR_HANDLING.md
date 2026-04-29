# Fudi Error Handling & Observability

## Principio

Todo error debe ser: **clasificable**, **rastreable**, **accionable**.
El usuario ve un mensaje claro. El equipo de ingenieria ve el contexto completo.

## Jerarquia de Errores

```dart
/// Base: todo error de Fudi hereda de aqui
sealed class FudiException implements Exception {
  final String message;
  final String? code;        // Codigo estable para busqueda en Sentry
  final Map<String, dynamic> context;  // Contexto adicional estructurado
  
  const FudiException({
    required this.message,
    this.code,
    this.context = const {},
  });
}

/// Errores de red y conectividad
sealed class NetworkException extends FudiException {
  final int? statusCode;
  final String? endpoint;
  
  const NetworkException({
    required super.message,
    super.code,
    super.context,
    this.statusCode,
    this.endpoint,
  });
}

class ConnectionException extends NetworkException {
  const ConnectionException({super.message = 'Sin conexion a internet'})
    : super(code: 'NET_001');
}

class TimeoutException extends NetworkException {
  const TimeoutException({super.message = 'La peticion excedio el tiempo limite'})
    : super(code: 'NET_002');
}

class ServerException extends NetworkException {
  const ServerException({super.message = 'Error del servidor', int? statusCode})
    : super(code: 'NET_003', statusCode: statusCode);
}

class RateLimitException extends NetworkException {
  const RateLimitException({super.message = 'Demasiadas peticiones'})
    : super(code: 'NET_004');
}

/// Errores de autenticacion y autorizacion
sealed class AuthException extends FudiException {
  const AuthException({required super.message, super.code, super.context});
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException({super.message = 'No autenticado'})
    : super(code: 'AUTH_001');
}

class ForbiddenException extends AuthException {
  const ForbiddenException({super.message = 'Sin permisos', String? requiredRole})
    : super(code: 'AUTH_002', context: {'required_role': requiredRole});
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException({super.message = 'Sesion expirada'})
    : super(code: 'AUTH_003');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({super.message = 'Credenciales invalidas'})
    : super(code: 'AUTH_004');
}

/// Errores de pagos
sealed class PaymentException extends FudiException {
  final String? paymentId;
  final String? gateway;
  
  const PaymentException({
    required super.message,
    super.code,
    super.context,
    this.paymentId,
    this.gateway,
  });
}

class PaymentRejectedException extends PaymentException {
  final String? rejectionReason;
  
  const PaymentRejectedException({super.message = 'Pago rechazado', this.rejectionReason})
    : super(code: 'PAY_001');
}

class PaymentTimeoutException extends PaymentException {
  const PaymentTimeoutException({super.message = 'El pago excedio el tiempo limite'})
    : super(code: 'PAY_002');
}

class RefundFailedException extends PaymentException {
  const RefundFailedException({super.message = 'Reembolso fallido'})
    : super(code: 'PAY_003');
}

class PaymentGatewayUnavailableException extends PaymentException {
  const PaymentGatewayUnavailableException({super.message = 'Pasarela no disponible'})
    : super(code: 'PAY_004');
}

/// Errores de reglas de negocio
sealed class BusinessRuleException extends FudiException {
  const BusinessRuleException({required super.message, super.code, super.context});
}

class OfferUnavailableException extends BusinessRuleException {
  const OfferUnavailableException({super.message = 'Oferta no disponible'})
    : super(code: 'BIZ_001');
}

class OfferExpiredException extends BusinessRuleException {
  const OfferExpiredException({super.message = 'Oferta expirada'})
    : super(code: 'BIZ_002');
}

class PickupWindowClosedException extends BusinessRuleException {
  const PickupWindowClosedException({super.message = 'Ventana de pickup cerrada'})
    : super(code: 'BIZ_003');
}

class OrderAlreadyReservedException extends BusinessRuleException {
  const OrderAlreadyReservedException({super.message = 'Orden ya reservada'})
    : super(code: 'BIZ_004');
}

class DuplicateReservationException extends BusinessRuleException {
  const DuplicateReservationException({super.message = 'Ya tienes una reserva para esta oferta'})
    : super(code: 'BIZ_005');
}

/// Errores de datos y validacion
sealed class DataException extends FudiException {
  const DataException({required super.message, super.code, super.context});
}

class ValidationException extends DataException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException({super.message = 'Datos invalidos', this.fieldErrors})
    : super(code: 'DATA_001');
}

class NotFoundException extends DataException {
  const NotFoundException({super.message = 'Recurso no encontrado'})
    : super(code: 'DATA_002');
}

class CacheException extends DataException {
  const CacheException({super.message = 'Error de cache'})
    : super(code: 'DATA_003');
}
```

## Estrategia Sentry

### Inicializacion por ambiente

```dart
// lib/core/observability/sentry_init.dart
Future<void> initSentry(AppEnvironment env) async {
  await SentryFlutter.init(
    (options) {
      options.dsn = env.sentryDsn;
      options.environment = env.name;           // dev, staging, prod
      options.release = '${env.appName}@${env.version}+${env.buildNumber}';
      options.tracesSampleRate = env.sentryTracesRate;  // 1.0 dev, 0.2 prod
      options.profilesSampleRate = env.sentryProfilesRate;
      options.attachStacktrace = true;
      options.attachThreads = true;
      options.sendDefaultPii = false;           // No PII nunca
      options.enableMetricSummary = true;
      
      // Before send: filtrar y enriquecer
      options.beforeSend = (event, hint) {
        // No enviar eventos en dev si no son crash
        if (env.isDev && event.level != SentryLevel.fatal) return null;
        // Enriquecer con contexto de app
        event.tags ??= {};
        event.tags!['app_version'] = env.version;
        return event;
      };
      
      // Before send transaction
      options.beforeSendTransaction = (transaction) {
        // Descartar transacciones de health checks
        if (transaction.name.startsWith('GET /health')) return null;
        return transaction;
      };
    },
    appRunner: () => runApp(),
  );
}
```

### Breadcrumbs obligatorios

```dart
/// Wrapper para agregar breadcrumbs automaticos
class SentryBreadcrumb {
  /// Navegacion
  static void navigation(String from, String to, {String? role}) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'navigation',
      message: '$from -> $to',
      level: SentryLevel.info,
      data: {'from': from, 'to': to, if (role != null) 'role': role},
    ));
  }
  
  /// Accion de usuario
  static void userAction(String action, String target, {Map<String, dynamic>? extra}) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'user.action',
      message: '$action on $target',
      level: SentryLevel.info,
      data: {'action': action, 'target': target, ...?extra},
    ));
  }
  
  /// API call
  static void apiCall(String method, String endpoint, {int? statusCode, Duration? duration}) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'http',
      message: '$method $endpoint',
      level: statusCode != null && statusCode >= 400 ? SentryLevel.error : SentryLevel.info,
      data: {
        'method': method,
        'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (duration != null) 'duration_ms': duration.inMilliseconds,
      },
    ));
  }
  
  /// Pago
  static void payment(String action, String orderId, {String? gateway, String? status}) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'payment',
      message: '$action for order $orderId',
      level: SentryLevel.info,
      data: {
        'action': action,
        'order_id': orderId,
        if (gateway != null) 'gateway': gateway,
        if (status != null) 'status': status,
      },
    ));
  }
}
```

### Tags por feature

| Feature | Tags obligatorios |
|---------|-------------------|
| Auth | `auth_method`, `role` |
| Offers | `offer_id`, `business_id`, `category` |
| Orders | `order_id`, `order_status`, `business_id` |
| Payments | `payment_id`, `gateway`, `payment_status` |
| Business | `business_id`, `business_action` |
| Map | `map_action`, `has_location_permission` |

### Contexto de usuario en Sentry

```dart
/// Al login, setear contexto
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: userId,
    username: displayName,
    email: email,
    other: {
      'role': role.name,
      'signup_date': signupDate.toIso8601String(),
    },
  ));
});

/// Al logout, limpiar
Sentry.configureScope((scope) {
  scope.setUser(null);
});
```

### Captura de errores

```dart
/// Utility para capturar errores con contexto
class FudiErrorReporter {
  /// Captura una excepcion de Fudi con su contexto tipado
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
    
    // Agregar tags del codigo de error
    if (exception.code != null) {
      Sentry.configureScope((scope) {
        scope.setTag('error_code', exception.code!);
      });
    }
  }
  
  /// Captura un mensaje (no excepcion)
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
```

## Retry y Resiliencia

### Retry con backoff exponencial

```dart
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
  
  /// Para operaciones de red
  static const network = RetryPolicy(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
  );
  
  /// Para operaciones de pago (mas conservador)
  static const payment = RetryPolicy(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 3.0,
  );
  
  /// Decide si un error es reintentable
  static bool isRetryable(Exception e) {
    return switch (e) {
      ConnectionException() => true,
      TimeoutException() => true,
      ServerException(statusCode: >= 500) => true,
      RateLimitException() => true,
      PaymentTimeoutException() => true,
      _ => false,
    };
  }
}
```

### Circuit Breaker

```dart
/// Previene llamadas continuas a un servicio que esta fallando
class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;
  
  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_lastFailureTime != null &&
          DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        _state = CircuitState.halfOpen;
      } else {
        throw const ServiceUnavailableException(
          message: 'Servicio temporalmente no disponible',
          code: 'CIR_001',
        );
      }
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
}

enum CircuitState { closed, open, halfOpen }
```

## Offline-First

### Estrategia

| Operacion | Offline | Sincronizacion |
|-----------|---------|----------------|
| Ver ofertas | Cache local + stale-while-revalidate | Background sync al reconectar |
| Crear reserva | Bloquear con mensaje claro | No permitir sin conexion |
| Ver historial | Cache local de ordenes propias | Sync al reconectar |
| Perfil | Cache local | Sync al reconectar |
| Mapa | Cache de tiles + ultima ubicacion | Actualizar al reconectar |

### Implementacion

```dart
/// Wrapper para operaciones que pueden caer offline
class OfflineAwareRepository {
  final ConnectivityService _connectivity;
  final CacheService _cache;
  
  Future<Result<T>> execute<T>({
    required Future<T> Function() remote,
    required Future<T> Function() cached,
    required String cacheKey,
    Duration maxStaleness = const Duration(minutes: 5),
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final result = await remote();
        await _cache.set(cacheKey, result, maxStaleness: maxStaleness);
        return Result.success(result);
      } on NetworkException {
        // Fallback a cache si hay
        final cachedResult = await cached();
        return Result.success(cachedResult, fromCache: true);
      }
    } else {
      final cachedResult = await cached();
      return Result.success(cachedResult, fromCache: true);
    }
  }
}
```

## Presentacion de Errores al Usuario

### Mapa de mensajes

```dart
extension FudiExceptionL10n on FudiException {
  String userMessage() {
    return switch (this) {
      ConnectionException() => 'Sin conexion. Verifica tu internet e intenta de nuevo.',
      TimeoutException() => 'La operacion tardo demasiado. Intenta de nuevo.',
      ServerException() => 'Tenemos un problema temporal. Intenta en unos minutos.',
      RateLimitException() => 'Has realizado muchas acciones. Espera un momento.',
      UnauthorizedException() => 'Inicia sesion para continuar.',
      TokenExpiredException() => 'Tu sesion expiro. Inicia sesion de nuevo.',
      ForbiddenException() => 'No tienes permisos para esta accion.',
      PaymentRejectedException() => 'Tu pago fue rechazado. Verifica tu metodo de pago.',
      PaymentTimeoutException() => 'El pago tardo demasiado. Intenta de nuevo.',
      PaymentGatewayUnavailableException() => 'El sistema de pagos no esta disponible. Intenta en unos minutos.',
      OfferUnavailableException() => 'Esta oferta ya no esta disponible.',
      OfferExpiredException() => 'Esta oferta ya expiro.',
      PickupWindowClosedException() => 'El horario de recogida ya paso.',
      DuplicateReservationException() => 'Ya tienes una reserva para esta oferta.',
      ValidationException(:final fieldErrors) => 'Revisa los datos ingresados.',
      NotFoundException() => 'No encontramos lo que buscas.',
      _ => 'Ocurrio un error inesperado. Intenta de nuevo.',
    };
  }
  
  /// Si la accion es reintentable
  bool get isRetryable => RetryPolicy.isRetryable(this);
}
```

### UI de errores

- **Retryable:** SnackBar con boton "Reintentar"
- **No retryable:** Dialog con descripcion y accion alternativa
- **Fatal/crash:** Pantalla de error con opcion de reiniciar app
- **Offline banner:** Banner persistente arriba indicando modo offline

## Alertas y SLOs

### SLOs

| Servicio | SLO | Ventana |
|----------|-----|---------|
| Login | 99.5% success rate | 7 dias |
| Payment completion | 99% success rate | 7 dias |
| Offer listing | 99.9% availability | 7 dias |
| Order pickup | 95% pickup rate | 30 dias |
| API p99 latency | < 2s | 7 dias |

### Reglas de alerta (Sentry)

| Condicion | Canal | Prioridad |
|-----------|-------|-----------|
| Crash rate > 1% en 1h | Slack + Email | Critica |
| Payment failure rate > 5% en 30min | Slack + Email + SMS | Critica |
| Login failure rate > 10% en 15min | Slack | Alta |
| Any FudiException con code PAY_* | Slack | Alta |
| API latency p99 > 5s | Slack | Media |

## Sourcemaps y Symbols

### CI Pipeline

```yaml
# .github/workflows/flutter-ci.yml - agregar despues del build
- name: Upload Sentry sourcemaps (Web)
  if: matrix.target == 'web'
  run: |
    npx @sentry/cli releases files $RELEASE upload-sourcemaps \
      --url-prefix '~/build/web/' \
      --dist build/web/

- name: Upload Sentry debug symbols (mobile)
  if: matrix.target != 'web'
  run: |
    sentry-cli upload-dif --org fudi --project fudi-mobile build/app/outputs/
```

### Configuracion por ambiente

| Prop | Dev | Staging | Prod |
|------|-----|---------|------|
| tracesSampleRate | 1.0 | 0.5 | 0.2 |
| profilesSampleRate | 1.0 | 0.3 | 0.1 |
| attachStacktrace | true | true | true |
| sendDefaultPii | false | false | false |
| maxBreadcrumbs | 50 | 100 | 100 |
