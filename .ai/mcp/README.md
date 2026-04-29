# Fudi MCP Setup

Este directorio centraliza la configuración MCP compartida del proyecto.

## Objetivo

Versionar en el repositorio una **fuente única de verdad** para los MCPs de Fudi sin subir secretos reales.

## MCPs incluidos

| Server | Tipo | Uso |
| --- | --- | --- |
| `github` | local / stdio | Issues, PRs y metadata del repositorio |
| `supabase-db` | local / stdio | Introspección segura de Postgres/Supabase |
| `openaiDeveloperDocs` | remoto / HTTP | Documentación oficial de OpenAI |
| `react-docs` | remoto / HTTP | Documentación oficial de React para análisis de código existente |
| `flutter-docs` | remoto / HTTP | Documentación oficial de Flutter para desarrollo y migración |
| `flutter-testing` | remoto / HTTP | Documentación de testing específico de Flutter |
| `jest-docs` | remoto / HTTP | Documentación de Jest para entender patrones de testing React |
| `github-actions` | remoto / HTTP | Documentación de GitHub Actions para CI/CD |
| `figma-api` | local / stdio | API de Figma para extraer designs y componentes (opcional) |
| `linear` | local / stdio | Integration con Linear para gestión de tareas (opcional) |

## Archivos importantes

| Archivo | Propósito |
| --- | --- |
| `.ai/mcp/mcp.manifest.json` | Catálogo canónico de MCPs y variables requeridas |
| `.ai/mcp/lib/env-loader.mjs` | Cargador compartido de variables desde archivos `.env*` |
| `.ai/mcp/launchers/github.mjs` | Launcher del MCP de GitHub |
| `.ai/mcp/launchers/supabase-postgres.mjs` | Launcher del MCP de Postgres/Supabase |
| `.codex/config.toml` | Config project-scoped de Codex |
| `.gemini/settings.json` | Config project-scoped de Gemini CLI |
| `opencode.json` | Config project-scoped de OpenCode |
| `.cursor/mcp.json` | Config project-scoped de Cursor |
| `.zed/settings.json` | Config project-scoped de Zed |
| `.vscode/mcp.json` | Config project-scoped para VS Code / Copilot Agent |

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

## Primer setup para un integrante nuevo

1. Copiar `.ai/mcp/.env.mcp.example` a `.ai/mcp/.env.mcp.local`
2. Completar valores reales
3. Abrir la herramienta que use:
   - Codex usa `.codex/config.toml`
   - Gemini CLI usa `.gemini/settings.json`
   - OpenCode usa `opencode.json`
   - Cursor usa `.cursor/mcp.json`
   - Zed usa `.zed/settings.json` o, si su versión no aplica `context_servers` en project settings, copiar el mismo bloque a su settings global
   - VS Code / Copilot Agent usa `.vscode/mcp.json`

## Nota sobre Supabase / Postgres

La URL debe ser una cadena PostgreSQL válida, por ejemplo:

```env
SUPABASE_DB_URL=postgresql://postgres:password@db.example.supabase.co:5432/postgres
```

## Nota sobre OpenAI Docs MCP

No requiere token adicional porque es un endpoint de documentación pública:

`https://developers.openai.com/mcp`

## Nota operativa importante

Abre la herramienta sobre la **raíz del repositorio** `fudi`. Los launchers resuelven secretos y runtime desde ahí.
