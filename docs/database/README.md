# Database Documentation

Estructura de documentación para el esquema de base de datos de Fudi.

## Estructura

```
docs/database/
├── README.md              # Este archivo - índice general
├── CHANGELOG.md           # Historial de cambios en el esquema
├── schemas/               # Definiciones de esquema SQL
│   ├── 001_initial.sql    # Schema inicial
│   └── ...                # Esquemas subsiguientes
├── migrations/            # Scripts de migración
│   ├── 001_initial_up.sql
│   ├── 001_initial_down.sql
│   └── ...
└── diagrams/              # Diagramas ERD y visualizaciones
    └── README.md          # Instrucciones para generar diagramas
```

## Convenciones

### Nomenclatura

- **Tablas:** snake_case, plural (ej: `businesses`, `offers`, `orders`)
- **Columnas:** snake_case (ej: `created_at`, `business_id`)
- **Índices:** `idx_{tabla}_{columna}` (ej: `idx_offers_business_id`)
- **Foreign keys:** `fk_{tabla}_{columna}` (ej: `fk_orders_user_id`)
- **Migraciones:** `{número}_{descripción}.sql` (ej: `002_add_soft_deletes.sql`)

### Versionado de Migraciones

- Números secuenciales de 3 dígitos: 001, 002, 003...
- Cada migración tiene archivo `_up.sql` y `_down.sql`
- Archivo up = aplicar cambio
- Archivo down = revertir cambio
- Ambos deben ser idempotentes

### Trazabilidad

Cada cambio debe registrarse en `CHANGELOG.md` con:
- Fecha
- Autor/Agente
- Descripción del cambio
- Justificación
- Número de migración
- Impacto en la aplicación

## Agentes

El agente **Database Architect** (`.agents/database-architect.md`) es responsable de mantener esta documentación y los esquemas.

## Referencias

- `docs/ai/PRODUCT_BRIEF.md` - Entidades y relaciones del dominio
- `docs/ai/SYSTEM_ARCHITECTURE.md` - Stack y arquitectura
