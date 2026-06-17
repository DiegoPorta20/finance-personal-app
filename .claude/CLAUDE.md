# CLAUDE.md — Mobile (Flutter)

Este archivo le da contexto a Claude Code cada vez que trabaje en este repositorio. Colócalo en la raíz del proyecto Flutter.

## Qué es este proyecto

App móvil de finanzas personales. Consume la API NestJS del backend del mismo producto. Permite gestionar cuentas, configurar ingresos, registrar egresos, ver historial de transacciones, visualizar reportes estadísticos y recibir recomendaciones de presupuesto y metas de ahorro.

Ver `01-prospecto.md` (compartido entre ambos repos) para el detalle funcional completo, y la referencia visual del dashboard (tema oscuro + acento verde, balance destacado, anillo de progreso de ahorro, tarjetas de cuentas, historial con tabs All/Spending/Income).

## Stack tecnológico

- Flutter + Dart
- Riverpod (manejo de estado)
- Dio (cliente HTTP)
- go_router (navegación)
- fl_chart (gráficos: pastel, línea, barras, progreso circular)

> Si el proyecto real usa Bloc/Provider/GetX en vez de Riverpod, actualiza esta sección primero — el resto de las convenciones se mantienen igual.

## Estructura de carpetas (feature-first)

```
lib/
  core/
    theme/                # colores, tipografía, design tokens
    network/               # cliente Dio, interceptores
    utils/                  # formato de moneda, fechas
  features/
    auth/
    dashboard/
    accounts/
    transactions/           # agregar/listar ingresos y egresos
    reports/                # gráficos estadísticos
    budget/                 # presupuesto y recomendaciones
    savings_goals/
    settings/               # configuración de ingresos, categorías, tema
```

Cada feature sigue el patrón `presentation / application / domain / data` (ver skill `flutter-screen-scaffold`).

## Sistema de diseño

Basado en la referencia visual del producto:
- Fondo: negro casi puro (~`#0E0E0F`).
- Tarjetas: gris oscuro (~`#1C1C1E`), esquinas redondeadas (16-20px).
- Acento principal (positivo, CTA, ahorro): verde lima (~`#A4E832`).
- Texto principal blanco, texto secundario gris claro (~`#9A9A9A`).
- El balance total y los montos positivos se destacan en el color de acento.
- Iconografía dentro de contenedores circulares para accesos rápidos a cuentas y acciones.

Una vez exista `lib/core/theme/app_theme.dart` con los valores definitivos, ese archivo es la fuente de verdad — no hardcodear colores nuevos sin antes revisarlo.

## Convenciones del proyecto

- Ningún widget de pantalla llama directamente a Dio; siempre pasa por un `repository`.
- El estado de pantallas con datos remotos siempre maneja 3 casos: cargando, error, vacío.
- Los montos se formatean siempre con el helper común de moneda (`core/utils/currency_formatter.dart`), nunca con `toStringAsFixed` suelto.
- Los gráficos se construyen con `fl_chart`; antes de crear un widget de gráfico nuevo, revisar si ya existe uno reutilizable en `core/widgets/charts/`.
- Las categorías de ingreso/egreso y la regla de presupuesto deben coincidir exactamente con el backend — ver skill `finance-domain-conventions`.

## Pantallas principales

1. Login / Onboarding
2. Dashboard (balance, anillo de ahorro del mes, accesos a cuentas)
3. Cuentas
4. Agregar transacción (ingreso/egreso)
5. Historial de transacciones (tabs All / Spending / Income)
6. Reportes (gasto por categoría, tendencia de ahorro, ingresos vs. egresos)
7. Presupuesto y recomendaciones
8. Metas de ahorro
9. Configuración (ingresos recurrentes, categorías, notificaciones, tema claro/oscuro)

## Integración con el backend

- Base URL configurable por entorno (`--dart-define=API_BASE_URL=...`), nunca hardcodeada.
- El token JWT se guarda con almacenamiento seguro (`flutter_secure_storage`), nunca en `SharedPreferences` en texto plano.
- Los modelos de datos (`domain/*.dart`) deben reflejar exactamente los DTOs de salida del backend; si el backend cambia un campo, actualizar el modelo en la misma sesión.

## Testing

- Widgets con lógica de negocio (ej. cálculo de progreso de meta de ahorro) deben tener un test en `test/features/.../`.
- Antes de dar por cerrada una pantalla nueva, correr `flutter analyze` y revisar que no haya warnings.

## Comandos habituales

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk        # o ios, según destino
```

## Qué evitar

- No mezclar lógica de negocio dentro de los widgets de presentación.
- No duplicar el catálogo de categorías o la regla de presupuesto — usar la skill `finance-domain-conventions` como única fuente.
- No usar `localStorage`/almacenamiento inseguro para el token de autenticación.
