import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FudiLocalizations
/// returned by `FudiLocalizations.of(context)`.
///
/// Applications need to include `FudiLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FudiLocalizations.localizationsDelegates,
///   supportedLocales: FudiLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FudiLocalizations.supportedLocales
/// property.
abstract class FudiLocalizations {
  FudiLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FudiLocalizations? of(BuildContext context) {
    return Localizations.of<FudiLocalizations>(context, FudiLocalizations);
  }

  static const LocalizationsDelegate<FudiLocalizations> delegate =
      _FudiLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// The application name
  ///
  /// In es, this message translates to:
  /// **'Fudi'**
  String get appName;

  /// Home screen title
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// Explore screen title
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get exploreTitle;

  /// Orders screen title
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get ordersTitle;

  /// Favorites screen title
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritesTitle;

  /// Profile screen title
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// Offline banner message
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a Internet'**
  String get offlineMessage;

  /// Location prompt title
  ///
  /// In es, this message translates to:
  /// **'Activa tu ubicación'**
  String get activateLocation;

  /// Location prompt description
  ///
  /// In es, this message translates to:
  /// **'Para ver ofertas cerca de ti'**
  String get activateLocationDescription;

  /// Expiring offers section title
  ///
  /// In es, this message translates to:
  /// **'Últimas Horas'**
  String get lastHours;

  /// Recent offers section title
  ///
  /// In es, this message translates to:
  /// **'Recién Agregados'**
  String get recentlyAdded;

  /// Popular offers section title
  ///
  /// In es, this message translates to:
  /// **'Ofertas Populares'**
  String get popularOffers;

  /// Nearby businesses section title
  ///
  /// In es, this message translates to:
  /// **'Negocios Cerca'**
  String get nearbyBusinesses;

  /// Nearby offers section title
  ///
  /// In es, this message translates to:
  /// **'Cerca de Ti'**
  String get nearbyOffers;

  /// Error when offer is not found
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado'**
  String get productNotFound;

  /// Error message when product is unavailable
  ///
  /// In es, this message translates to:
  /// **'Este producto no está disponible'**
  String get productNotAvailable;

  /// Button to navigate home
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backToHome;

  /// Terms agreement text in checkout
  ///
  /// In es, this message translates to:
  /// **'Al confirmar aceptas los términos y condiciones de Fudi'**
  String get confirmTerms;

  /// Coupon validation error
  ///
  /// In es, this message translates to:
  /// **'Cupón no encontrado o inválido'**
  String get couponNotFound;

  /// Expired coupon error
  ///
  /// In es, this message translates to:
  /// **'Este cupón ya no es válido'**
  String get couponExpired;

  /// Minimum order amount for coupon
  ///
  /// In es, this message translates to:
  /// **'Monto mínimo para este cupón: {amount}'**
  String minAmountRequired(String amount);
}

class _FudiLocalizationsDelegate
    extends LocalizationsDelegate<FudiLocalizations> {
  const _FudiLocalizationsDelegate();

  @override
  Future<FudiLocalizations> load(Locale locale) {
    return SynchronousFuture<FudiLocalizations>(
      lookupFudiLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_FudiLocalizationsDelegate old) => false;
}

FudiLocalizations lookupFudiLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return FudiLocalizationsEs();
  }

  throw FlutterError(
    'FudiLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
