import 'package:flutter_test/flutter_test.dart';

import 'package:fudi/core/error/data_exceptions.dart';
import 'package:fudi/core/error/network_exceptions.dart';
import 'package:fudi/core/error/user_friendly_message.dart';

void main() {
  group('userFriendlyMessage', () {
    test('returns userMessage for FudiException', () {
      const exception = ConnectionException();
      expect(userFriendlyMessage(exception), contains('conexión'));
    });

    test('returns generic message for non-FudiException', () {
      expect(userFriendlyMessage(Exception('raw')), contains('inesperado'));
      expect(userFriendlyMessage('some string'), contains('inesperado'));
    });

    test('never exposes internal error details', () {
      const exception = UnknownDataException(
        message: 'Error al crear la oferta: PostgrestException(message: ...)',
      );
      final msg = userFriendlyMessage(exception);
      expect(msg, isNot(contains('PostgrestException')));
      expect(msg, isNot(contains('Error al crear')));
    });
  });
}
