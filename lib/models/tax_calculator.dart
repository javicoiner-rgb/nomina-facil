import '../constants/app_constants.dart';
import 'calculation_result.dart';
import 'ccaa_model.dart';
import 'tax_data_2026.dart';

/// Calculadora de nómina para España (ejercicio 2026).
///
/// Todo el cálculo se hace en el dispositivo, sin APIs ni backend.
/// El resultado es una estimación de la RETENCIÓN de IRPF (no de la
/// declaración anual) siguiendo el procedimiento del art. 82 y ss. RIRPF
/// de forma simplificada:
///
///   1. Rendimiento íntegro = bruto.
///   2. Base del IRPF = bruto − cotización del trabajador a la Seguridad
///      Social (6,50 % en 2026, MEI incluido).
///   3. Reducción por rendimientos del trabajo (art. 20), 0 € por encima
///      de 21.000 € de rendimiento.
///   4. Base para el tipo = base − reducción (mínimo 0).
///   5. Cuota = escala(base) − escala(mínimo personal y familiar).
///      - Régimen común: escala de retención del art. 85 RIRPF
///        (19/24/30/37/45/47), común a todas las comunidades.
///      - Régimen foral (País Vasco): escala foral propia.
///   6. Tipo de retención = cuota / bruto. Retención anual = cuota.
///   7. Neto = bruto − retención IRPF − cotización SS.
///
/// Nota: entre comunidades de régimen común la retención mensual es la
/// misma; la diferencia autonómica real se liquida en la declaración de
/// la renta (fuera del alcance de esta estimación).
class TaxCalculator {
  const TaxCalculator();

  // -------------------------------------------------------------------
  // API pública
  // -------------------------------------------------------------------

  /// Calcula el neto a partir del [bruto] anual.
  CalculationResult calcularNeto({
    required double bruto,
    required String ccaa,
    required int pagas,
    required int numHijos,
  }) {
    final brutoSeguro = bruto < 0 ? 0.0 : bruto;
    final comunidad = TaxData2026.comunidadPorId(ccaa);

    final ss = _cotizacionSeguridadSocial(brutoSeguro);
    final irpf = comunidad.esForal
        ? _irpfForal(
            bruto: brutoSeguro,
            ss: ss,
            comunidad: comunidad,
            numHijos: numHijos,
          )
        : _irpfRegimenComun(
            bruto: brutoSeguro,
            ss: ss,
            numHijos: numHijos,
          );

    final netoAnual = brutoSeguro - irpf - ss;
    final pagasSeguras = pagas <= 0 ? 12 : pagas;

    return CalculationResult(
      bruto: brutoSeguro,
      neto: netoAnual,
      irpfTotal: irpf,
      ssEmpleado: ss,
      irpfPorcentaje: brutoSeguro == 0 ? 0 : (irpf / brutoSeguro) * 100,
      netoMensual: netoAnual / pagasSeguras,
      netoAnual: netoAnual,
      descripcionCCAA: comunidad.descripcion,
      pagas: pagasSeguras,
    );
  }

  /// Calcula, mediante BISECCIÓN numérica, el bruto anual necesario para
  /// obtener [netoDeseadoMensual] de neto por paga.
  ///
  /// Tolerancia 0,01 € sobre el neto por paga y máximo 100 iteraciones.
  double calcularBrutoDesdeNeto({
    required double netoDeseadoMensual,
    required String ccaa,
    required int pagas,
    required int numHijos,
  }) {
    if (netoDeseadoMensual <= 0) return 0;

    const tolerancia = AppConstants.toleranciaBiseccion;
    const maxIter = AppConstants.maxIteracionesBiseccion;

    double neto(double bruto) => calcularNeto(
          bruto: bruto,
          ccaa: ccaa,
          pagas: pagas,
          numHijos: numHijos,
        ).netoMensual;

    // Cota inferior: un bruto por paga nunca da más neto que él mismo.
    double bajo = netoDeseadoMensual * (pagas <= 0 ? 12 : pagas);
    // Cota superior: la ampliamos hasta que sobrepase el objetivo.
    double alto = bajo * 2 + 1000;
    int guardas = 0;
    while (neto(alto) < netoDeseadoMensual && guardas < 40) {
      alto *= 1.5;
      guardas++;
    }

    double medio = (bajo + alto) / 2;
    for (int i = 0; i < maxIter; i++) {
      medio = (bajo + alto) / 2;
      final netoMedio = neto(medio);
      if ((netoMedio - netoDeseadoMensual).abs() <= tolerancia) {
        return medio;
      }
      if (netoMedio < netoDeseadoMensual) {
        bajo = medio;
      } else {
        alto = medio;
      }
    }
    return medio;
  }

