import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_exceptions.dart';
import 'business_exceptions.dart';
import 'data_exceptions.dart';
import 'fudi_exception.dart';

extension PostgrestExceptionMapper on PostgrestException {
  FudiException toFudiException({String feature = 'data'}) {
    final pgCode = code;

    if (pgCode == '23505') {
      return ConflictException(
        message: _uniqueViolationMessage(message),
      );
    }

    if (pgCode == '23514') {
      return ValidationException(
        message: _checkConstraintMessage(message),
        fieldErrors: _extractFieldErrors(message),
      );
    }

    if (pgCode == '23503') {
      return const NotFoundException(
        message: 'El recurso referenciado no existe.',
      );
    }

    if (pgCode == '42501') {
      return ForbiddenException();
    }

    if (pgCode == 'P0001' || pgCode == 'P0002') {
      return OfferUnavailableException(
        message: _plpgsqlMessage(message),
      );
    }

    return UnknownDataException(
      message: _friendlyMessage(message),
      code: pgCode,
      context: {
        'pg_code': pgCode,
        'pg_message': message,
        'pg_details': details,
        'pg_hint': hint,
      },
      severity: ErrorSeverity.medium,
    );
  }
}

String _uniqueViolationMessage(String raw) {
  if (raw.contains('business_locations')) {
    return 'Ya existe un local con esos datos. Intenta con uno diferente.';
  }
  if (raw.contains('offers')) {
    return 'Ya existe una oferta similar. Verifica los datos.';
  }
  if (raw.contains('businesses')) {
    return 'Ya existe un negocio con esos datos.';
  }
  if (raw.contains('users') || raw.contains('profiles')) {
    return 'Ya existe una cuenta con esa información.';
  }
  return 'Ya existe información registrada con esos datos.';
}

String _checkConstraintMessage(String raw) {
  final lower = raw.toLowerCase();

  if (lower.contains('discounted_less_than_original') ||
      lower.contains('discounted_price')) {
    return 'El precio con descuento debe ser menor al precio original.';
  }
  if (lower.contains('stock') || lower.contains('quantity')) {
    return 'La cantidad ingresada no es válida.';
  }
  if (lower.contains('pickup') || lower.contains('time')) {
    return 'El horario de recogida no es válido.';
  }
  if (lower.contains('price') || lower.contains('amount')) {
    return 'El precio ingresado no es válido.';
  }

  return 'Los datos ingresados no cumplen con las reglas de validación.';
}

Map<String, String>? _extractFieldErrors(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('discounted_less_than_original') ||
      lower.contains('discounted_price')) {
    return {'discountedPrice': 'Debe ser menor al precio original'};
  }
  if (lower.contains('stock')) {
    return {'stock': 'Cantidad no válida'};
  }
  if (lower.contains('pickup')) {
    return {'pickupEnd': 'Horario no válido'};
  }
  return null;
}

String _plpgsqlMessage(String raw) {
  if (raw.contains('no disponible') || raw.contains('not available')) {
    return 'Esta oferta ya no está disponible.';
  }
  if (raw.contains('ya reservada') || raw.contains('already reserved')) {
    return 'Ya tienes una reserva para esta oferta.';
  }
  if (raw.contains('stock') || raw.contains('agotado')) {
    return 'La oferta se agotó. Intenta con otra.';
  }
  return 'No se pudo completar la acción. Intenta de nuevo.';
}

String _friendlyMessage(String raw) {
  if (raw.isEmpty) return 'Ocurrió un error inesperado. Intenta de nuevo.';
  if (raw.contains('timeout') || raw.contains('Timeout')) {
    return 'La operación tardó demasiado. Intenta de nuevo.';
  }
  if (raw.contains('connection') || raw.contains('network')) {
    return 'Sin conexión. Verifica tu internet e intenta de nuevo.';
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
