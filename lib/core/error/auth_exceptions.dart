import 'fudi_exception.dart';

sealed class AuthException extends FudiException {
  const AuthException({
    required super.message,
    super.code,
    super.context,
    super.severity,
    super.feature = 'auth',
  });
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException({super.message = 'No autenticado'})
      : super(code: 'AUTH_001', severity: ErrorSeverity.medium);
}

class ForbiddenException extends AuthException {
  ForbiddenException({super.message = 'Sin permisos', String? requiredRole})
      : super(code: 'AUTH_002', severity: ErrorSeverity.medium, context: {'required_role': requiredRole});
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException({super.message = 'Sesión expirada'})
      : super(code: 'AUTH_003', severity: ErrorSeverity.medium);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({super.message = 'Credenciales inválidas'})
      : super(code: 'AUTH_004', severity: ErrorSeverity.low);
}

class AuthConflictException extends AuthException {
  const AuthConflictException({super.message = 'Ya existe una cuenta con ese correo'})
      : super(code: 'AUTH_005', severity: ErrorSeverity.medium);
}
