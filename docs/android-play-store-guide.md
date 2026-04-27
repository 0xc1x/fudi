# Android Play Store Publishing Guide

Esta guía explica paso a paso cómo publicar tu app Flutter en Google Play Store, incluyendo configuración de firma, automatización y mejores prácticas.

## Requisitos Previos

### Cuenta de Developer
- ✅ Cuenta de Google Play Developer ($25 USD pago único)
- ✅ Verificación de identidad completada
- ✅ Cuenta de Google Cloud (para API services)

### Herramientas Necesarias
- ✅ Android Studio instalado
- ✅ JDK 11 o superior
- ✅ Flutter SDK configurado
- ✅ Keystore de Android creado

## Paso 1: Crear Keystore de Android

### ¿Qué es un Keystore?
Un keystore es un archivo que contiene tu certificado digital y clave privada para firmar tu app. Es **CRUCIAL** mantenerlo seguro.

### Crear Keystore

```bash
# Navegar a la carpeta android
cd android

# Crear keystore
keytool -genkey -v -keystore fudi-release.keystore -alias fudi -keyalg RSA -keysize 2048 -validity 10000

# Se te pedirá:
# - Keystore password: (guárdala en lugar seguro)
# - Key password: (puede ser la misma que la del keystore)
# - Nombre, organización, etc.
```

**IMPORTANTE:**
- ⚠️ **Nunca commits el keystore al repositorio**
- ⚠️ **Guarda el keystore y contraseñas en lugar seguro**
- ⚠️ **Si pierdes el keystore, NO podrás actualizar la app**

### Estructura de Keystore
```
android/
├── app/
│   └── fudi-release.keystore  # ❌ NO commits esto
├── key.properties              # ❌ NO commits esto
└── ...
```

## Paso 2: Configurar Firma en Gradle

### Crear archivo key.properties
Este archivo contiene las referencias a tu keystore (no las contraseñas reales):

```bash
# Crear archivo en android/key.properties
cat > android/key.properties << 'EOF'
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fudi
storeFile=../app/fudi-release.keystore
EOF
```

**⚠️ IMPORTANTE:** Agrega `android/key.properties` a `.gitignore`

### Configurar build.gradle

**Archivo:** `android/app/build.gradle`

```gradle
// Agregar al inicio del archivo
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... otras configuraciones

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Actualizar .gitignore

**Archivo:** `.gitignore`

```gitignore
# Android keystore
*.keystore
*.jks
key.properties

# Android release
android/app/release/
```

## Paso 3: Configurar GitHub Secrets para Android

### Secrets Requeridos

#### 1. ANDROID_KEYSTORE_FILE
**Descripción:** Keystore en formato base64

**Cómo obtenerlo:**
```bash
# Convertir keystore a base64
base64 -i android/app/fudi-release.keystore | pbcopy

