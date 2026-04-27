# Fudi MCP Capabilities

Este documento describe los MCPs actualmente versionados en el repositorio y cómo compartirlos sin exponer secretos.

## Fuente única de verdad

La configuración canónica vive en:

- `.ai/mcp/README.md`
- `.ai/mcp/mcp.manifest.json`
- `.ai/mcp/launchers/`

Las configuraciones concretas por herramienta viven en:

- `.codex/config.toml`
- `.gemini/settings.json`
- `opencode.json`
- `.cursor/mcp.json`
- `.zed/settings.json`
- `.vscode/mcp.json`

## MCPs activos

### `supabase-db`

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/supabase-postgres.mjs`
- **Variable requerida:** `SUPABASE_DB_URL`
- **Uso:** introspección de esquema, tablas, columnas, relaciones y consultas de apoyo sobre Postgres/Supabase.

### `github`

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/github.mjs`
- **Variable requerida:** `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Uso:** gestión de issues, PRs y metadata de GitHub.

### `openaiDeveloperDocs`

- **Tipo:** remoto / HTTP
- **URL:** `https://developers.openai.com/mcp`
- **Uso:** documentación oficial de OpenAI.

### `react-docs`

- **Tipo:** remoto / HTTP
- **URL:** `https://react.dev/learn`
- **Uso:** documentación oficial de React para análisis de código existente y patrones de migración.

### `flutter-docs`

- **Tipo:** remoto / HTTP
- **URL:** `https://docs.flutter.dev`
- **Uso:** documentación oficial de Flutter para desarrollo y migración desde React.

### `flutter-testing`

- **Tipo:** remoto / HTTP
- **URL:** `https://docs.flutter.dev/cookbook/testing`
- **Uso:** documentación de testing específico de Flutter.

### `jest-docs`

- **Tipo:** remoto / HTTP
- **URL:** `https://jestjs.io/docs/getting-started`
- **Uso:** documentación de Jest para entender patrones de testing React.

### `github-actions`

- **Tipo:** remoto / HTTP
- **URL:** `https://docs.github.com/en/actions`
- **Uso:** documentación de GitHub Actions para configuración de CI/CD.

### `figma-api` (opcional)

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/figma.mjs`
- **Variable requerida:** `FIGMA_ACCESS_TOKEN`
- **Uso:** API de Figma para extraer designs, componentes y especificaciones visuales.

### `linear` (opcional)

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/linear.mjs`
- **Variable requerida:** `LINEAR_API_KEY`
- **Uso:** integration con Linear para gestión de tareas y bugs.

### `slack-notifications` (opcional)

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/slack.mjs`
- **Variable requerida:** `SLACK_WEBHOOK_URL`
- **Uso:** notificaciones de Slack para builds, deployments y errores.

## Estrategia de secretos

El repositorio versiona:

- `.env.mcp.example`

Los secretos reales deben vivir en archivos locales o variables exportadas:

- `.env.mcp.local`
- `.env.mcp`
- `.env.local`
- `.env`
- variables del sistema

## Orden de resolución

Los launchers cargan archivos en este orden:

1. `.env`
2. `.env.local`
3. `.env.mcp`
4. `.env.mcp.local`

Después de eso, respetan cualquier variable ya presente en `process.env`.

## Protocolo para agentes

Si un MCP no está disponible:

1. No inventes datos.
2. Indica qué variable falta.
3. Pide al usuario completar `.env.mcp.local`.
4. Si sigue bloqueado, usa documentación local o mocks.
