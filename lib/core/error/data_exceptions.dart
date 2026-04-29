import 'fudi_exception.dart';

/// Exceptions related to data and validation.
sealed class DataException extends FudiException {
  const DataException({required super.message, super.code, super.context});
}

class ValidationException extends DataException {
  final Map<String, String>? fieldErrors;

  const ValidationException({super.message = 'Datos inválidos', this.fieldErrors})
      : super(code: 'DATA_001');
}

class NotFoundException extends DataException {
  const NotFoundException({super.message = 'Recurso no encontrado'})
      : super(code: 'DATA_002');
}

class CacheException extends DataException {
  const CacheException({super.message = 'Error de caché'})
      : super(code: 'DATA_003');
}
