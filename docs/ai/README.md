# Fudi AI System

Este directorio es el núcleo documental del sistema agentic de Fudi.

## Objetivo

Centralizar reglas, arquitectura, contexto de producto y configuración MCP para que varias herramientas operen con coherencia.

## Archivos principales

| Archivo | Nivel | Propósito |
| --- | --- | --- |
| `AGENTS.md` | Comportamiento | Reglas operativas y criterio del agente |
| `docs/ai/PRODUCT_BRIEF.md` | Producto | Roles, pantallas, alcance y restricciones |
| `docs/ai/SYSTEM_ARCHITECTURE.md` | Arquitectura | Stack, módulos y decisiones técnicas |
| `docs/ai/MCP_CAPABILITIES.md` | Herramientas | MCPs compartidos, variables y estrategia de uso |
| `AGENT_SYSTEM_META.md` | Meta | Mapa unificado de agentes y herramientas |

## Agentes especializados

Los roles viven en `.agents/`:

- `fudi-orchestrator`
- `architect`
- `ux-ui`
- `business-logic`
- `test-engineer`
- `accessibility-observability`
- `integrations`
- `deployment-sre`
- `technical-documentation`

## MCP compartidos

El proyecto versiona una base compartida en `.ai/mcp/`.

- Usa `.env.mcp.example` como plantilla
- Completa secretos en `.env.mcp.local`
- Cada herramienta consume su archivo nativo del repo

## Protocolo de actualización

Si cambia negocio, arquitectura o tooling:

1. Actualiza el documento fuente correcto.
2. Si cambia un MCP o variable, actualiza también `.ai/mcp/` y `docs/ai/MCP_CAPABILITIES.md`.
3. Mantén alineados los adaptadores por herramienta.
