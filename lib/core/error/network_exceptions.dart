import 'fudi_exception.dart';

/// Exceptions related to network and connectivity.
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
  const ConnectionException({super.message = 'Sin conexión a internet'})
      : super(code: 'NET_001');
}

class TimeoutException extends NetworkException {
  const TimeoutException({super.message = 'La petición excedió el tiempo límite'})
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
