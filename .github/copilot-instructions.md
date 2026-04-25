# Fudi Copilot Instructions

Usa siempre `AGENTS.md` como la **Instrucción Canónica** del proyecto. Este archivo contiene el protocolo de comportamiento y orquestación para todas las IAs.

## Contexto de Verdad (Single Source of Truth)

Para cualquier duda sobre el negocio, arquitectura o reglas técnicas, consulta:
- [Instrucciones de Agentes](AGENTS.md)
- [Contexto de Producto](docs/ai/PRODUCT_BRIEF.md)
- [Arquitectura de Sistema](docs/ai/SYSTEM_ARCHITECTURE.md)
- [Mapa de Herramientas y Agentes](AGENT_SYSTEM_META.md)
- [Agentes Especializados](.agents/) (ubicación neutral, proveedor-agnostic)

## Guía de Prompting y Sugerencias

- **Sugerencias Cortas:** Prefiere completar líneas o bloques pequeños. Evita generar archivos enteros de una vez si no se ha validado la arquitectura con el usuario.
- **Contexto Local:** Antes de sugerir un nuevo widget o provider, busca uno existente en `lib/core/widgets/` o en la feature correspondiente.
- **Clean Architecture:** Si sugieres código en `presentation`, no permitas que importe nada de `data`. Respeta estrictamente el flujo `presentation -> domain <- data`.
- **Inferencia de Tipos:** No seas redundante con los tipos si Dart puede inferirlos, a menos que mejore la legibilidad en firmas públicas.
