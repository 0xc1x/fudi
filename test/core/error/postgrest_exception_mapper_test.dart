import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fudi/core/error/data_exceptions.dart';
import 'package:fudi/core/error/fudi_exception_l10n.dart';
import 'package:fudi/core/error/postgrest_exception_mapper.dart';

PostgrestException _makePgException({
  String? code,
  String message = '',
  String? details,
  String? hint,
}) {
  return PostgrestException(
    message: message,
    code: code,
    details: details,
    hint: hint,
  );
}

void main() {
  group('PostgrestExceptionMapper', () {
    test('23505 maps to ConflictException with friendly message', () {
      final e = _makePgException(
        code: '23505',
        message:
            'duplicate key value violates unique constraint "business_locations_pkey"',
      );
      final fudi = e.toFudiException();
      expect(fudi, isA<ConflictException>());
      expect(fudi.userMessage(), contains('Ya existe'));
    });

    test(
      '23514 with discounted_less_than_original maps to ValidationException',
      () {
        final e = _makePgException(
          code: '23514',
          message:
              'new row for relation "offers" violates check constraint "discounted_less_than_original"',
        );
        final fudi = e.toFudiException();
        expect(fudi, isA<ValidationException>());
        expect(fudi.userMessage(), contains('precio original'));
        final validation = fudi as ValidationException;
        expect(validation.fieldErrors, isNotNull);
        expect(validation.fieldErrors?['discountedPrice'], isNotNull);
      },
    );

    test('23503 maps to NotFoundException', () {
      final e = _makePgException(
        code: '23503',
        message: 'foreign key constraint violation',
      );
      final fudi = e.toFudiException();
      expect(fudi, isA<NotFoundException>());
      expect(fudi.userMessage(), contains('encontramos'));
    });

    test('unknown code maps to UnknownDataException with context', () {
      final e = _makePgException(
        code: '22023',
        message: 'some pg error',
        details: 'detail info',
        hint: 'try this',
      );
      final fudi = e.toFudiException();
      expect(fudi, isA<UnknownDataException>());
      expect(fudi.context['pg_code'], '22023');
      expect(fudi.context['pg_message'], 'some pg error');
      expect(fudi.userMessage(), isNot(contains('PostgrestException')));
    });

    test('all mapped exceptions return user-friendly messages', () {
      final exceptions = [
        _makePgException(code: '23505', message: 'duplicate'),
        _makePgException(
          code: '23514',
          message: 'violates check constraint "discounted_less_than_original"',
        ),
        _makePgException(code: '23503', message: 'fk violation'),
        _makePgException(code: '42501', message: 'insufficient privilege'),
        _makePgException(code: 'XXXXX', message: 'unknown error'),
      ];

      for (final e in exceptions) {
        final fudi = e.toFudiException();
        final msg = fudi.userMessage();
        expect(msg, isNot(contains('PostgrestException')));
        expect(msg, isNot(contains('violates')));
        expect(msg, isNot(contains('constraint')));
      }
    });
  });
}
