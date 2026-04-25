# Fudi Product Brief

## Qué es Fudi

Fudi es una app para descubrir, reservar y recoger paquetes de comida con descuento publicados por negocios cercanos.

## Propuesta de valor

- Usuarios: encuentran ofertas cercanas a buen precio.
- Negocios: reducen merma y monetizan excedentes.
- Plataforma: coordina descubrimiento, reserva, pago y recogida.

## Roles

### Guest

- Sin registro
- Ve mapa, ofertas cercanas, populares y explorar
- Puede cambiar ubicación manualmente
- No puede ordenar ni pagar

### User

- Auth con email y providers
- Reserva y paga
- Consulta historial
- Configura radio de notificaciones y preferencias

### Business

- Ve dashboard operativo
- Gestiona catálogo y paquetes
- Define precio, disponibilidad y ventana de pickup
- Administra perfil del local
- Revisa pedidos y ventas

### Admin

- Alta y gestión de perfiles business
- Configuraciones globales de plataforma
- Operación prioritaria en web

## Pantallas mínimas fase 1

### Consumer

1. Home
   - mapa con ofertas cercanas
   - sección de populares
   - acceso a ubicación actual/manual
2. Explorar
   - mapa grande
   - filtros por categoría y precio
   - listado sincronizado con el mapa
3. Detalle de oferta / catálogo del local
   - paquetes filtrados
   - precio y pickup window
4. Perfil
   - datos del usuario
   - historial
   - preferencias y notificaciones

### Business

1. Dashboard
   - catálogo publicado
   - crear/editar/deshabilitar paquetes
   - precio y pickup window
2. Ventas/Pedidos
   - estados de pedido
   - validación de recogida
3. Perfil de local
   - contactos
   - ubicación
   - descripción
   - imágenes

### Admin Web

1. Gestión de negocios
2. Configuración global
3. Soporte operativo básico

### Landing Web

- hero atractivo
- cómo funciona
- beneficios para usuarios y negocios
- CTA para solicitar información
- base para captación comercial

## Límites de fase 1

- pickup-only
- sin delivery
- sin carrito
- misma codebase, no apps separadas por rol

## Decisión de carrito

Se descarta en fase 1 porque agrega complejidad innecesaria al flujo de reserva inmediata y al inventario escaso por paquete. La arquitectura debe dejar posibilidad de evolución futura, pero el flujo actual es directo: **seleccionar oferta -> reservar/pagar -> recoger**.
