# Herramientas y Skills Adicionales para Desarrollo Agéntico

Este documento describe las herramientas, MCPs y skills adicionales agregadas al proyecto Fudi para potenciar el desarrollo agéntico.

## Nuevos Agentes Especializados

### 1. Migration Specialist
**Archivo:** `.agents/migration-specialist.md`

Especialista en migración React → Flutter con conocimiento profundo de ambos ecosistemas.

**Responsabilidades:**
- Análisis de código React existente
- Traducción de patrones de estado (useState → Riverpod)
- Conversión de componentes React a Widgets Flutter
- Mapeo de routing React Navigation → GoRouter
- Validación de paridad funcional

**Cuándo usarlo:**
- Durante migración de código React a Flutter
- Cuando necesites entender patrones React existentes
- Para traducir estilos CSS a Flutter decorations

### 2. Component Library Specialist
**Archivo:** `.agents/component-library.md`

Especialista en sistemas de diseño y componentes reutilizables.

**Responsabilidades:**
- Diseño de sistema de diseño atómico
- Creación de componentes reutilizables
- Establecimiento de tokens de diseño
- Implementación de patrones de composición
- Garantía de accesibilidad WCAG AA

**Cuándo usarlo:**
- Para crear nuevos componentes UI
- Para establecer consistencia visual
- Para implementar sistema de diseño
- Para optimizar componentes reutilizables

### 3. Performance Specialist
**Archivo:** `.agents/performance.md`

Especialista en optimización de rendimiento de Flutter apps.

**Responsabilidades:**
- Optimización de renderizado y rebuilds
- Gestión eficiente de memoria
- Optimización de animaciones
- Monitoreo de performance con DevTools
- Implementación de mejores prácticas

**Cuándo usarlo:**
- Cuando la app no mantenga 60 FPS
- Para optimizar listas largas
- Para reducir uso de memoria
- Para mejorar tiempo de carga

## Nuevos MCPs

### MCPs de Documentación

#### `react-docs`
- **URL:** https://react.dev/learn
- **Uso:** Documentación oficial de React para análisis de código existente
- **Habilitado por defecto:** Sí

#### `flutter-docs`
- **URL:** https://docs.flutter.dev
- **Uso:** Documentación oficial de Flutter para desarrollo y migración
- **Habilitado por defecto:** Sí

#### `flutter-testing`
- **URL:** https://docs.flutter.dev/cookbook/testing
- **Uso:** Documentación de testing específico de Flutter
- **Habilitado por defecto:** Sí

#### `jest-docs`
- **URL:** https://jestjs.io/docs/getting-started
- **Uso:** Documentación de Jest para entender patrones de testing React
- **Habilitado por defecto:** Sí

#### `github-actions`
- **URL:** https://docs.github.com/en/actions
- **Uso:** Documentación de GitHub Actions para configuración de CI/CD
- **Habilitado por defecto:** Sí

### MCPs Opcionales

#### `figma-api`
- **Launcher:** `.ai/mcp/launchers/figma.mjs`
- **Variable requerida:** `FIGMA_ACCESS_TOKEN`
- **Uso:** API de Figma para extraer designs y componentes
- **Habilitado por defecto:** No

#### `linear`
- **Launcher:** `.ai/mcp/launchers/linear.mjs`
- **Variable requerida:** `LINEAR_API_KEY`
- **Uso:** Integration con Linear para gestión de tareas
- **Habilitado por defecto:** No

#### `slack-notifications`
- **Launcher:** `.ai/mcp/launchers/slack.mjs`
- **Variable requerida:** `SLACK_WEBHOOK_URL`
- **Uso:** Notificaciones de Slack para builds y deployments
- **Habilitado por defecto:** No

## Scripts de Automatización

### 1. Script de Análisis de React
**Archivo:** `.ai/mcp/scripts/analyze-react.mjs`

Analiza código React existente y extrae patrones para facilitar la migración.

**Uso:**
```bash
node .ai/mcp/scripts/analyze-react.mjs <directorio_fuente> [archivo_salida]
```

**Ejemplo:**
```bash
# Analizar directorio src de proyecto React
node .ai/mcp/scripts/analyze-react.mjs src react-analysis.json

# Analizar directorio específico
node .ai/mcp/scripts/analyze-react.mjs ../react-app/src analysis.json
```

