---
applyTo: "lib/**,test/**,integration_test/**,pubspec.yaml,analysis_options.yaml"
---

# Fudi Flutter Development Instructions

Toda la lógica de negocio y arquitectura base reside en `docs/ai/` y `AGENTS.md`. Consúltalos antes de implementar.

## Implementación Técnica

- **Clean Architecture + Feature-First:** Respeta la estructura `presentation`, `domain` y `data`. Las entidades y casos de uso deben ser agnósticos a Flutter y Supabase.
- **Estado e Inyección:** Riverpod es la única herramienta para gestión de estado e inyección de dependencias.
- **Seguridad en Capa Cliente:** Implementa guards y redirecciones basados estrictamente en el estado de sesión y el rol del perfil, según se define en `SYSTEM_ARCHITECTURE.md`.
- **Calidad de Código:**
    - Sigue las reglas de `analysis_options.yaml`.
    - No silencies warnings de linter sin una justificación arquitectónica.
    - Asegura que cada nueva funcionalidad incluya tests de lógica de negocio (domain) y de integración para flujos críticos (auth, orders).
