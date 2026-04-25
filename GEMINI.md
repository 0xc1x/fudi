# Fudi Gemini Context

Usa **AGENTS.md** como la instrucción canónica de comportamiento para este repositorio.

@./AGENTS.md

## Carga obligatoria de contexto

Antes de cualquier tarea de producto o arquitectura, sincroniza con:
- `docs/ai/PRODUCT_BRIEF.md`
- `docs/ai/SYSTEM_ARCHITECTURE.md`
- `AGENT_SYSTEM_META.md` (mapa unificado de herramientas y agentes)
- `.agents/` (agentes especializados, ubicación neutral)

## Reglas de Ejecución

- Respeta siempre el Protocolo de Orquestación definido en `AGENTS.md`.
- Los agentes especializados están disponibles en `.agents/` — son proveedor-agnostic.
- No ejecutes builds tras realizar cambios.
- Prioriza la integridad arquitectónica y de negocio definida en la documentación central.
