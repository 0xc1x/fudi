import 'fudi_exception.dart';

sealed class BusinessRuleException extends FudiException {
  const BusinessRuleException({
    required super.message,
    super.code,
    super.context,
    super.severity,
    super.feature = 'business',
  });
}

class OfferUnavailableException extends BusinessRuleException {
  const OfferUnavailableException({super.message = 'Oferta no disponible'})
      : super(code: 'BIZ_001', severity: ErrorSeverity.medium);
}

class OfferExpiredException extends BusinessRuleException {
  const OfferExpiredException({super.message = 'Oferta expirada'})
      : super(code: 'BIZ_002', severity: ErrorSeverity.low);
}

class PickupWindowClosedException extends BusinessRuleException {
  const PickupWindowClosedException({super.message = 'Ventana de pickup cerrada'})
      : super(code: 'BIZ_003', severity: ErrorSeverity.medium);
}

class OrderAlreadyReservedException extends BusinessRuleException {
  const OrderAlreadyReservedException({super.message = 'Orden ya reservada'})
      : super(code: 'BIZ_004', severity: ErrorSeverity.low);
}

class DuplicateReservationException extends BusinessRuleException {
  const DuplicateReservationException({super.message = 'Ya tienes una reserva para esta oferta'})
      : super(code: 'BIZ_005', severity: ErrorSeverity.low);
}
