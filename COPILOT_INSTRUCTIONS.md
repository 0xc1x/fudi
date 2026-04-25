# Fudi Copilot / Codex Instructions

Este archivo complementa `.github/copilot-instructions.md` y existe para compatibilidad con herramientas que buscan un archivo raíz explícito. Para una visión unificada del sistema agentic, consulta `AGENT_SYSTEM_META.md`.

## Reglas base

- Proyecto: **Fudi**
- Stack: Flutter + Riverpod + Supabase + Sentry + Maps + pagos
- Arquitectura: Clean Architecture + Feature-First
- Fase 1: pickup-only
- Sin carrito en fase 1
- `guest` no es rol persistido
- Roles persistidos: `user`, `business`, `admin`
- `business` usa dashboard propio
- `admin` opera principalmente desde web

## Calidad

- Nada de lógica de negocio en UI
- Añadir tests en lógica crítica
- Mantener accesibilidad WCAG AA
- Mantener logs útiles y sin datos sensibles
- Nunca ejecutar builds después de editar

## Fuente canónica

Consulta también:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `docs/ai/README.md`
- `AGENT_SYSTEM_META.md`
- `.agents/` (agentes especializados, ubicación neutral)