# El resultado en el clipboard es el valor del secret
```

#### 2. ANDROID_KEYSTORE_PASSWORD
**Descripción:** Contraseña del keystore

**Nota:** Es la contraseña que estableciste al crear el keystore.

#### 3. ANDROID_KEY_ALIAS
**Descripción:** Alias de la clave

**Valor:** `fudi` (o el alias que usaste al crear el keystore)

#### 4. ANDROID_KEY_PASSWORD
**Descripción:** Contraseña de la clave

**Nota:** Puede ser la misma que la del keystore.

### Configurar Secrets en GitHub

1. Ve a tu repositorio → Settings → Secrets and variables → Actions
2. Agrega los siguientes secrets:

```yaml
ANDROID_KEYSTORE_FILE: "u3R7... (base64 del keystore)"
ANDROID_KEYSTORE_PASSWORD: "tu_keystore_password"
ANDROID_KEY_ALIAS: "fudi"
ANDROID_KEY_PASSWORD: "tu_key_password"
```

## Paso 4: Configurar Google Play Console

### Crear App en Play Console

1. **Ir a [Google Play Console](https://play.google.com/console)**
2. **Click en "Crear app"**
3. **Completar información:**
   - Nombre de la app: "Fudi"
   - Paquete: `com.fudi.app` (debe ser único)
   - Idioma predeterminado
   - App gratuita o de pago

### Configurar App

#### Información de la tienda
- **Título:** Fudi
- **Descripción corta:** Encuentra y reserva comida con descuento
- **Descripción completa:** (mínimo 80 caracteres)
- **Iconos:** (512x512 px high-res)
- **Capturas de pantalla:** (mínimo 2, teléfono y tablet)

#### Clasificación de contenido
- **Cuestionario de clasificación:** Completar todas las preguntas
- **Nivel de madurez:** Seleccionar apropiado

#### Política de contenido
- **URL de política de privacidad:** (requerido)
- **URL de términos de servicio:** (opcional pero recomendado)

#### Lista de tiendas
- **Países:** Seleccionar países de lanzamiento

#### Precios y distribución
- **Gratis:** Seleccionar si es gratuita
- **Anuncios:** Configurar si incluye ads

## Paso 5: Crear App Bundle (AAB)

### ¿Por qué AAB en lugar de APK?
Google Play requiere **Android App Bundle (AAB)** para nuevas apps desde agosto 2021. AAB permite:

- ✅ Optimización automática por dispositivo
- ✅ Apps más pequeñas para usuarios
- ✅ Entrega de features on-demand
- ✅ Soporte para múltiples arquitecturas

### Build Local

```bash
# Build AAB para release
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build con GitHub Actions

El workflow ya incluye build de Android. Para generar AAB:

```yaml
# Agregar al job build-android
- name: Build AAB
  run: flutter build appbundle --release

- name: Upload AAB
  uses: actions/upload-artifact@v3
  with:
    name: release-aab
    path: build/app/outputs/bundle/release/app-release.aab
```

## Paso 6: Subir a Google Play Console

### Opción 1: Manual (Recomendado para primer release)

1. **Ir a Google Play Console**
2. **Seleccionar tu app**
3. **Ir a "Lanzamiento" → "Producción"**
4. **Click en "Crear nuevo lanzamiento"**
5. **Subir AAB:**
   - Arrastrar `app-release.aab`
   - O usar "Google Play Console API"

6. **Completar información del lanzamiento:**
   - **Nombre del lanzamiento:** "v1.0.0 - Initial Release"
   - **Notas de la versión:** (detalles de cambios)
   - **Estado de lanzamiento:** "Borrador" o "Completado"

### Opción 2: Automatizado con GitHub Actions

#### Configurar Service Account de Google Cloud

