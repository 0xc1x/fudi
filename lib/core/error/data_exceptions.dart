import 'fudi_exception.dart';

sealed class DataException extends FudiException {
  const DataException({
    required super.message,
    super.code,
    super.context,
    super.severity,
    super.feature = 'data',
  });
}

class ValidationException extends DataException {
  final Map<String, String>? fieldErrors;

  const ValidationException({super.message = 'Datos inválidos', this.fieldErrors})
      : super(code: 'DATA_001', severity: ErrorSeverity.low);
}

class NotFoundException extends DataException {
  const NotFoundException({super.message = 'Recurso no encontrado'})
      : super(code: 'DATA_002', severity: ErrorSeverity.medium);
}

class CacheException extends DataException {
  const CacheException({super.message = 'Error de caché'})
      : super(code: 'DATA_003', severity: ErrorSeverity.low);
}
