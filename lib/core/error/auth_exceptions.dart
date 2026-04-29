import 'fudi_exception.dart';

/// Exceptions related to authentication and authorization.
sealed class AuthException extends FudiException {
  const AuthException({required super.message, super.code, super.context});
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException({super.message = 'No autenticado'})
      : super(code: 'AUTH_001');
}

class ForbiddenException extends AuthException {
  const ForbiddenException({super.message = 'Sin permisos', String? requiredRole})
      : super(code: 'AUTH_002', context: {'required_role': requiredRole});
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException({super.message = 'Sesión expirada'})
      : super(code: 'AUTH_003');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({super.message = 'Credenciales inválidas'})
      : super(code: 'AUTH_004');
}
