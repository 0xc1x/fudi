// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FudiLocalizationsEs extends FudiLocalizations {
  FudiLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Fudi';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get offlineMessage => 'Sin conexión a Internet';

  @override
  String get activateLocation => 'Activa tu ubicación';

  @override
  String get activateLocationDescription => 'Para ver ofertas cerca de ti';

  @override
  String get lastHours => 'Últimas Horas';

  @override
  String get recentlyAdded => 'Recién Agregados';

  @override
  String get popularOffers => 'Ofertas Populares';

  @override
  String get nearbyBusinesses => 'Negocios Cerca';

  @override
  String get nearbyOffers => 'Cerca de Ti';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get productNotAvailable => 'Este producto no está disponible';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get confirmTerms =>
      'Al confirmar aceptas los términos y condiciones de Fudi';

  @override
  String get couponNotFound => 'Cupón no encontrado o inválido';

  @override
  String get couponExpired => 'Este cupón ya no es válido';

  @override
  String minAmountRequired(String amount) {
    return 'Monto mínimo para este cupón: $amount';
  }
}
