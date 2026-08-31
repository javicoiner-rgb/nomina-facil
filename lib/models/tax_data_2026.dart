import 'ccaa_model.dart';

/// Datos fiscales del ejercicio 2026 usados por [TaxCalculator].
///
/// FUENTE Y ACTUALIZACIÓN: ver `FISCAL_NOTES.md` en la raíz del proyecto.
/// Todos los importes están en euros y los tipos en tanto por uno.
///
/// Estos datos son ORIENTATIVOS. Algunas comunidades aún podían no haber
/// publicado su escala definitiva para 2026 en el momento de esta versión;
/// en esos casos se ha mantenido la última escala vigente conocida.
class TaxData2026 {
  TaxData2026._();

  static const int anio = 2026;

  // =====================================================================
  // 1. ESCALAS DEL IRPF
  // =====================================================================

  /// Escala general **estatal** (art. 63.1.1º LIRPF). Es la mitad de la
  /// carga: en la declaración anual se le suma la escala autonómica de
  /// cada comunidad. Se conserva para el cálculo de la cuota diferencial
  /// y para el régimen foral.
  static const List<TramoIRPF> tramosEstatales = [
    TramoIRPF(12450, 0.0950),
    TramoIRPF(20200, 0.1200),
    TramoIRPF(35200, 0.1500),
    TramoIRPF(60000, 0.1850),
    TramoIRPF(300000, 0.2250),
    TramoIRPF(double.infinity, 0.2450),
  ];

  /// Escala de **retención** del art. 85.1.1º RIRPF (RD 439/2007). Es la
  /// que el pagador aplica en nómina y **no varía por comunidad autónoma**
  /// (equivale a la escala estatal + un tramo autonómico general idéntico).
  /// Las diferencias reales entre comunidades de régimen común se
  /// regularizan en la declaración de la renta, no en la nómina mensual.
  static const List<TramoIRPF> tramosRetencion = [
    TramoIRPF(12450, 0.1900),
    TramoIRPF(20200, 0.2400),
    TramoIRPF(35200, 0.3000),
    TramoIRPF(60000, 0.3700),
    TramoIRPF(300000, 0.4500),
    TramoIRPF(double.infinity, 0.4700),
  ];

  // =====================================================================
  // 2. COTIZACIÓN DEL TRABAJADOR A LA SEGURIDAD SOCIAL
  // =====================================================================
  //
  // Régimen general. Total 6,50 % en 2026:
  //   - Contingencias comunes .............. 4,70 %
  //   - Desempleo (contrato indefinido) .... 1,55 %
  //   - Formación profesional ............. 0,10 %
  //   - MEI (Mec. de Equidad Intergener.) . 0,15 %
  //
  // El MEI a cargo del trabajador sube al 0,15 % en 2026 (0,90 % total,
  // 0,75 % a cargo de la empresa). Ver FISCAL_NOTES.md.

  static const double ssContingenciasComunes = 0.0470;
  static const double ssDesempleo = 0.0155;
  static const double ssFormacion = 0.0010;
  static const double ssMEI = 0.0015;

  /// Tipo total de cotización del trabajador (6,50 %).
  static const double ssEmpleadoTotal =
      ssContingenciasComunes + ssDesempleo + ssFormacion + ssMEI;

  /// Base máxima de cotización anual (4.909,50 €/mes x 12).
  /// Aproximada para 2026; ver notas.
  static const double baseMaximaCotizacionAnual = 58914;

  /// Base mínima de cotización anual aproximada (grupo 1).
  static const double baseMinimaCotizacionAnual = 18606;

  // =====================================================================
  // 3. MÍNIMO PERSONAL Y FAMILIAR (arts. 57 a 61 LIRPF)
  // =====================================================================

  /// Mínimo del contribuyente (menor de 65 años).
  static const double minimoContribuyente = 5550;

