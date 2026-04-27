# GitHub Secrets Configuration for Android Play Store

Este archivo lista todos los secrets que necesitas configurar en tu repositorio de GitHub para habilitar el build y deployment automatizado a Google Play Store.

## Secrets Requeridos

### ANDROID_KEYSTORE_FILE
**Tipo:** Secret
**Descripción:** Keystore de Android en formato base64
**Requerido para:** Build Android release

**Cómo obtenerlo:**
```bash
# 1. Crear keystore (si no existe)
cd android
keytool -genkey -v -keystore fudi-release.keystore -alias fudi -keyalg RSA -keysize 2048 -validity 10000

# 2. Convertir a base64
base64 -i android/app/fudi-release.keystore | pbcopy

# 3. El resultado en el clipboard es el valor del secret
```

**⚠️ IMPORTANTE:**
- Nunca commits el keystore al repositorio
- Guarda el keystore original en lugar seguro
- Si pierdes el keystore, NO podrás actualizar la app

### ANDROID_KEYSTORE_PASSWORD
**Tipo:** Secret
**Descripción:** Contraseña del keystore
**Requerido para:** Build Android release

**Nota:** Es la contraseña que estableciste al crear el keystore.

### ANDROID_KEY_ALIAS
**Tipo:** Secret
**Descripción:** Alias de la clave en el keystore
**Requerido para:** Build Android release

**Valor:** `fudi` (o el alias que usaste al crear el keystore)

### ANDROID_KEY_PASSWORD
**Tipo:** Secret
**Descripción:** Contraseña de la clave privada
**Requerido para:** Build Android release

**Nota:** Puede ser la misma que la del keystore.

## Secrets Opcionales (para Deployment Automatizado)

### GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
**Tipo:** Secret
**Descripción:** Service account JSON de Google Cloud para Play Console API
**Requerido para:** Deployment automatizado a Google Play Store

**Cómo obtenerlo:**

