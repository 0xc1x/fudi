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

### `supabase` (MCP oficial — unico)

- **Tipo:** remoto / HTTP (hosted por Supabase)
- **URL:** `https://mcp.supabase.com/mcp?project_ref=sxqopofoynsqkztozlix&features=docs%2Caccount%2Cdatabase%2Cdebugging%2Cdevelopment%2Cfunctions%2Cbranching`
- **Variable requerida:** ninguna — usa OAuth por harness
- **Auth:** cada herramienta autentica por su cuenta (login de Supabase):
  - OpenCode: `opencode mcp auth supabase`
  - Codex: `codex mcp login supabase`
  - Cursor / VS Code / Zed / Gemini / Claude: flujo OAuth del cliente MCP
- **Features activadas:** `docs`, `account`, `database`, `debugging`, `development`, `functions`, `branching`
- **Tools principales (feature database):** `list_tables`, `execute_sql`, `list_extensions`, `list_migrations`, `apply_migration`
- **Uso:** introspección de esquema, tablas, columnas, relaciones, migraciones y consultas sobre Supabase.

> **Nota:** No existe launcher local ni variable `SUPABASE_DB_URL` para este MCP. Cualquier config con `supabase-db` / `supabase-postgres.mjs` es obsoleta — usar el remoto oficial.

### `github`

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/github.mjs`
- **Variable requerida:** `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Variable runtime upstream:** `GITHUB_ACCESS_TOKEN`
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
- **Variable runtime upstream:** `FIGMA_API_KEY`
- **Uso:** API de Figma para extraer designs, componentes y especificaciones visuales.

### `linear` (opcional)

- **Tipo:** local / stdio
- **Launcher:** `.ai/mcp/launchers/linear.mjs`
- **Variable requerida:** `LINEAR_API_KEY`
- **Uso:** integration con Linear para gestión de tareas y bugs.

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
5. `.ai/mcp/.env.mcp.local`

Después de eso, respetan cualquier variable ya presente en `process.env`.

## Protocolo para agentes

Si un MCP no está disponible:

1. No inventes datos.
2. Indica qué variable falta.
3. Pide al usuario completar `.env.mcp.local`.
4. Si sigue bloqueado, usa documentación local o mocks.
