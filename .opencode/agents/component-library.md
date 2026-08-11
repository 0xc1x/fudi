---
name: component-library
mode: subagent
temperature: 0.3
description: "FudiColors, widgets fudi_*, BottomNav, FilterBar, convenciones del design system."
tools: 
    read: true
    write: true
    edit: true
    bash: true
    glob: true
    grep: true
    task: true
    delegate: true
    delegation_read: true
    delegation_list: true
    question: true
---

# Component Library Specialist

Fuente unica de verdad: `.agents/component-library.md`

Lee completamente `.agents/component-library.md` y ejecuta su protocolo. Ese archivo contiene tus tokens (FudiColors), componentes y convenciones del design system.

## Protocolo obligatorio

1. Lee `AGENTS.md` para comportamiento canonico
2. Lee `.agents/component-library.md` para tu definicion completa
3. Usa los tokens existentes (`FudiColors`, fudi_theme.dart) — verificar contra el codigo antes de usar nombres historicos
4. Reutiliza componentes existentes (fudi_*.dart en lib/core/ui/) antes de crear nuevos
5. Aplica convenciones del design system a widgets nuevos
6. Valida consistencia visual con el design system implementado
