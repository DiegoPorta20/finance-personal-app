---
name: flutter-screen-scaffold
description: Usar esta skill cuando se necesite crear una nueva pantalla, widget o componente visual en la app Flutter (ej. "crea la pantalla de Reportes", "agrega el widget de meta de ahorro"). Aplica el sistema de diseño del proyecto (tema oscuro + acento verde) y el patrón de manejo de estado elegido.
---

# Flutter Screen Scaffold

## Cuándo se activa

Cualquier pedido de crear una pantalla, widget reutilizable o componente visual nuevo en la app mobile.

## Estructura a generar

Para una feature `feature_name` (ej. `reports`, `savings_goals`):

```
lib/features/feature_name/
  presentation/
    screens/feature_name_screen.dart
    widgets/...
  application/feature_name_provider.dart   (Riverpod)
  domain/feature_name_model.dart
  data/feature_name_repository.dart
```

## Sistema de diseño (referencia visual del proyecto)

- Fondo principal: negro casi puro (~`#0E0E0F`).
- Tarjetas: gris oscuro (~`#1C1C1E`), bordes redondeados ~16-20px.
- Color de acento (positivo/ahorro/CTA): verde lima (~`#A4E832`).
- Texto principal: blanco. Texto secundario: gris claro (~`#9A9A9A`).
- Tipografía: títulos en negrita (bold), montos grandes destacados en el color de acento cuando son positivos.
- Los gráficos circulares de progreso (ej. "ahorro del mes") usan el verde de acento sobre un track gris oscuro.
- Iconos dentro de contenedores circulares blancos/grises para accesos rápidos (cuentas, acciones).

Estos valores son una referencia inicial: una vez exista un archivo real de design tokens (`lib/core/theme/app_theme.dart`), esa es la fuente de verdad y debe consultarse antes de hardcodear colores nuevos.

## Convenciones obligatorias

- Manejo de estado con Riverpod (`StateNotifierProvider` o `AsyncNotifierProvider` según corresponda).
- Nunca hacer llamadas HTTP directamente desde un widget; siempre a través del repository correspondiente.
- Los montos monetarios se formatean siempre con el helper común de formato de moneda del proyecto (no usar `toStringAsFixed` suelto en la UI).
- Las pantallas que muestran datos remotos deben manejar explícitamente los tres estados: cargando, error, datos vacíos.
- Los gráficos usan `fl_chart`; reutilizar los widgets de gráfico ya creados antes de construir uno nuevo desde cero.

## Después de generar

Recordar sugerir al usuario correr `flutter analyze` y, si la pantalla tiene lógica de negocio, agregar un test en `test/features/feature_name/`.