  /// Compara el salario base con el resultante tras aplicar una subida
  /// bruta de [incremento] euros anuales.
  DeltaResult calcularDelta({
    required double brutoBase,
    required double incremento,
    required String ccaa,
    required int pagas,
    required int numHijos,
  }) {
    final base = calcularNeto(
      bruto: brutoBase,
      ccaa: ccaa,
      pagas: pagas,
      numHijos: numHijos,
    );
    final nuevo = calcularNeto(
      bruto: brutoBase + incremento,
      ccaa: ccaa,
      pagas: pagas,
      numHijos: numHijos,
    );
    return DeltaResult(base: base, nuevo: nuevo, incrementoBruto: incremento);
  }

  // -------------------------------------------------------------------
  // Internos
  // -------------------------------------------------------------------

  /// Aplica una escala progresiva por tramos a [base].
  static double _cuotaPorTramos(double base, List<TramoIRPF> tramos) {
    if (base <= 0) return 0;
    double cuota = 0;
    double limiteAnterior = 0;
    for (final tramo in tramos) {
      if (base > tramo.hasta) {
        cuota += (tramo.hasta - limiteAnterior) * tramo.tipo;
        limiteAnterior = tramo.hasta;
      } else {
        cuota += (base - limiteAnterior) * tramo.tipo;
        return cuota;
      }
    }
    return cuota;
  }

  /// Cotización del trabajador a la Seguridad Social (6,50 % en 2026,
  /// MEI incluido), sobre la base máxima si el bruto la supera.
  double _cotizacionSeguridadSocial(double bruto) {
    // La cotización se calcula sobre la base máxima si el bruto la supera.
    final base = bruto > TaxData2026.baseMaximaCotizacionAnual
        ? TaxData2026.baseMaximaCotizacionAnual
        : bruto;
    return base * TaxData2026.ssEmpleadoTotal;
  }

  /// Base para el tipo de retención: bruto − SS − reducción por trabajo
  /// (art. 20). No se resta el gasto genérico del art. 19.2.f (ver
  /// `TaxData2026.otrosGastosDeducibles`).
  double _baseLiquidable(double bruto, double ss) {
    final rendimientoNeto =
        bruto - ss - TaxData2026.otrosGastosDeducibles;
    final reduccion = TaxData2026.reduccionPorTrabajo(rendimientoNeto);
    final base = rendimientoNeto - reduccion;
    return base < 0 ? 0 : base;
  }

  /// IRPF en régimen común: escala de retención del art. 85 RIRPF
  /// (19/24/30/37/45/47), aplicada a la base y al mínimo personal y
  /// familiar. No varía por comunidad autónoma.
  double _irpfRegimenComun({
    required double bruto,
    required double ss,
    required int numHijos,
  }) {
    final base = _baseLiquidable(bruto, ss);
    final minimo = TaxData2026.minimoPersonalYFamiliar(numHijos);

    final cuota = _cuotaPorTramos(base, TaxData2026.tramosRetencion) -
        _cuotaPorTramos(minimo, TaxData2026.tramosRetencion);

    return cuota < 0 ? 0 : cuota;
  }

  /// IRPF foral (País Vasco), versión simplificada: escala foral única
  /// menos deducción general del trabajo y deducciones por descendientes.
  double _irpfForal({
    required double bruto,
    required double ss,
    required CCAA comunidad,
    required int numHijos,
  }) {
    final rendimientoNeto = bruto - ss;
    final base = rendimientoNeto < 0 ? 0.0 : rendimientoNeto;

    final cuotaIntegra =
        _cuotaPorTramos(base, comunidad.tramosAutonomicos);

    final deducciones = TaxData2026.deduccionForalTrabajo +
        TaxData2026.deduccionForalPorHijos(numHijos);

    final cuota = cuotaIntegra - deducciones;
    return cuota < 0 ? 0 : cuota;
  }
}
