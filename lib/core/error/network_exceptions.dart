import 'fudi_exception.dart';

sealed class NetworkException extends FudiException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException({
    required super.message,
    super.code,
    super.context,
    super.severity,
    super.feature = 'network',
    this.statusCode,
    this.endpoint,
  });
}

class ConnectionException extends NetworkException {
  const ConnectionException({super.message = 'Sin conexión a internet'})
      : super(code: 'NET_001', severity: ErrorSeverity.low);
}

class TimeoutException extends NetworkException {
  const TimeoutException({super.message = 'La petición excedió el tiempo límite'})
      : super(code: 'NET_002', severity: ErrorSeverity.low);
}

class ServerException extends NetworkException {
  const ServerException({super.message = 'Error del servidor', super.statusCode})
      : super(code: 'NET_003', severity: ErrorSeverity.high);
}

class RateLimitException extends NetworkException {
  const RateLimitException({super.message = 'Demasiadas peticiones'})
      : super(code: 'NET_004', severity: ErrorSeverity.low);
}
