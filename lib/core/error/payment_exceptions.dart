import 'fudi_exception.dart';

sealed class PaymentException extends FudiException {
  final String? paymentId;
  final String? gateway;

  const PaymentException({
    required super.message,
    super.code,
    super.context,
    super.severity,
    super.feature = 'payments',
    this.paymentId,
    this.gateway,
  });
}

class PaymentRejectedException extends PaymentException {
  final String? rejectionReason;

  const PaymentRejectedException({
    super.message = 'Pago rechazado',
    this.rejectionReason,
  }) : super(code: 'PAY_001', severity: ErrorSeverity.medium);
}

class PaymentTimeoutException extends PaymentException {
  const PaymentTimeoutException({super.message = 'El pago excedió el tiempo límite'})
      : super(code: 'PAY_002', severity: ErrorSeverity.medium);
}

class RefundFailedException extends PaymentException {
  const RefundFailedException({super.message = 'Reembolso fallido'})
      : super(code: 'PAY_003', severity: ErrorSeverity.high);
}

class PaymentGatewayUnavailableException extends PaymentException {
  const PaymentGatewayUnavailableException({super.message = 'Pasarela no disponible'})
      : super(code: 'PAY_004', severity: ErrorSeverity.high);
}
