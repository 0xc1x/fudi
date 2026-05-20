import 'fudi_exception.dart';
import 'fudi_exception_l10n.dart';

String userFriendlyMessage(Object error) {
  if (error is FudiException) {
    return error.userMessage();
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