  /// Mínimo por descendiente, importe ACUMULADO según número de hijos.
  ///   índice 0 -> sin hijos
  ///   índice 1 -> 1 hijo   (2.400)
  ///   índice 2 -> 2 hijos  (2.400 + 2.700)
  ///   índice 3 -> 3 o más  (2.400 + 2.700 + 4.000)
  static const List<double> minimoPorDescendientesAcumulado = [
    0,
    2400,
    2400 + 2700,
    2400 + 2700 + 4000,
  ];

  /// Devuelve el mínimo personal y familiar total para [numHijos].
  static double minimoPersonalYFamiliar(int numHijos) {
    final indice = numHijos.clamp(0, minimoPorDescendientesAcumulado.length - 1);
    return minimoContribuyente + minimoPorDescendientesAcumulado[indice];
  }

  // =====================================================================
  // 4. REDUCCIÓN POR OBTENCIÓN DE RENDIMIENTOS DEL TRABAJO (art. 20)
  // =====================================================================
  //
  // Valores 2026 (actualizados con la subida del SMI). Se aplica sobre el
  // rendimiento neto del trabajo:
  //   RNT <= 16.825 € ......................... 7.302 €
  //   16.825 € < RNT <= 21.000 € ............. decrece linealmente hasta 0
  //   RNT > 21.000 € ......................... 0 €
  //
  // A partir de 21.000 € de rendimiento la reducción es 0: para un bruto
  // de 30.000 € NO hay reducción por trabajo.

  static const double reduccionTrabajoMaxima = 7302;
  static const double reduccionTrabajoUmbralInferior = 16825;
  static const double reduccionTrabajoUmbralSuperior = 21000;

  /// Pendiente de la parte decreciente: lleva la reducción de su valor
  /// máximo a 0 justo en [reduccionTrabajoUmbralSuperior].
  static double get reduccionTrabajoPendiente =>
      reduccionTrabajoMaxima /
      (reduccionTrabajoUmbralSuperior - reduccionTrabajoUmbralInferior);

  /// Gasto genérico del art. 19.2.f LIRPF (2.000 € en la normativa).
  ///
  /// SE MANTIENE EN 0 A PROPÓSITO. La app define la base del IRPF como
  /// `bruto − cotización a la Seguridad Social`, sin restar este gasto.
  /// Motivos:
  ///   1. Es el criterio de las fuentes de referencia verificadas para
  ///      2026 con las que se contrastó la calculadora.
  ///   2. El público objetivo son sueldos > 20.000 €, donde el efecto de
  ///      los 2.000 € sobre el tipo efectivo es de ~1-2 puntos y las
  ///      fuentes de mercado tienden a no aplicarlo en la estimación de
  ///      nómina (sí en la declaración anual).
  ///   3. Simplifica el modelo y lo hace algo más conservador (la
  ///      retención estimada nunca queda por debajo de la real).
  ///
  /// CONTRAPARTIDA: en rentas cercanas al SMI la retención estimada sale
  /// ~200-400 €/año por encima de la real (que es casi 0). Si se quiere el
  /// procedimiento estricto de la AEAT, basta con poner este valor en 2000
  /// (el resto del cálculo ya lo tiene en cuenta).
  static const double otrosGastosDeducibles = 0;

  static double reduccionPorTrabajo(double rendimientoNeto) {
    if (rendimientoNeto <= reduccionTrabajoUmbralInferior) {
      return reduccionTrabajoMaxima;
    }
    if (rendimientoNeto <= reduccionTrabajoUmbralSuperior) {
      return reduccionTrabajoMaxima -
          reduccionTrabajoPendiente *
              (rendimientoNeto - reduccionTrabajoUmbralInferior);
    }
    return 0;
  }

  // =====================================================================
  // 5. ESCALAS AUTONÓMICAS DEL IRPF
  // =====================================================================
  //
  // Una entrada por cada comunidad soportada, ordenadas alfabéticamente
  // (régimen común) con las forales (Navarra y País Vasco) al final. Las
  // forales tienen [esForal] = true y su lista contiene la escala foral
  // COMPLETA (estatal + foral juntas); el selector las marca "· foral".

