# GitHub Secrets Configuration for iOS Production

Este archivo lista todos los secrets que necesitas configurar en tu repositorio de GitHub para habilitar el build de iOS production.

## Secrets Requeridos

### IOS_CERTIFICATES_P12
**Tipo:** Secret
**Descripción:** Certificado de desarrollo/distribución de Apple en formato base64
**Requerido para:** Build iOS production

**Cómo obtenerlo:**
```bash
# 1. Exportar certificado desde Keychain Access
# 2. Convertir a base64
base64 -i Certificates.p12 | pbcopy

# 3. El resultado en el clipboard es el valor del secret
```

### IOS_CERTIFICATES_P12_PASSWORD
**Tipo:** Secret
**Descripción:** Contraseña del certificado P12
**Requerido para:** Build iOS production

**Nota:** Si no estableciste contraseña al exportar, usa una cadena vacía.

## Secrets Opcionales (para TestFlight/App Store)

### APP_STORE_CONNECT_API_KEY_ID
**Tipo:** Secret
**Descripción:** ID de la API Key de App Store Connect
**Requerido para:** Subir automáticamente a TestFlight

**Cómo obtenerlo:**
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Roles → Keys
3. Crea una nueva API Key
4. Copia el "Key ID" (ej: "ABC123XYZ")

### APP_STORE_CONNECT_API_ISSUER_ID
**Tipo:** Secret
**Descripción:** Issuer ID de tu equipo en App Store Connect
**Requerido para:** Subir automáticamente a TestFlight

**Cómo obtenerlo:**
1. En App Store Connect → Users and Roles → Keys
2. El "Issuer ID" está visible en la parte superior (ej: "12345678-1234-1234-1234-123456789012")

### APP_STORE_CONNECT_API_KEY_CONTENT
**Tipo:** Secret
**Descripción:** Contenido de la API Key (.p8 file) en formato base64
**Requerido para:** Subir automáticamente a TestFlight

**Cómo obtenerlo:**
```bash
# 1. Descarga el archivo .p8 desde App Store Connect
# 2. Convierte a base64
base64 -i AuthKey_ABC123XYZ.p8 | pbcopy

# 3. El resultado en el clipboard es el valor del secret
```

## Secrets Opcionales (para notificaciones)

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
# Crear un tag para probar el build de iOS production
git tag -a test-build -m "Test iOS build"
git push origin test-build

# Ve a GitHub Actions para ver el resultado
```

## Ejemplo de Configuración Completa

### Mínimo (para build iOS development)
```yaml
IOS_CERTIFICATES_P12: "MIAGCSqGSIb3DQEBAQUAA4GMADCBiAKBgD..."
IOS_CERTIFICATES_P12_PASSWORD: "tu_password_aqui"
```

### Completo (para TestFlight/App Store)
```yaml
IOS_CERTIFICATES_P12: "MIAGCSqGSIb3DQEBAQUAA4GMADCBiAKBgD..."
IOS_CERTIFICATES_P12_PASSWORD: "tu_password_aqui"
APP_STORE_CONNECT_API_KEY_ID: "ABC123XYZ"
APP_STORE_CONNECT_API_ISSUER_ID: "12345678-1234-1234-1234-123456789012"
APP_STORE_CONNECT_API_KEY_CONTENT: "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t..."
SLACK_WEBHOOK_URL: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

## Seguridad

### Best Practices
1. **Nunca commits secrets** al repositorio
2. **Usa contraseñas fuertes** para los certificados
3. **Rota certificados** periódicamente (Apple recomienda cada año)
4. **Limita acceso** a los secrets en GitHub
5. **Usa entornos separados** para development y production

### Rotación de Certificados
Apple requiere que los certificados de desarrollo/distribución se roten anualmente. Para rotar:

1. **Generar nuevo certificado** en Apple Developer
2. **Exportar nuevo P12** desde Keychain Access
3. **Actualizar secrets** en GitHub
4. **Revocar certificado antiguo** en Apple Developer

## Troubleshooting

### Error: "IOS_CERTIFICATES_P12 is not set"
**Solución:** Configura el secret en GitHub Settings → Secrets

### Error: "Invalid password for certificate"
**Solución:** Verifica que IOS_CERTIFICATES_P12_PASSWORD sea correcto

### Error: "No matching provisioning profiles found"
**Solución:** 
1. Verifica que el Bundle Identifier sea correcto
2. Asegúrate de tener el provisioning profile instalado
3. Revisa que el certificado sea del tipo correcto (development vs distribution)

### Error: "API key is not valid"
**Solución:**
1. Verifica que APP_STORE_CONNECT_API_KEY_ID sea correcto
2. Asegúrate de que la API Key esté activa en App Store Connect
3. Verifica que el Issuer ID sea correcto

## Referencias

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Apple Developer Certificates](https://developer.apple.com/support/certificates/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

## Soporte

Si necesitas ayuda:

1. Consulta la guía completa: `docs/ios-build-guide.md`
2. Revisa la documentación de GitHub Actions
3. Verifica los logs del workflow en GitHub
4. Contacta a tu equipo de desarrollo

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
