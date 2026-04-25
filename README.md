# Fudi

Configuración base de agentes e instrucciones de trabajo para desarrollar **Fudi**, una app Flutter + Supabase + Sentry con landing/admin web enfocada en rescate de comida con **pickup-only** en fase 1.

> ⚡️ **Para una visión unificada del sistema agentic**, consulta `AGENT_SYSTEM_META.md`

## Archivos clave

- `AGENTS.md` -> instrucción canónica del repositorio
- `AGENT_SYSTEM_META.md` -> mapa unificado de herramientas y agentes
- `.agents/` -> agentes especializados (ubicación neutral, proveedor-agnostic)
- `GEMINI.md` -> contexto raíz para Gemini CLI
- `opencode.json` -> configuración base para OpenCode
- `.cursor/rules/` -> reglas de Cursor
- `.github/copilot-instructions.md` -> instrucciones globales para Copilot/Codex
- `docs/ai/` -> brief y arquitectura del proyecto

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
