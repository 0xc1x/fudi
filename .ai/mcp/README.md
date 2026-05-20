# Fudi MCP Setup

Este directorio centraliza la configuración MCP compartida del proyecto.

## Objetivo

Versionar en el repositorio una **fuente única de verdad** para los MCPs de Fudi sin subir secretos reales.

## MCPs incluidos

| Server | Tipo | Uso |
| --- | --- | --- |
| `github` | local / stdio | Issues, PRs y metadata del repositorio |
| `supabase` | remote / HTTP | Official Supabase MCP — Database, Auth, Storage, RLS |
| `openaiDeveloperDocs` | remote / HTTP | Documentación oficial de OpenAI |
| `chrome-devtools` | local / stdio | Inspección de páginas web via Chrome DevTools Protocol (snapshots, screenshots, red, performance, JS execution) |
| `context7` | remote / HTTP | Documentación actualizada de cualquier librería/framework en tiempo real |
| `react-docs` | remote / HTTP | Documentación oficial de React para análisis de código existente |
| `flutter-docs` | remote / HTTP | Documentación oficial de Flutter para desarrollo y migración |
| `flutter-testing` | remote / HTTP | Documentación de testing específico de Flutter |
| `jest-docs` | remote / HTTP | Documentación de Jest para entender patrones de testing React |
| `github-actions` | remote / HTTP | Documentación de GitHub Actions para CI/CD |
| `figma-api` | local / stdio | API de Figma para extraer designs y componentes (opcional) |
| `linear` | local / stdio | Integration con Linear para gestión de tareas (opcional) |

## Configs por herramienta

| Archivo | Herramienta |
| --- | --- |
| `opencode.json` | OpenCode |
| `.codex/config.toml` | Codex (OpenAI) |
| `.cursor/mcp.json` | Cursor |
| `.vscode/mcp.json` | VS Code / Copilot Agent |
| `.zed/settings.json` | Zed |
| `.gemini/settings.json` | Gemini CLI |
| `.claude/mcp.json` | Claude Code (project-level) |
| `.antigravitycli/mcp_config.json` | Antigravity CLI (project-level) |

### Configs globales (fuera del repo, por usuario)

| Ruta | Herramienta |
| --- | --- |
| `~/.claude/mcp/` | Claude Code (global) |
| `~/.gemini/antigravity-cli/mcp_config.json` | Antigravity CLI (global) |
| `~/.gemini/antigravity/mcp_config.json` | Antigravity IDE (global) |
| `~/.gemini/antigravity-ide/mcp_config.json` | Antigravity IDE (global) |

## Archivos importantes

| Archivo | Propósito |
| --- | --- |
| `.ai/mcp/mcp.manifest.json` | Catálogo canónico de MCPs y variables requeridas |
| `.ai/mcp/lib/env-loader.mjs` | Cargador compartido de variables desde archivos `.env*` |
| `.ai/mcp/launchers/github.mjs` | Launcher del MCP de GitHub |
| `.ai/mcp/launchers/supabase-postgres.mjs` | Launcher del MCP de Postgres/Supabase |
| `.ai/mcp/launchers/chrome-devtools.mjs` | Launcher del MCP de Chrome DevTools |
| `.ai/mcp/launchers/figma.mjs` | Launcher del MCP de Figma (opcional) |
| `.ai/mcp/launchers/linear.mjs` | Launcher del MCP de Linear (opcional) |

## Cómo se resuelven los secretos

Los launchers leen variables en este orden de prioridad:

1. variables del proceso ya exportadas
2. `.ai/mcp/.env.mcp.local`
3. `.env.mcp.local`
4. `.env.mcp`
5. `.env.local`
6. `.env`

> Recomendación: usa `.env.mcp.local` para secretos locales.
> El repo incluye `.env.mcp.example`, pero **no** incluye tokens reales.

## Compatibilidad runtime

Los launchers exponen variables canónicas del repo y las traducen a lo que espera cada paquete upstream:

| Server | Variable del repo | Variable runtime |
| --- | --- | --- |
| `github` | `GITHUB_PERSONAL_ACCESS_TOKEN` | `GITHUB_ACCESS_TOKEN` |
| `supabase-db` | `SUPABASE_DB_URL` | `DB_MAIN_URL` + aliases `main` |
| `figma-api` | `FIGMA_ACCESS_TOKEN` | `FIGMA_API_KEY` |

## Variables mínimas

| Variable | Obligatoria | Uso |
| --- | --- | --- |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | Sí | MCP de GitHub |
| `SUPABASE_DB_URL` | Sí | MCP de Postgres/Supabase |
| `FIGMA_ACCESS_TOKEN` | No | MCP de Figma (opcional) |
| `LINEAR_API_KEY` | No | MCP de Linear (opcional) |

## Chrome DevTools MCP

Para usar el MCP de Chrome DevTools, necesitas lanzar Chrome/Edge con remote debugging:

```powershell
# Chrome
chrome --remote-debugging-port=9222

# Edge
msedge --remote-debugging-port=9222
```

Luego el MCP se conecta automáticamente a la primera pestaña disponible.

Capacidades: snapshots del DOM, screenshots, inspección de red, auditorías Lighthouse, ejecución de JavaScript, emulación de dispositivos, traces de performance.

## Primer setup para un integrante nuevo

1. Copiar `.ai/mcp/.env.mcp.example` a `.ai/mcp/.env.mcp.local`
2. Completar valores reales
3. Abrir la herramienta que use:
   - OpenCode usa `opencode.json`
   - Codex usa `.codex/config.toml`
   - Gemini CLI usa `.gemini/settings.json`
   - Cursor usa `.cursor/mcp.json`
   - Zed usa `.zed/settings.json`
   - VS Code / Copilot Agent usa `.vscode/mcp.json`
   - Claude Code usa `.claude/mcp.json` (project) + `~/.claude/mcp/` (global)
   - Antigravity CLI usa `.antigravitycli/mcp_config.json` (project) + `~/.gemini/antigravity-cli/mcp_config.json` (global)

## Nota sobre Supabase / Postgres

La URL debe ser una cadena PostgreSQL válida, por ejemplo:

```env
SUPABASE_DB_URL=postgresql://postgres:password@db.example.supabase.co:5432/postgres
```

## Nota sobre OpenAI Docs MCP

No requiere token adicional porque es un endpoint de documentación pública:

`https://developers.openai.com/mcp`

## Nota sobre Context7 MCP

No requiere token. Es un endpoint público para consultar documentación actualizada:

`https://mcp.context7.com/mcp`

## Nota operativa importante

Abre la herramienta sobre la **raíz del repositorio** `fudi`. Los launchers resuelven secretos y runtime desde ahí.