#### Paso 1: Crear Service Account en Google Cloud
1. Ir a [Google Cloud Console](https://console.cloud.google.com)
2. Crear proyecto o seleccionar existente
3. Ir a "IAM & Admin" → "Service Accounts"
4. Click en "Create Service Account"
5. Completar:
   - **Service account name:** `github-actions-deploy`
   - **Service account description:** `GitHub Actions deployment to Play Store`
6. Click en "Create and Continue"

#### Paso 2: Configurar Permisos
1. Click en el service account creado
2. Ir a "Permissions"
3. Click en "Grant Access"
4. Buscar y agregar rol: **"Play Android Developer"**
5. Click en "Save"

#### Paso 3: Crear y Descargar Clave JSON
1. En el service account, ir a "Keys"
2. Click en "Add Key" → "Create new key"
3. Seleccionar "JSON"
4. Click en "Create"
5. El archivo JSON se descargará automáticamente

#### Paso 4: Convertir a Base64
```bash
# Convertir el archivo JSON a base64
base64 -i downloaded-key.json | pbcopy

# El resultado en el clipboard es el valor del secret
```

#### Paso 5: Habilitar API
1. En Google Cloud Console, ir a "APIs & Services" → "Library"
2. Buscar "Google Play Android Developer API"
3. Click en "Enable"

#### Paso 6: Vincular Service Account con Play Console
1. Ir a [Google Play Console](https://play.google.com/console)
2. Seleccionar tu app
3. Ir a "Setup" → "API access"
4. En "Service accounts", click en "Link service account"
5. Seleccionar el service account creado
6. Click en "Authorize"

**⚠️ IMPORTANTE:**
- Guarda el archivo JSON original en lugar seguro
- Si pierdes el archivo JSON, tendrás que crear uno nuevo
- El service account debe tener permisos de "Play Android Developer"

## Secrets Opcionales (para Notificaciones)

### SLACK_WEBHOOK_URL
**Tipo:** Secret
**Descripción:** URL del webhook de Slack para notificaciones
**Requerido para:** Notificaciones de build/deployment

**Cómo obtenerlo:**
1. Crea una app en Slack
2. Configura un Incoming Webhook
3. Copia la URL del webhook

## Configuración en GitHub

### Paso 1: Ir a la configuración de secrets
1. Ve a tu repositorio en GitHub
2. Click en "Settings"
3. En el menú lateral, click en "Secrets and variables"
4. Click en "Actions"

### Paso 2: Agregar cada secret
1. Click en "New repository secret"
2. Nombre: (usar los nombres exactos de arriba)
3. Secret: (pegar el valor correspondiente)
4. Click en "Add secret"

### Paso 3: Verificar configuración
Después de configurar los secrets, puedes verificar que funcionen correctamente:

```bash
# Crear un tag para probar el build de Android
git tag -a test-android-build -m "Test Android build"
git push origin test-android-build

# Ve a GitHub Actions para ver el resultado
```

## Ejemplo de Configuración Completa

### Mínimo (para build Android release)
```yaml
ANDROID_KEYSTORE_FILE: "u3R7... (base64 del keystore)"
ANDROID_KEYSTORE_PASSWORD: "tu_keystore_password"
ANDROID_KEY_ALIAS: "fudi"
ANDROID_KEY_PASSWORD: "tu_key_password"
```

### Completo (para deployment automatizado)
```yaml
ANDROID_KEYSTORE_FILE: "u3R7... (base64 del keystore)"
ANDROID_KEYSTORE_PASSWORD: "tu_keystore_password"
ANDROID_KEY_ALIAS: "fudi"
ANDROID_KEY_PASSWORD: "tu_key_password"
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: "eyJ0eXAiOiJKV1QiLCJhbGc..."
SLACK_WEBHOOK_URL: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

## Configuración Local (key.properties)

Para builds locales, necesitas crear el archivo `android/key.properties`:

```bash
cat > android/key.properties << 'EOF'
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fudi
storeFile=../app/fudi-release.keystore
EOF
```

**⚠️ IMPORTANTE:** Agrega `android/key.properties` a `.gitignore`

```gitignore
# Android keystore
*.keystore
*.jks
key.properties
```

## Seguridad

### Best Practices
1. **Nunca commits secrets** al repositorio
2. **Nunca commits keystore** al repositorio
3. **Usa contraseñas fuertes** para el keystore
4. **Guarda keystore** en lugar seguro (password manager, drive encriptado)
5. **Limita acceso** a los secrets en GitHub
6. **Rota service account keys** periódicamente
7. **Usa entornos separados** para development y production

### Rotación de Keystore
Google Play permite rotar el keystore, pero es un proceso complejo. Para rotar:

1. **Generar nuevo keystore:**
   ```bash
   keytool -genkey -v -keystore fudi-release-v2.keystore -alias fudi-v2 -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Configurar ambos keystores en build.gradle:**
   ```gradle
   signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
       
       releaseV2 {
           keyAlias keystoreProperties['keyAliasV2']
           keyPassword keystoreProperties['keyPasswordV2']
           storeFile keystoreProperties['storeFileV2'] ? file(keystoreProperties['storeFileV2']) : null
           storePassword keystoreProperties['storePasswordV2']
       }
   }
   ```

3. **Subir a Google Play Console:**
   - Ir a "Setup" → "App signing"
   - Click en "Request app signing key upgrade"
   - Seguir instrucciones

4. **Actualizar secrets en GitHub:**
   - Reemplazar `ANDROID_KEYSTORE_FILE` con nuevo keystore
   - Actualizar contraseñas correspondientes

### Rotación de Service Account Key
Para rotar la clave del service account:

1. **Ir a Google Cloud Console**
2. **Service Accounts → Seleccionar tu service account**
3. **Keys → Add Key → Create new key**
4. **Descargar nueva clave JSON**
5. **Actualizar secret en GitHub:**
   - Reemplazar `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
6. **Eliminar clave antigua** (después de verificar que la nueva funciona)

## Troubleshooting

### Error: "ANDROID_KEYSTORE_FILE is not set"
**Solución:** Configura el secret en GitHub Settings → Secrets

### Error: "Invalid keystore password"
**Solución:** Verifica que `ANDROID_KEYSTORE_PASSWORD` sea correcto

### Error: "Key alias not found"
**Solución:** Verifica que `ANDROID_KEY_ALIAS` coincida con el alias en el keystore

### Error: "Service account does not have permission"
**Solución:**
1. Verifica que el service account tenga rol "Play Android Developer"
2. Verifica que la API esté habilitada en Google Cloud Console
3. Verifica que el service account esté vinculado en Play Console

### Error: "Invalid service account JSON"
**Solución:**
1. Verifica que el JSON sea válido
2. Verifica que esté en formato base64 correcto
3. Regenerar la clave si es necesario

### Error: "App not found in Play Console"
**Solución:**
1. Verifica que el package name sea correcto
2. Verifica que la app exista en Play Console
3. Verifica que el service account tenga acceso a esa app específica

## Verificación de Configuración

### Verificar Keystore Localmente
```bash
# Ver información del keystore
keytool -list -v -keystore android/app/fudi-release.keystore

# Verificar alias
keytool -list -keystore android/app/fudi-release.keystore -alias fudi
```

### Verificar Service Account
```bash
# Descargar y verificar el JSON
echo "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" | base64 -d > service-account.json
cat service-account.json

# Verificar que tenga los campos necesarios
# - type: "service_account"
# - project_id
# - private_key_id
# - private_key
# - client_email
```

### Verificar Build Local
```bash
# Build con keystore local
flutter build appbundle --release

# Verificar que se haya creado el AAB
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### Verificar Build en CI/CD
```bash
# Ver runs del workflow
gh run list

# Ver último run
gh run view

# Ver logs específicos
gh run view --log
```

## Referencias

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Google Play Console API](https://developers.google.com/android-publisher)
- [Google Cloud Service Accounts](https://cloud.google.com/iam/docs/service-accounts)
- [Android Keystore System](https://developer.android.com/security/keystore)
- [Flutter Android Signing](https://docs.flutter.dev/deployment/android#create-an-upload-keystore)

## Soporte

Si necesitas ayuda:

1. Consulta la guía completa: `docs/android-play-store-guide.md`
2. Revisa la documentación de GitHub Actions
3. Verifica los logs del workflow en GitHub
4. Consulta la documentación de Google Play Console
5. Contacta a Google Play Developer Support

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
