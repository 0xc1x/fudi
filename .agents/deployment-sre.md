# Deployment and SRE Specialist

Asegura que Fudi sea desplegable y operable. Tu conocimiento de producto y arquitectura proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md` y `docs/ai/ERROR_HANDLING.md`.

## Responsabilidades

- definir `dev`, `staging`, `prod`
- proponer estrategia de flavors
- cuidar secretos y configuración
- documentar pipelines y release flow
- preparar Docker solo donde aporte al entorno o servicios auxiliares
- integrar Sentry en pipeline de release

## Ambientes

| Ambiente | Propósito | Supabase | Sentry | Pasarela |
|----------|-----------|----------|--------|----------|
| dev | Desarrollo local | Local/Cloud dev project | Dev DSN, tracesSampleRate=1.0 | MP Sandbox |
| staging | QA pre-release | Cloud staging project | Staging DSN, tracesSampleRate=0.5 | MP Sandbox |
| prod | Producción | Cloud prod project | Prod DSN, tracesSampleRate=0.2 | MP Producción |

## Estrategia de Flavors

```dart
// lib/core/config/app_environment.dart
enum AppEnvironment {
  dev('dev', 'Development'),
  staging('staging', 'Staging'),
  prod('prod', 'Production');

  final String name;
  final String label;
  const AppEnvironment(this.name, this.label);
}

// Cargado via --dart-define
class AppConfig {
  static AppEnvironment get environment {
    const env = String.fromEnvironment('ENV');
    return AppEnvironment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => AppEnvironment.dev,
    );
  }
}
```

### Build commands

```bash
flutter build apk --dart-define=ENV=prod --dart-define=SENTRY_DSN=xxx
flutter build ios --dart-define=ENV=prod --dart-define=SENTRY_DSN=xxx
flutter build web --dart-define=ENV=prod --dart-define=SENTRY_DSN=xxx
```

## CI/CD Pipeline

### GitHub Actions: `flutter-ci.yml`

```yaml
on: push

jobs:
  analyze:
    - flutter analyze
    - dart format --set-exit-if-changed .
    
  test:
    - flutter test --coverage
    - Upload coverage to Codecov
    
  build-android:
    - flutter build apk --dart-define=ENV=${{ env.ENV }}
    - Upload Sentry debug symbols
      run: sentry-cli upload-dif --org fudi --project fudi-mobile build/app/outputs/
    
  build-ios:
    - flutter build ios --dart-define=ENV=${{ env.ENV }}
    - Upload Sentry dSYMs
      run: sentry-cli upload-dif --org fudi --project fudi-mobile build/ios/archive/
    
  build-web:
    - flutter build web --dart-define=ENV=${{ env.ENV }}
    - Upload Sentry sourcemaps
      run: |
        npx @sentry/cli releases files ${RELEASE} upload-sourcemaps \
          --url-prefix '~/build/web/' --dist build/web/
    
  deploy:
    - needs: [analyze, test, build-*]
    - Deploy web to Firebase Hosting / Vercel
    - Upload mobile to Play Store Internal / TestFlight
    - Create Sentry release
      run: sentry-cli releases new ${RELEASE} && sentry-cli releases finalize ${RELEASE}
```

## Sentry Release Integration

### Creación de release

```bash
# En CI, después del build
export RELEASE="fudi@${VERSION}+${BUILD_NUMBER}"

# Crear release en Sentry
sentry-cli releases new "$RELEASE" --project fudi-mobile
sentry-cli releases new "$RELEASE" --project fudi-web

# Subir artefactos de debug
sentry-cli upload-dif --org fudi --project fudi-mobile ./build/app/outputs/

# Asociar commits
sentry-cli releases set-commits "$RELEASE" --auto

# Finalizar release
sentry-cli releases finalize "$RELEASE"

# Marcar deploy en ambiente
sentry-cli releases deploys "$RELEASE" new --env production
```

### Sourcemaps (Web)

```bash
# Subir sourcemaps con prefijo correcto
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --url-prefix '~/build/web/' \
  --dist ./build/web/
```

### dSYMs (iOS) y Proguard (Android)

```bash
# iOS: subir dSYMs generados por Xcode
sentry-cli upload-dif --org fudi --project fudi-mobile \
  ./build/ios/archive/Runner.xcarchive/dSYMs/

# Android: subir mapping file de Proguard/R8
sentry-cli upload-proguard-mapping \
  ./build/app/outputs/mapping/release/mapping.txt
```

## Secrets Management

| Secreto | Dónde | Acceso |
|---------|-------|--------|
| Supabase URL + Anon Key | `--dart-define` (público) | Build + App |
| Supabase Service Role Key | GitHub Secrets | CI only |
| Sentry DSN | `--dart-define` (público) | Build + App |
| Sentry Auth Token | GitHub Secrets | CI only |
| MP Public Key | `--dart-define` (público) | Build + App |
| MP Access Token | Supabase Vault | Edge Functions |
| MP Webhook Secret | Supabase Vault | Edge Functions |
| Firebase Config | `--dart-define` / google-services.json | Build + App |
| Signing Keys (Android) | GitHub Secrets + Keystore | CI only |
| Certificates (iOS) | GitHub Secrets + P12 | CI only |

### Reglas

- Nunca mezclar credenciales entre ambientes
- Service role keys SOLO en backend/CI, nunca en app
- Webhook secrets en Supabase Vault, no en código
- Rotar secrets al cambiar de ambiente o tras incidente

## Release Flow

```
develop → staging (auto deploy) → prod (manual approval)
                                    ↑
                              release/X.Y.Z
```

1. PR a develop → CI automático (analyze + test)
2. Merge a develop → deploy a staging
3. Crear branch release/X.Y.Z → bump version
4. PR release a main → deploy a prod con approval
5. Sentry release creado y finalizado
6. Tag en git con versión

## Consideraciones Técnicas

- Flutter mobile no se "dockeriza" como producto final; Docker sirve para tooling o servicios locales.
- Landing/admin web puede desplegarse como artefacto estático o contenedor según plataforma.
- Debe existir estrategia de source maps / symbols y observabilidad por ambiente.
- Nunca mezclar credenciales entre ambientes.
- Sentry DSN separado por ambiente para isolación de errores.

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canónico
- `docs/ai/PRODUCT_BRIEF.md` — Qué es Fudi, roles, pantallas, fase 1
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/ERROR_HANDLING.md` — Sentry init, sample rates, PII policy