1. **Ir a [Google Cloud Console](https://console.cloud.google.com)**
2. **Crear proyecto o seleccionar existente**
3. **Ir a IAM & Admin → Service Accounts**
4. **Crear service account:**
   - Nombre: `github-actions-deploy`
   - Rol: "Play Android Developer"

5. **Crear y descargar clave JSON:**
   - Click en el service account
   - "Keys" → "Add key" → "Create new key"
   - Descargar archivo JSON

6. **Habilitar Google Play Android Developer API:**
   - Ir a "APIs & Services" → "Library"
   - Buscar "Google Play Android Developer API"
   - Click en "Enable"

#### Configurar Secrets en GitHub

```yaml
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: '{"type":"service_account",...}'
```

#### Agregar Job de Deploy al Workflow

```yaml
deploy-play-store:
  needs: build-android
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main' && startsWith(github.ref, 'refs/tags/')
  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Download AAB
      uses: actions/download-artifact@v3
      with:
        name: release-aab

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.0'

    - name: Install fastlane
      run: gem install fastlane -NV

    - name: Deploy to Play Store
      env:
        GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
      run: |
        echo "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" > service_account.json
        fastlane supply \
          --aab app-release.aab \
          --track internal \
          --json_key service_account.json \
          --package_name com.fudi.app
```

## Paso 7: Proceso de Review

### Tipos de Testing Tracks

#### 1. **Internal Testing** (Pruebas internas)
- **Propósito:** Testing por tu equipo
- **Requisitos:** Mínimo 1 tester
- **Tiempo de review:** Inmediato
- **Distribución:** Link de prueba

#### 2. **Closed Testing** (Pruebas cerradas)
- **Propósito:** Testing por grupo selecto
- **Requisitos:** Mínimo 5 testers
- **Tiempo de review:** 1-2 días
- **Distribución:** Link de prueba

#### 3. **Open Testing** (Pruebas abiertas)
- **Propósito:** Beta pública
- **Requisitos:** Ninguno
- **Tiempo de review:** 1-2 días
- **Distribución:** Play Store (beta)

#### 4. **Production** (Producción)
- **Propósito:** Lanzamiento público
- **Requisitos:** Aprobación completa
- **Tiempo de review:** 3-7 días
- **Distribución:** Play Store (pública)

### Flujo Recomendado

```
Internal Testing → Closed Testing → Open Testing → Production
     (1 día)          (1-2 días)        (1-2 días)      (3-7 días)
```

## Paso 8: Checklist de Lanzamiento

### Antes de Subir

- [ ] Keystore creado y respaldado en lugar seguro
- [ ] Contraseñas guardadas en lugar seguro
- [ ] `.gitignore` configurado correctamente
- [ ] App compilada en modo release
- [ ] ProGuard configurado y probado
- [ ] Versión actualizada en `pubspec.yaml`
- [ ] Version code incrementado

### Información de la Tienda

- [ ] Título de la app (30 caracteres máx)
- [ ] Descripción corta (80 caracteres máx)
- [ ] Descripción completa (4000 caracteres máx)
- [ ] Icono de alta resolución (512x512 px)
- [ ] Capturas de pantalla (mínimo 2)
  - [ ] Teléfono (mínimo 2)
  - [ ] Tablet (opcional pero recomendado)
- [ ] Banner de feature (1024x500 px)
- [ ] Política de privacidad (URL)
- [ ] Términos de servicio (URL, opcional)

### Configuración Técnica

- [ ] Package name único
- [ ] Versión de Android SDK mínima
- [ ] Permisos declarados y justificados
- [ ] Contenido de pantalla inicial configurado
- [ ] Deep links configurados (si aplica)

### Testing

- [ ] Probado en múltiples dispositivos
- [ ] Probado en diferentes versiones de Android
- [ ] Probado en tablets
- [ ] Performance aceptable
- [ ] Sin crashes ni ANRs
- [ ] Accesibilidad verificada

### Legal y Cumplimiento

- [ ] Política de privacidad publicada
- [ ] Términos de servicio publicados
- [ ] Licencias de terceros documentadas
- [ ] Cumplimiento con políticas de contenido
- [ ] Verificación de identidad completada

## Paso 9: Monitoreo Post-Lanzamiento

### Google Play Console Analytics

#### Métricas Clave
- **Instalaciones:** Número de instalaciones
- **Usuarios activos:** DAU, MAU, WAU
- **Retención:** Day 1, Day 7, Day 30
- **Crashes:** Tasa de crashes y ANRs
- **Rating:** Promedio de estrellas y reviews
- **Conversiones:** Instalaciones vs visitas

### Crashlytics (Firebase)

```yaml
# Agregar a pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.0
  firebase_core: ^2.24.0
```

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Configurar Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  runApp(MyApp());
}
```

### Analytics (Firebase)

```yaml
# pubspec.yaml
dependencies:
  firebase_analytics: ^10.0.0
