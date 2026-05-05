import 'fudi_exception.dart';
import 'auth_exceptions.dart';
import 'business_exceptions.dart';
import 'data_exceptions.dart';
import 'network_exceptions.dart';
import 'payment_exceptions.dart';

extension FudiExceptionL10n on FudiException {
  String userMessage() {
    return switch (this) {
      ConnectionException() => 'Sin conexión. Verifica tu internet e intenta de nuevo.',
      TimeoutException() => 'La operación tardó demasiado. Intenta de nuevo.',
      ServerException() => 'Tenemos un problema temporal. Intenta en unos minutos.',
      RateLimitException() => 'Has realizado muchas acciones. Espera un momento.',
      UnauthorizedException() => 'Inicia sesión para continuar.',
      TokenExpiredException() => 'Tu sesión expiró. Inicia sesión de nuevo.',
      ForbiddenException() => 'No tienes permisos para esta acción.',
      InvalidCredentialsException() => 'Credenciales inválidas. Verifica tus datos.',
      PaymentRejectedException() => 'Tu pago fue rechazado. Verifica tu método de pago.',
      PaymentTimeoutException() => 'El pago tardó demasiado. Intenta de nuevo.',
      PaymentGatewayUnavailableException() => 'El sistema de pagos no está disponible. Intenta en unos minutos.',
      RefundFailedException() => 'El reembolso falló. Contacta soporte.',
      OfferUnavailableException() => 'Esta oferta ya no está disponible.',
      OfferExpiredException() => 'Esta oferta ya expiró.',
      PickupWindowClosedException() => 'El horario de recogida ya pasó.',
      OrderAlreadyReservedException() => 'Esta orden ya fue reservada.',
      DuplicateReservationException() => 'Ya tienes una reserva para esta oferta.',
      ValidationException() => 'Revisa los datos ingresados.',
      NotFoundException() => 'No encontramos lo que buscas.',
      CacheException() => 'Error de caché. Intenta de nuevo.',
      _ => 'Ocurrió un error inesperado. Intenta de nuevo.',
    };
  }

  String recovery() {
    return switch (this) {
      ConnectionException() => 'retry',
      TimeoutException() => 'retry',
      ServerException() => 'retry_later',
      RateLimitException() => 'wait',
      UnauthorizedException() => 'login',
      TokenExpiredException() => 'login',
      ForbiddenException() => 'contact_support',
      InvalidCredentialsException() => 'check_credentials',
      PaymentRejectedException() => 'change_payment_method',
      PaymentTimeoutException() => 'retry',
      PaymentGatewayUnavailableException() => 'retry_later',
      RefundFailedException() => 'contact_support',
      OfferUnavailableException() => 'browse_offers',
      OfferExpiredException() => 'browse_offers',
      PickupWindowClosedException() => 'check_schedule',
      OrderAlreadyReservedException() => 'view_orders',
      DuplicateReservationException() => 'view_orders',
      ValidationException() => 'fix_fields',
      NotFoundException() => 'go_home',
      CacheException() => 'retry',
      _ => 'retry',
    };
  }

  bool get isRetryable => switch (this) {
    ConnectionException() => true,
    TimeoutException() => true,
    ServerException() => true,
    RateLimitException() => true,
    PaymentTimeoutException() => true,
    PaymentGatewayUnavailableException() => true,
    _ => false,
  };
}
