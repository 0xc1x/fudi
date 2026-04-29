import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/error/auth_exceptions.dart';
import 'package:fudi/core/error/business_exceptions.dart';
import 'package:fudi/core/error/data_exceptions.dart';
import 'package:fudi/core/error/fudi_exception.dart';
import 'package:fudi/core/error/network_exceptions.dart';
import 'package:fudi/core/error/payment_exceptions.dart';

void main() {
  group('FudiException Hierarchy', () {
    test('ConnectionException should be a NetworkException and FudiException', () {
      const exception = ConnectionException();
      expect(exception, isA<NetworkException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'NET_001');
    });

    test('UnauthorizedException should be an AuthException and FudiException', () {
      const exception = UnauthorizedException();
      expect(exception, isA<AuthException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'AUTH_001');
    });

    test('PaymentRejectedException should be a PaymentException and FudiException', () {
      const exception = PaymentRejectedException(rejectionReason: 'Insufficient funds');
      expect(exception, isA<PaymentException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'PAY_001');
      expect(exception.rejectionReason, 'Insufficient funds');
    });

    test('OfferUnavailableException should be a BusinessRuleException and FudiException', () {
      const exception = OfferUnavailableException();
      expect(exception, isA<BusinessRuleException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'BIZ_001');
    });

    test('ValidationException should be a DataException and FudiException', () {
      const exception = ValidationException(fieldErrors: {'email': 'Invalid format'});
      expect(exception, isA<DataException>());
      expect(exception, isA<FudiException>());
      expect(exception.code, 'DATA_001');
      expect(exception.fieldErrors?['email'], 'Invalid format');
    });
  });
}
