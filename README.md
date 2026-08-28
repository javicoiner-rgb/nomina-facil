# Nómina Fácil

**Tu sueldo real, sin sorpresas.** Calculadora de nómina y sueldo neto para
España, pensada para público joven (Gen Z / Millennials). Material Design 3,
colores vibrantes, cero fricción.

- 100 % **offline**: sin APIs, sin backend, sin Firebase. Todos los cálculos
  se hacen en el dispositivo.
- Sin registro y sin recogida de datos.
- Datos fiscales del ejercicio **2026** (ver `FISCAL_NOTES.md`).

---

## Los tres modos

| Modo | Qué hace | Precio |
|------|----------|--------|
| **Directo** | Mueve el slider de bruto anual y mira tu neto al instante (sin botón "calcular"). Desglose de IRPF, Seguridad Social y neto. | Gratis |
| **Sorpresa** | Introduce tu bruto actual y una subida: te dice cuántos euros **netos** más al mes ganarías de verdad, con frase lista para compartir. | Gratis |
| **Negociación** (inverso) | Dime el neto que quieres cobrar al mes y te digo el **bruto anual que pedir**. Frase lista para copiar. | PRO |

El paywall (RevenueCat) **solo** bloquea el Modo Negociación. Los modos
Directo y Sorpresa son siempre gratuitos.

---

## Estructura del proyecto

```
lib/
  main.dart                 Punto de entrada. Inicializa Provider + PurchaseService.
  app.dart                  MaterialApp, tema Material 3, rutas nombradas.
  models/
    tax_data_2026.dart      Escala de retención (art. 85 RIRPF), SS 6,50 %, mínimos. DATOS.
    tax_calculator.dart     Lógica de cálculo (neto, inverso por bisección, delta).
    calculation_result.dart CalculationResult y DeltaResult.
    ccaa_model.dart          CCAA y TramoIRPF.
  screens/
    home_screen.dart        Inicio: 3 tarjetas de modo + aviso legal.
    modo_directo_screen.dart
    modo_sorpresa_screen.dart
    modo_inverso_screen.dart Muestra el paywall incrustado si el usuario no es PRO.
    paywall_screen.dart     Reutilizable como ruta o incrustada.
  widgets/
    salary_slider_widget.dart
    result_card_widget.dart
    ccaa_selector_widget.dart
    breakdown_row_widget.dart
    modo_card_widget.dart
    opciones_nomina_widget.dart   Selector de pagas (12/14) y de hijos.
  services/
    purchase_service.dart   RevenueCat. Degrada con elegancia sin red ni claves.
  constants/
    app_colors.dart         Paleta (primary 0xFF00C896, etc.).
    app_strings.dart         Todos los textos de la UI, en español.
    app_constants.dart       Rangos de sliders, rutas, límites de bisección.
    formatters.dart          Formato € y % al estilo español, sin dependencias.
test/
  tax_calculator_test.dart  Pruebas de la calculadora.
```

### Dependencias

- `purchases_flutter` — compras in-app / suscripción PRO (RevenueCat).
- `share_plus` — compartir la frase del Modo Sorpresa.
- `google_fonts` — tipografía moderna (Plus Jakarta Sans).
- `provider` — estado del `PurchaseService`.
- `flutter_svg` — iconografía vectorial.

---

## Cómo ejecutar

```bash
cd nomina_facil
flutter pub get
flutter run              # dispositivo/emulador conectado
flutter run -d chrome    # web
flutter test             # pruebas
flutter analyze          # análisis estático
```

### Configurar RevenueCat (opcional)

La app funciona sin configurar nada: si las claves siguen con el valor
`TU_CLAVE`, el `PurchaseService` no se inicializa y el Modo Negociación
muestra el paywall sin precio real.

Para activarlo, edita `lib/constants/app_constants.dart`:

```dart
static const String revenueCatApiKeyAndroid = 'goog_...';
static const String revenueCatApiKeyIos = 'appl_...';
static const String entitlementPro = 'pro'; // debe coincidir con RevenueCat
```

Para pruebas locales sin store: `context.read<PurchaseService>().activarProDemo()`.

---

## Cómo actualizar los tramos de IRPF cada enero

Toda la parametrización fiscal vive en **un solo archivo**:
`lib/models/tax_data_2026.dart`.

1. **Renombra el archivo y la clase** al nuevo ejercicio, p. ej.
   `tax_data_2027.dart` / `TaxData2027`, y actualiza los imports
   (`tax_calculator.dart`, widgets y pantallas que lo referencian) y
   `AppConstants.anioFiscal`.
2. **Escala de retención** (`tramosRetencion`, art. 85 RIRPF, 19/24/30/…):
   es la que usa la nómina y no varía por CCAA. Comprueba también la escala
   estatal de referencia (`tramosEstatales`, art. 63). Suelen no cambiar
   salvo reforma.
3. **Seguridad Social**: revisa el % del trabajador (contingencias comunes,
   desempleo, formación) y **el tipo del MEI** de ese año (`ssMEI`; en 2026
   es 0,15 % y sube ~0,10 pp/año). Actualiza `baseMaximaCotizacionAnual` con
   la nueva base máxima (base mensual × 12).
4. **Mínimo personal y familiar** (`minimoContribuyente`,
   `minimoPorDescendientesAcumulado`): art. 57-61 LIRPF.
5. **Reducción por rendimientos del trabajo** (art. 20): revisa umbrales e
   importe máximo (`reduccionTrabajo*`). Hoy: 7.302 € hasta 16.825 €,
   decreciente hasta 0 en 21.000 €.
6. **Escalas autonómicas** (`comunidades`): solo se usan para el régimen
   foral (País Vasco) y como referencia. Cada CCAA publica su escala en su
   Ley de Medidas Fiscales. El País Vasco y Navarra son forales
   (`esForal: true`, escala completa).
7. Ejecuta `flutter test`. Los tests son de coherencia (neto < bruto,
   monotonía, ida y vuelta de la bisección); si fallan, revisa los datos.
8. Anota la fuente y la fecha en `FISCAL_NOTES.md`.

---

## Aviso legal

El resultado es **orientativo**. Es una estimación de la retención de IRPF
y no sustituye a tu nómina oficial, a la Agencia Tributaria ni a tu asesor
fiscal. No contempla situaciones particulares (movilidad geográfica,
discapacidad, pensiones compensatorias, tipo mínimo por rentas irregulares,
regularizaciones, etc.).
