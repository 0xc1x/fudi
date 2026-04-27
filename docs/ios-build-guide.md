# iOS Build Configuration Guide

Este documento explica las diferentes opciones de build de iOS en el workflow de CI/CD y cómo configurarlas.

## Tipos de Build iOS

### 1. Build iOS Development (No Codesign)
**Job:** `build-ios`

**Características:**
- ✅ No requiere certificados de desarrollo
- ✅ Se ejecuta en cada push y PR
- ✅ Ideal para testing y validación
- ❌ No se puede instalar en dispositivos reales
- ❌ No se puede subir a App Store

**Uso:**
```bash
# Localmente
flutter build ios --release --no-codesign

# En CI/CD
# Se ejecuta automáticamente en cada push
```

**Output:**
- Archive ZIP en `build/ios/archive/ios-archive.zip`
- Se puede abrir en Xcode para testing

### 2. Build iOS Production (Con Codesign)
**Job:** `build-ios-production`

**Características:**
- ✅ Genera IPA firmado para App Store
- ✅ Se puede subir a TestFlight/App Store
- ✅ Se puede instalar en dispositivos reales
- ❌ Requiere certificados y provisioning profiles
- ❌ Solo se ejecuta en tags del branch main

**Uso:**
```bash
# Localmente (requiere certificados instalados)
flutter build ios --release

# En CI/CD
# Se ejecuta automáticamente cuando creas un tag en main
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

**Output:**
- IPA en `build/ios/ipa/*.ipa`
- Listo para subir a App Store Connect

## Configuración de Secrets para iOS Production

Para habilitar el build de iOS production, necesitas configurar los siguientes secrets en tu repositorio de GitHub:

### Secrets Requeridos

#### 1. IOS_CERTIFICATES_P12
**Descripción:** Certificado de desarrollo/distribución de Apple en formato base64

**Cómo obtenerlo:**
```bash
# Exportar tu certificado desde Keychain Access
# 1. Abre Keychain Access
# 2. Busca tu certificado de desarrollo/distribución
# 3. Right-click → Export → "Certificates.p12"
# 4. Convertir a base64
base64 -i Certificates.p12 | pbcopy
```

**Configuración en GitHub:**
1. Ve a Settings → Secrets and variables → Actions
2. Crea un nuevo secret llamado `IOS_CERTIFICATES_P12`
3. Pega el contenido base64 del certificado

#### 2. IOS_CERTIFICATES_P12_PASSWORD
**Descripción:** Contraseña del certificado P12

**Cómo obtenerlo:**
- Es la contraseña que estableciste al exportar el certificado
- Si no estableciste ninguna, usa una cadena vacía

**Configuración en GitHub:**
1. Crea un nuevo secret llamado `IOS_CERTIFICATES_P12_PASSWORD`
2. Pega la contraseña del certificado

### Secrets Opcionales (para TestFlight/App Store)

#### 3. APP_STORE_CONNECT_API_KEY_ID
**Descripción:** ID de la API Key de App Store Connect

**Cómo obtenerlo:**
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Roles → Keys
3. Crea una nueva API Key
4. Copia el "Key ID"

#### 4. APP_STORE_CONNECT_API_ISSUER_ID
**Descripción:** Issuer ID de tu equipo en App Store Connect

**Cómo obtenerlo:**
1. En App Store Connect → Users and Roles → Keys
2. Verás el "Issuer ID" en la parte superior

#### 5. APP_STORE_CONNECT_API_KEY_CONTENT
**Descripción:** Contenido de la API Key en formato base64

**Cómo obtenerlo:**
```bash
# Descargar el archivo .p8 de App Store Connect
# Convertir a base64
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

## Provisioning Profiles

### Development Profile
**Uso:** Testing en dispositivos reales durante desarrollo

**Configuración:**
1. Ve a [Apple Developer](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → Profiles
3. Crea un new Development Profile
4. Descarga e instala en tu Mac

### App Store Profile
**Uso:** Distribución en App Store

**Configuración:**
1. En Apple Developer → Profiles
2. Crea un new App Store Profile
3. Descarga e instala en tu Mac

## Configuración de Xcode

### Bundle Identifier
Asegúrate de que tu Bundle Identifier sea único:

```xml
<!-- ios/Runner.xcodeproj/project.pbxproj -->
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.fudi
```

### Signing & Capabilities
Configura el signing en Xcode:

1. Abre `ios/Runner.xcworkspace`
2. Selecciona el target "Runner"
3. Ve a "Signing & Capabilities"
4. Selecciona tu team de desarrollo
5. Verifica que el provisioning profile esté seleccionado

## Comandos Útiles

### Local Development
```bash
# Build sin codesign (para testing)
flutter build ios --release --no-codesign

# Build con codesign (requiere certificados)
flutter build ios --release

# Build para simulator
flutter build ios --debug --simulator

# Ver información del build
flutter build ios --release --verbose
```

### Testing en Simulator
```bash
# Listar simulators disponibles
flutter devices

# Ejecutar en simulator específico
flutter run -d iPhone 15 Pro

# Build para simulator
flutter build ios --simulator
```

### Deployment
```bash
# Subir a TestFlight (requiere xcrun)
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/Runner.ipa \
  --username "your@email.com" \
  --password "app-specific-password"

# Validar IPA antes de subir
xcrun altool --validate-app \
  --type ios \
  --file build/ios/ipa/Runner.ipa \
  --username "your@email.com" \
  --password "app-specific-password"
```

## Troubleshooting

### Error: "No matching provisioning profiles found"
**Solución:**
1. Verifica que el Bundle Identifier sea correcto
2. Asegúrate de tener el provisioning profile instalado
3. Limpia el build: `flutter clean && cd ios && pod install && cd ..`

### Error: "Code signing is required"
**Solución:**
1. Usa `--no-codesign` para development
2. Configura los certificados correctamente para production

### Error: "No profiles for 'com.yourcompany.fudi' were found"
**Solución:**
1. Crea el provisioning profile en Apple Developer
2. Descarga e instala el profile
3. Limpia y rebuild: `flutter clean && flutter build ios`

## Workflow de Release

### Para crear un release de iOS:

1. **Asegúrate de estar en main branch**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Actualiza la versión en pubspec.yaml**
   ```yaml
   version: 1.0.0+1
   ```

3. **Crea un tag**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

4. **GitHub Actions ejecutará automáticamente:**
   - Tests
   - Build iOS production (con codesign)
   - Generará el IPA

5. **Descarga el IPA desde GitHub Actions:**
   - Ve a la pestaña "Actions"
   - Selecciona el workflow run
   - Descarga el artifact "release-ios-ipa"

6. **Sube a App Store Connect:**
   - Usa Transporter o Xcode
   - O usa el comando `xcrun altool`

## Automatización Avanzada

### Subir automáticamente a TestFlight
Puedes agregar este step al job `build-ios-production`:

```yaml
- name: Upload to TestFlight
  uses: apple-actions/upload-testflight-build@v1
  with:
    app-path: build/ios/ipa/*.ipa
    api-key-id: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
    api-key-issuer-id: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
    api-key-content: ${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}
```

### Notificar en Slack cuando el build esté listo
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'iOS build is ready for deployment!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
  if: always()
```

## Referencias

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [GitHub Actions for iOS](https://github.com/marketplace/actions/apple-actions)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## Soporte

Si encuentras problemas:

1. Revisa los logs de GitHub Actions
2. Verifica que los secrets estén configurados correctamente
3. Asegúrate de tener los provisioning profiles correctos
4. Consulta la documentación oficial de Flutter y Apple

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