```

```dart
// Track eventos
FirebaseAnalytics.instance.logEvent(
  name: 'offer_reserved',
  parameters: {
    'offer_id': offerId,
    'price': price,
  },
);
```

## Paso 10: Actualizaciones y Mantenimiento

### Versionamiento

**Formato:** `MAJOR.MINOR.PATCH+BUILD_NUMBER`

```yaml
# pubspec.yaml
version: 1.0.0+1  # MAJOR.MINOR.PATCH+BUILD_NUMBER
```

**Reglas:**
- **MAJOR:** Cambios incompatibles en API
- **MINOR:** Funcionalidades backwards-compatible
- **PATCH:** Bug fixes backwards-compatible
- **BUILD_NUMBER:** Incrementar en cada build

### Proceso de Actualización

```bash
# 1. Actualizar versión en pubspec.yaml
version: 1.1.0+2

# 2. Commit y tag
git add pubspec.yaml
git commit -m "Bump version to 1.1.0"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main v1.1.0

# 3. GitHub Actions genera nuevo AAB
# 4. Subir a Google Play Console
# 5. Crear nuevo release
```

### Rollbacks

Si encuentras un bug crítico:

1. **Identificar versión anterior estable**
2. **Subir versión anterior como nuevo release**
3. **Usar "Expedited review"** (solo para bugs críticos)
4. **Comunicar con usuarios**

## Troubleshooting

### Error: "Keystore file not found"
**Solución:**
1. Verificar que `key.properties` apunte al path correcto
2. Verificar que el keystore exista en `android/app/`
3. Verificar permisos del archivo

### Error: "Invalid keystore password"
**Solución:**
1. Verificar contraseñas en `key.properties`
2. Verificar contraseñas en GitHub secrets
3. Recrear keystore si es necesario (⚠️ perderás firma anterior)

### Error: "Package name already exists"
**Solución:**
1. El package name debe ser único en Play Store
2. Cambiar `applicationId` en `build.gradle`
3. O usar un dominio propio: `com.tuempresa.fudi`

### Error: "App rejected during review"
**Causas comunes:**
- Política de privacidad faltante
- Permisos injustificados
- Contenido inapropiado
- Violación de políticas de diseño

**Solución:**
1. Leer mensaje de rechazo detallado
2. Corregir issues mencionados
3. Resubmitir para review

### Error: "Crash rate too high"
**Solución:**
1. Investigar crashes en Crashlytics
2. Fix bugs críticos
3. Subir nueva versión
4. Monitorear métricas post-fix

## Automatización Avanzada

### Fastlane para Android

**Instalación:**
```bash
# Instalar Ruby y fastlane
gem install fastlane

# Inicializar fastlane en proyecto
cd android
fastlane init
```

**Fastfile ejemplo:**
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Build and upload to Internal Testing"
  lane :internal do
    build_app_bundle(
      project: "app/build.gradle",
      release: true
    )
    
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: File.read('../service_account.json')
    )
  end
  
  desc "Build and upload to Production"
  lane :production do
    build_app_bundle(
      project: "app/build.gradle",
      release: true
    )
    
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: File.read('../service_account.json'),
      release_status: 'completed',
      rollout: '0.1'  # 10% rollout inicial
    )
  end
end
```

**Uso:**
```bash
# Subir a internal testing
cd android
fastlane internal

# Subir a production con 10% rollout
fastlane production
```

### Gradle Tasks Útiles

```bash
# Ver todas las tareas disponibles
cd android
./gradlew tasks

# Limpiar build
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Build release AAB
./gradlew bundleRelease

# Ver dependencias
./gradlew app:dependencies

# Run tests
./gradlew test
```

## Referencias

- [Google Play Console](https://play.google.com/console)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [Play Console API](https://developers.google.com/android-publisher)
- [Fastlane for Android](https://docs.fastlane.tools/best-practices/android/)
- [Flutter Android Release](https://docs.flutter.dev/deployment/android)

## Soporte

Si necesitas ayuda:

1. Consulta la documentación oficial de Google Play
2. Revisa los logs de build
3. Verifica configuración de Gradle
4. Contacta a Google Play Developer Support

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