  static const List<CCAA> comunidades = [
    CCAA(
      id: 'andalucia',
      nombre: 'Andalucía',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(13000, 0.0950),
        TramoIRPF(21000, 0.1200),
        TramoIRPF(35200, 0.1500),
        TramoIRPF(60000, 0.1850),
        TramoIRPF(double.infinity, 0.2250),
      ],
    ),
    CCAA(
      id: 'aragon',
      nombre: 'Aragón',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(13972.50, 0.0950),
        TramoIRPF(21209.10, 0.1200),
        TramoIRPF(36960.00, 0.1500),
        TramoIRPF(52360.00, 0.1850),
        TramoIRPF(61100.00, 0.2050),
        TramoIRPF(82360.00, 0.2300),
        TramoIRPF(102360.00, 0.2400),
        TramoIRPF(122360.00, 0.2450),
        TramoIRPF(double.infinity, 0.2500),
      ],
    ),
    CCAA(
      id: 'asturias',
      nombre: 'Asturias',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el BOPA. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'baleares',
      nombre: 'Baleares',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el BOIB. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'canarias',
      nombre: 'Canarias',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12450, 0.0900),
        TramoIRPF(17707.20, 0.1150),
        TramoIRPF(33007.20, 0.1400),
        TramoIRPF(53407.20, 0.1850),
        TramoIRPF(90000, 0.2350),
        TramoIRPF(double.infinity, 0.2400),
      ],
    ),
    CCAA(
      id: 'cantabria',
      nombre: 'Cantabria',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el BOC. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'castilla_la_mancha',
      nombre: 'Castilla-La Mancha',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el DOCM. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'castilla_leon',
      nombre: 'Castilla y León',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12450, 0.0900),
        TramoIRPF(20200, 0.1200),
        TramoIRPF(35200, 0.1400),
        TramoIRPF(53407.20, 0.1850),
        TramoIRPF(double.infinity, 0.2150),
      ],
    ),
    CCAA(
      id: 'cataluna',
      nombre: 'Cataluña',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12450, 0.1050),
        TramoIRPF(17707.20, 0.1200),
        TramoIRPF(21000, 0.1400),
        TramoIRPF(33007.20, 0.1500),
        TramoIRPF(53407.20, 0.1880),
        TramoIRPF(90000, 0.2150),
        TramoIRPF(120000, 0.2350),
        TramoIRPF(175000, 0.2450),
        TramoIRPF(double.infinity, 0.2550),
      ],
    ),
    CCAA(
      id: 'valencia',
      nombre: 'C. Valenciana',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12000, 0.0900),
        TramoIRPF(22000, 0.1200),
        TramoIRPF(32000, 0.1500),
        TramoIRPF(42000, 0.1750),
        TramoIRPF(62000, 0.2000),
        TramoIRPF(72000, 0.2250),
        TramoIRPF(100000, 0.2500),
        TramoIRPF(150000, 0.2650),
        TramoIRPF(200000, 0.2750),
        TramoIRPF(double.infinity, 0.2950),
      ],
    ),
    CCAA(
      id: 'extremadura',
      nombre: 'Extremadura',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el DOE. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'galicia',
      nombre: 'Galicia',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12985, 0.0900),
        TramoIRPF(21068, 0.1165),
        TramoIRPF(35200, 0.1490),
        TramoIRPF(47600, 0.1840),
        TramoIRPF(60000, 0.2050),
        TramoIRPF(double.infinity, 0.2250),
      ],
    ),
    CCAA(
      id: 'madrid',
      nombre: 'Madrid',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(13362.22, 0.0850),
        TramoIRPF(19004.63, 0.1070),
        TramoIRPF(35425.68, 0.1280),
        TramoIRPF(57320.40, 0.1740),
        TramoIRPF(double.infinity, 0.2050),
      ],
    ),
    CCAA(
      id: 'murcia',
      nombre: 'Murcia',
      descripcion:
          'La retención en nómina usa la escala estatal (art. 85 RIRPF), '
          'igual en todo el régimen común. La diferencia autonómica se '
          'regulariza en la declaración de la renta.',
      tramosAutonomicos: [
        TramoIRPF(12450, 0.0950),
        TramoIRPF(20200, 0.1120),
        TramoIRPF(34000, 0.1330),
        TramoIRPF(60000, 0.1790),
        TramoIRPF(double.infinity, 0.2250),
      ],
    ),
    CCAA(
      id: 'la_rioja',
      nombre: 'La Rioja',
      descripcion:
          'Escala autonómica pendiente de confirmar contra el BOR. Se usa '
          'como aproximación la escala general estatal (art. 63.1.1º '
          'LIRPF); la retención en nómina no cambia, ya que siempre usa la '
          'escala de retención estatal (art. 85 RIRPF).',
      // Escala pendiente de confirmar contra BOE autonómico
      tramosAutonomicos: tramosEstatales,
    ),
    CCAA(
      id: 'navarra',
      nombre: 'Navarra',
      esForal: true,
      descripcion:
          'Régimen foral. Escala pendiente de confirmar contra el BOE '
          'navarro: se usa como aproximación la misma escala foral que el '
          'País Vasco, con el cálculo simplificado de deducción general '
          'del trabajo.',
      // Escala pendiente de confirmar contra BOE autonómico (aproximación
      // provisional con la escala foral del País Vasco).
      tramosAutonomicos: [
        TramoIRPF(17720, 0.2300),
        TramoIRPF(35440, 0.2800),
        TramoIRPF(53160, 0.3500),
        TramoIRPF(70880, 0.4000),
        TramoIRPF(97240, 0.4500),
        TramoIRPF(132930, 0.4600),
        TramoIRPF(177240, 0.4700),
        TramoIRPF(double.infinity, 0.4900),
      ],
    ),
    CCAA(
      id: 'pais_vasco',
      nombre: 'País Vasco',
      esForal: true,
      descripcion:
          'Régimen foral: escala única (no se suma la escala estatal). '
          'Cálculo simplificado con deducción general del trabajo.',
      tramosAutonomicos: [
        TramoIRPF(17720, 0.2300),
        TramoIRPF(35440, 0.2800),
        TramoIRPF(53160, 0.3500),
        TramoIRPF(70880, 0.4000),
        TramoIRPF(97240, 0.4500),
        TramoIRPF(132930, 0.4600),
        TramoIRPF(177240, 0.4700),
        TramoIRPF(double.infinity, 0.4900),
      ],
    ),
  ];

  /// Comunidad por defecto (Madrid).
  static const String ccaaPorDefecto = 'madrid';

  /// Busca una comunidad por [id]; devuelve Madrid si no se encuentra.
  static CCAA comunidadPorId(String id) {
    return comunidades.firstWhere(
      (c) => c.id == id,
      orElse: () => comunidades.first,
    );
  }

  // =====================================================================
  // 6. PARÁMETROS DEL RÉGIMEN FORAL (simplificados)
  // =====================================================================

  /// Deducción general foral por rendimientos del trabajo (aprox.).
  static const double deduccionForalTrabajo = 4400;

  /// Deducción foral por descendiente, importe ACUMULADO.
  static const List<double> deduccionForalDescendientesAcumulada = [
    0,
    663,
    663 + 822,
    663 + 822 + 1390,
  ];

  static double deduccionForalPorHijos(int numHijos) {
    final indice = numHijos.clamp(
      0,
      deduccionForalDescendientesAcumulada.length - 1,
    );
    return deduccionForalDescendientesAcumulada[indice];
  }
}