**Salida:**
- Archivo JSON con análisis completo
- Patrones de hooks encontrados
- Componentes identificados
- Imports y exports
- Recomendaciones de migración

### 2. Script de Generación de Feature Flutter
**Archivo:** `.ai/mcp/scripts/generate-flutter-feature.py`

Genera estructura completa de boilerplate Flutter según Clean Architecture + Feature-First.

**Uso:**
```bash
python .ai/mcp/scripts/generate-flutter-feature.py <nombre_feature> [--no-templates]
```

**Ejemplo:**
```bash
# Generar feature completo con templates
python .ai/mcp/scripts/generate-flutter-feature.py user_profile

# Generar solo estructura de carpetas
python .ai/mcp/scripts/generate-flutter-feature.py user_profile --no-templates
```

**Estructura generada:**
```
lib/features/user_profile/
  data/
    datasources/
      user_profile_datasource.dart
    models/
      user_profile_model.dart
    repositories/
      user_profile_repository_impl.dart
  domain/
    entities/
      user_profile_entity.dart
    repositories/
      user_profile_repository.dart
    usecases/
      get_user_profile.dart
  presentation/
    providers/
      user_profile_provider.dart
    pages/
      user_profile_page.dart
    widgets/
```

## Skills del Sistema Recomendadas

### Para Planificación y Arquitectura

#### `plan`
Modo plan para inspeccionar contexto y escribir planes markdown.

**Uso recomendado:**
- Antes de implementar features complejos
- Para planificar migración de React a Flutter
- Para diseñar arquitectura de nuevos módulos

#### `writing-plans`
Para crear planes multi-paso desde especificaciones.

**Uso recomendado:**
- Cuando tengas specs detalladas
- Para descomponer features grandes
- Para planificar sprints de desarrollo

#### `subagent-driven-development`
Para ejecutar planes con agentes independientes.

**Uso recomendado:**
- Para implementación paralela de features
- Cuando necesites especialización por dominio
- Para desarrollo complejo con múltiples sub-tareas

### Para Calidad y Testing

#### `test-driven-development`
CRUCIAL para Flutter development.

**Uso recomendado:**
- Antes de escribir cualquier código de producción
- Para garantizar calidad desde el inicio
- Para documentar comportamiento esperado

#### `systematic-debugging`
Para bugs y fallos inesperados.

**Uso recomendado:**
- Cuando encuentres errores
- Para investigar fallos de producción
- Para debugging sistemático

#### `requesting-code-review`
Para verificación pre-commit.

**Uso recomendado:**
- Antes de crear PRs
- Para validación de cambios
- Para asegurar calidad del código

### Para GitHub y Colaboración

#### `github-pr-workflow`
Ciclo completo de Pull Requests.

**Uso recomendado:**
- Para crear branches y commits
- Para gestionar ciclo de PRs
- Para integración continua

#### `github-code-review`
Revisión de cambios de código.

**Uso recomendado:**
- Para revisar PRs de otros
- Para auto-revisión antes de push
- Para mantener estándares de código

#### `github-issues`
Gestión de issues y bugs.

**Uso recomendado:**
- Para reportar bugs
- Para tracking de features
- Para gestión de backlog

#### `github-repo-management`
Gestión del repositorio.

**Uso recomendado:**
- Para configurar repo
- Para gestionar branches
- Para mantenimiento general

## Configuración de CI/CD

### GitHub Actions Workflow
**Archivo:** `.github/workflows/flutter-ci.yml`

Workflow completo de CI/CD para Flutter con:

- **Test job:** Ejecuta tests unitarios y de cobertura
- **Build Android (APK):** Compila APK de release
- **Build Android (AAB):** Compila Android App Bundle
- **Build Android Production:** Compila AAB firmado (solo en tags)
- **Deploy Play Store:** Deploy automatizado a Google Play Store (solo en tags)
- **Build iOS:** Compila iOS sin codesign (development)
- **Build iOS Production:** Compila iOS con codesign (solo en tags)
- **Build Web:** Compila versión web
- **Integration Test:** Ejecuta tests de integración
- **Code Quality:** Verifica métricas de código

**Características:**
- Cache de Flutter para builds más rápidos
- Análisis de código con `flutter analyze`
- Verificación de formato con `dart format`
- Subida de artifacts (APK, AAB, IPA, web build)
- Integración con Codecov para cobertura
- Build iOS production automático en tags
- Build Android production automático en tags
- Deploy automatizado a Google Play Store con Fastlane

