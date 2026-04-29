/// Enum representing the supported application environments.
enum AppEnvironment {
  dev,
  staging,
  prod;

  /// Constructs an [AppEnvironment] from a string value.
  ///
  /// Returns [AppEnvironment.dev] as default if the string does not match
  /// any known environment.
  static AppEnvironment fromString(String value) {
    return switch (value.toLowerCase()) {
      'staging' => AppEnvironment.staging,
      'prod' || 'production' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }

  /// Human-readable name for the environment.
  String get displayName {
    return switch (this) {
      AppEnvironment.dev => 'Development',
      AppEnvironment.staging => 'Staging',
      AppEnvironment.prod => 'Production',
    };
  }

  /// Short identifier used in logging and file naming.
  String get shortName {
    return switch (this) {
      AppEnvironment.dev => 'dev',
      AppEnvironment.staging => 'staging',
      AppEnvironment.prod => 'prod',
    };
  }

  /// The corresponding .env file name for this environment.
  String get envFileName {
    return '.env.$shortName';
  }
}
