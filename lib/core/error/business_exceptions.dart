import 'fudi_exception.dart';

/// Exceptions related to business rules.
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
