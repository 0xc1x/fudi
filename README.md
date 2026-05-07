# Fudi

Configuración base de agentes e instrucciones de trabajo para desarrollar **Fudi**, una app Flutter + Supabase + Sentry con landing/admin web enfocada en rescate de comida con **pickup-only** en fase 1.

> ⚡️ **Para una visión unificada del sistema agentic**, consulta `AGENT_SYSTEM_META.md`

## Archivos clave

- `AGENTS.md` -> instrucción canónica del repositorio
- `AGENT_SYSTEM_META.md` -> mapa unificado de herramientas y agentes
- `CHANGELOG.md` -> historial de cambios y versiones del proyecto
- `.agents/` -> agentes especializados (ubicación neutral, proveedor-agnostic)
- `GEMINI.md` -> contexto raíz para Gemini CLI
- `opencode.json` -> configuración base para OpenCode
- `.cursor/rules/` -> reglas de Cursor
- `.github/copilot-instructions.md` -> instrucciones globales para Copilot/Codex
- `docs/ai/` -> brief y arquitectura del proyecto
- `docs/ai/ADDITIONAL_TOOLS.md` -> herramientas y skills adicionales para desarrollo agéntico
- `docs/ios-build-guide.md` -> guía completa de configuración de builds iOS
- `docs/android-play-store-guide.md` -> guía completa de publicación en Google Play Store
- `docs/github-secrets-ios.md` -> configuración de secrets para iOS
- `docs/github-secrets-android.md` -> configuración de secrets para Android
- `.ai/mcp/` -> configuración de MCPs compartida
- `.ai/mcp/MCP_SETUP_GUIDE.md` -> guía completa de configuración de MCPs
- `.ai/mcp/scripts/` -> scripts de automatización para análisis y generación
- `.github/workflows/flutter-ci.yml` -> workflow de CI/CD con builds iOS, Android y Web

## Resumen del producto

- Roles: `guest`, `user`, `business`, `admin`
- Consumer app con mapa, explorar, ofertas, perfil e historial
- Dashboard business para catálogo, paquetes, ventas y pedidos
- Admin web para alta de negocios y configuración global
- Sin carrito ni delivery en fase 1

## Documentación inicial

- `docs/ai/README.md`
- `docs/ai/PRODUCT_BRIEF.md`
- `docs/ai/SYSTEM_ARCHITECTURE.md`

## Notas operativas

- No ejecutar builds después de cambios
- Mantener Clean Architecture + Feature-First
- Considerar `guest` como estado no autenticado, no como rol persistido

## Configuración de MCPs

El proyecto incluye 11 MCPs configurados para desarrollo agéntico:

### MCPs Requeridos
- **GitHub** - Gestión de repositorios, issues, PRs (github-mcp)
- **Supabase Database** - Introspección de PostgreSQL (postgres-mcp)

### MCPs Opcionales
- **Figma API** - Designs y componentes (figma-mcp)
- **Linear** - Gestión de tareas (@mseep/linear-mcp)
- **Slack Notifications** - Notificaciones (@aaronsb/slack-mcp)

### MCPs HTTP
- **OpenAI Developer Docs** - Documentación de OpenAI
- **React Docs** - Documentación de React
- **Flutter Docs** - Documentación de Flutter
- **Flutter Testing** - Testing de Flutter
- **Jest Docs** - Documentación de Jest
- **GitHub Actions** - Documentación de GitHub Actions

### Configuración Rápida

```bash
cd .ai/mcp
npm run setup
cp .env.mcp.example .env.mcp.local
# Editar .env.mcp.local con tus tokens
npm run verify
```

Para más detalles, consulta [`.ai/mcp/MCP_SETUP_GUIDE.md`](.ai/mcp/MCP_SETUP_GUIDE.md) o [`.ai/mcp/MCP_CONFIGURATION_FIXED.md`](.ai/mcp/MCP_CONFIGURATION_FIXED.md)
