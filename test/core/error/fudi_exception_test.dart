import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/error/auth_exceptions.dart';
import 'package:fudi/core/error/business_exceptions.dart';
import 'package:fudi/core/error/data_exceptions.dart';
import 'package:fudi/core/error/fudi_exception.dart';
import 'package:fudi/core/error/fudi_exception_l10n.dart';
import 'package:fudi/core/error/network_exceptions.dart';
import 'package:fudi/core/error/payment_exceptions.dart';

void main() {
  group('FudiException Hierarchy', () {
    test(
      'ConnectionException should be a NetworkException and FudiException',
      () {
        const exception = ConnectionException();
        expect(exception, isA<NetworkException>());
        expect(exception, isA<FudiException>());
        expect(exception.code, 'NET_001');
        expect(exception.severity, ErrorSeverity.low);
        expect(exception.feature, 'network');
      },
    );

    test(
      'UnauthorizedException should be an AuthException and FudiException',
      () {
        const exception = UnauthorizedException();
        expect(exception, isA<AuthException>());
        expect(exception, isA<FudiException>());
        expect(exception.code, 'AUTH_001');
        expect(exception.severity, ErrorSeverity.medium);
        expect(exception.feature, 'auth');
      },
    );

    test(
      'PaymentRejectedException should be a PaymentException and FudiException',
      () {
        const exception = PaymentRejectedException(
          rejectionReason: 'Insufficient funds',
        );
        expect(exception, isA<PaymentException>());
        expect(exception, isA<FudiException>());
        expect(exception.code, 'PAY_001');
        expect(exception.rejectionReason, 'Insufficient funds');
        expect(exception.severity, ErrorSeverity.medium);
        expect(exception.feature, 'payments');
      },
    );

    test(
      'OfferUnavailableException should be a BusinessRuleException and FudiException',
      () {
        const exception = OfferUnavailableException();
        expect(exception, isA<BusinessRuleException>());
        expect(exception, isA<FudiException>());
        expect(exception.code, 'BIZ_001');
        expect(exception.feature, 'business');
      },
    );

    test('ValidationException should be a DataException and FudiException', () {
      const exception = ValidationException(
        fieldErrors: {'email': 'Invalid format'},
      );
      expect(exception, isA<DataException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'DATA_001');
      expect(exception.fieldErrors?['email'], 'Invalid format');
      expect(exception.feature, 'data');
    });

    test('ServerException should have high severity', () {
      const exception = ServerException();
      expect(exception.severity, ErrorSeverity.high);
    });

    test('RefundFailedException should have high severity', () {
      const exception = RefundFailedException();
      expect(exception.severity, ErrorSeverity.high);
    });

    test('custom feature and severity can be overridden', () {
      const exception = ConnectionException() as FudiException;
      expect(exception.severity, ErrorSeverity.low);
      expect(exception.feature, 'network');
    });
  });

  group('FudiException Severity', () {
    test('default severity is medium', () {
      const exception = UnauthorizedException();
      expect(exception.severity, ErrorSeverity.medium);
    });

    test('default feature is set per exception family', () {
      const net = ConnectionException();
      const auth = UnauthorizedException();
      const pay = PaymentRejectedException();
      const biz = OfferUnavailableException();
      const data = ValidationException();

      expect(net.feature, 'network');
      expect(auth.feature, 'auth');
      expect(pay.feature, 'payments');
      expect(biz.feature, 'business');
      expect(data.feature, 'data');
    });
  });

  group('FudiExceptionL10n', () {
    test('userMessage returns localized strings for all types', () {
      expect(ConnectionException().userMessage(), contains('conexión'));
      expect(TimeoutException().userMessage(), contains('tardó'));
      expect(ServerException().userMessage(), contains('problema temporal'));
      expect(UnauthorizedException().userMessage(), contains('sesión'));
      expect(PaymentRejectedException().userMessage(), contains('rechazado'));
      expect(
        OfferUnavailableException().userMessage(),
        contains('no está disponible'),
      );
      expect(ValidationException().userMessage(), contains('datos'));
      expect(NotFoundException().userMessage(), contains('encontramos'));
    });

    test('recovery returns actionable suggestions', () {
      expect(ConnectionException().recovery(), 'retry');
      expect(UnauthorizedException().recovery(), 'login');
      expect(PaymentRejectedException().recovery(), 'change_payment_method');
      expect(NotFoundException().recovery(), 'go_home');
    });

    test('isRetryable returns true for transient errors', () {
      expect(ConnectionException().isRetryable, true);
      expect(TimeoutException().isRetryable, true);
      expect(ServerException().isRetryable, true);
      expect(RateLimitException().isRetryable, true);
      expect(PaymentTimeoutException().isRetryable, true);
      expect(PaymentGatewayUnavailableException().isRetryable, true);
    });

    test('isRetryable returns false for non-transient errors', () {
      expect(UnauthorizedException().isRetryable, false);
      expect(ForbiddenException().isRetryable, false);
      expect(PaymentRejectedException().isRetryable, false);
      expect(RefundFailedException().isRetryable, false);
      expect(OfferUnavailableException().isRetryable, false);
      expect(ValidationException().isRetryable, false);
      expect(NotFoundException().isRetryable, false);
    });

    test('UnknownDataException is retryable', () {
      expect(const UnknownDataException(message: 'test').isRetryable, true);
    });

    test('ValidationException with fieldErrors shows first field error', () {
      const exception = ValidationException(
        fieldErrors: {'discountedPrice': 'Debe ser menor al original'},
      );
      expect(exception.userMessage(), 'Debe ser menor al original');
    });

    test('ValidationException without fieldErrors shows generic message', () {
      const exception = ValidationException();
      expect(exception.userMessage(), contains('datos'));
    });

    test('AuthConflictException shows duplicate email message', () {
      const exception = AuthConflictException();
      expect(exception.userMessage(), contains('correo'));
    });
  });

  group('FudiException toString', () {
    test('includes code, severity, feature, and message', () {
      const exception = ConnectionException();
      final str = exception.toString();
      expect(str, contains('NET_001'));
      expect(str, contains('ErrorSeverity.low'));
      expect(str, contains('network'));
      expect(str, contains('Sin conexión'));
    });
  });
}