**Uso:**
```bash
# El workflow se ejecuta automáticamente en push y PRs
# Build iOS/Android production se ejecuta solo en tags de main
git tag -a v1.0.0 -m "Release"
git push origin v1.0.0
```

**Documentación completa:**
- `docs/ios-build-guide.md` - Guía de builds iOS
- `docs/android-play-store-guide.md` - Guía de publicación Android
- `docs/github-secrets-ios.md` - Secrets para iOS
- `docs/github-secrets-android.md` - Secrets para Android

## Configuración de Variables de Entorno

### Archivo de ejemplo
**Archivo:** `.env.mcp.example`

Contiene todas las variables de entorno necesarias para los MCPs.

**Setup:**
```bash
# Copiar archivo de ejemplo
cp .env.mcp.example .env.mcp.local

# Editar con tus valores reales
nano .env.mcp.local
```

**Variables requeridas:**
- `GITHUB_PERSONAL_ACCESS_TOKEN` - Para MCP de GitHub
- `SUPABASE_DB_URL` - Para MCP de Supabase

**Variables opcionales:**
- `FIGMA_ACCESS_TOKEN` - Para integración con Figma
- `LINEAR_API_KEY` - Para gestión de tareas con Linear
- `SLACK_WEBHOOK_URL` - Para notificaciones de Slack

## Flujo de Trabajo Recomendado

### Fase 1: Análisis de React (Actual)
1. Usar script `analyze-react.mjs` para analizar código existente
2. Revisar patrones identificados
3. Documentar arquitectura React actual
4. Identificar componentes a migrar

### Fase 2: Preparación Flutter
1. Configurar estructura con agente `architect`
2. Generar features con `generate-flutter-feature.py`
3. Setup de dependencias clave
4. Configurar MCPs adicionales

### Fase 3: Migración
1. Usar agente `migration-specialist` para migrar features
2. Migrar feature por feature
3. Testing continuo con `test-driven-development`
4. Validación con agente `performance`

### Fase 4: Optimización
1. Performance tuning con agente `performance`
2. Code review con `github-code-review`
3. Documentación con `technical-documentation`
4. CI/CD con GitHub Actions

## Comandos Útiles

### Análisis de React
```bash
# Analizar código React
node .ai/mcp/scripts/analyze-react.mjs src

# Ver reporte generado
cat react-analysis.json | jq '.summary'
```

### Generación de Features
```bash
# Generar nuevo feature
python .ai/mcp/scripts/generate-flutter-feature.py offer_details

# Generar múltiples features
python .ai/mcp/scripts/generate-flutter-feature.py user_auth
python .ai/mcp/scripts/generate-flutter-feature.py business_dashboard
python .ai/mcp/scripts/generate-flutter-feature.py order_management
```

### Testing
```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ejecutar tests de integración
flutter test integration_test
```

### Build
```bash
# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release

# Analizar tamaño de APK
flutter build apk --analyze-size
```

### Performance
```bash
# Ejecutar app en modo profile
flutter run --profile

# Ver timeline de startup
flutter run --profile --trace-startup

# Generar perfil de memoria
flutter run --profile --dump-memory-profile-to=memory_profile.json
```

## Referencias

### Documentación
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [GoRouter Documentation](https://gorouter.dev)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Dart Code Metrics](https://dartcodemetrics.dev)
- [Very Good CLI](https://verygood.ventures)

### Communities
- [Flutter Community](https://flutter.dev/community)
- [Riverpod Discord](https://discord.gg/SpStCjD)
- [Flutter Reddit](https://reddit.com/r/flutterdev)

## Soporte

Si encuentras problemas o tienes preguntas:

1. Revisa la documentación de cada agente en `.agents/`
2. Consulta los archivos de configuración en `.ai/mcp/`
3. Revisa el workflow de CI/CD en `.github/workflows/`
4. Usa los scripts de automatización en `.ai/mcp/scripts/`

## Próximos Pasos

1. **Configurar MCPs opcionales** si los necesitas
2. **Personalizar templates** de generación de features
3. **Ajustar workflow de CI/CD** según tus necesidades
4. **Configurar integraciones** con Figma, Linear, Slack
5. **Establecer métricas de performance** específicas del proyecto

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
