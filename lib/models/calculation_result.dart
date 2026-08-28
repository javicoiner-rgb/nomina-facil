/// Resultado de un cálculo de nómina (bruto → neto).
class CalculationResult {
  /// Bruto anual introducido.
  final double bruto;

  /// Neto anual resultante (= [netoAnual]).
  final double neto;

  /// Retención total de IRPF en el año, en euros.
  final double irpfTotal;

  /// Cotización anual del trabajador a la Seguridad Social, en euros.
  final double ssEmpleado;

  /// Tipo efectivo de retención de IRPF, en porcentaje (0-100).
  final double irpfPorcentaje;

  /// Neto por paga (neto anual dividido entre el número de pagas).
  final double netoMensual;

  /// Neto anual (idéntico a [neto], expuesto por claridad).
  final double netoAnual;

  /// Descripción de la escala autonómica aplicada.
  final String descripcionCCAA;

  /// Número de pagas usado en el cálculo (12 o 14).
  final int pagas;

  /// Cotización mensual a la Seguridad Social (siempre en 12 mensualidades).
  double get ssMensual => ssEmpleado / 12;

  /// Bruto por paga.
  double get brutoMensual => bruto / pagas;

  /// Tipo efectivo total (IRPF + SS) sobre el bruto, en porcentaje.
  double get tipoTotalPorcentaje =>
      bruto == 0 ? 0 : ((irpfTotal + ssEmpleado) / bruto) * 100;

  const CalculationResult({
    required this.bruto,
    required this.neto,
    required this.irpfTotal,
    required this.ssEmpleado,
    required this.irpfPorcentaje,
    required this.netoMensual,
    required this.netoAnual,
    required this.descripcionCCAA,
    required this.pagas,
  });
}

/// Resultado de comparar un salario base con el mismo salario tras una
/// subida bruta (modo sorpresa / negociación).
class DeltaResult {
  /// Cálculo del salario antes de la subida.
  final CalculationResult base;

  /// Cálculo del salario después de la subida.
  final CalculationResult nuevo;

  /// Incremento bruto anual aplicado.
  final double incrementoBruto;

  const DeltaResult({
    required this.base,
    required this.nuevo,
    required this.incrementoBruto,
  });

  /// Cuánto neto adicional al año.
  double get deltaNetoAnual => nuevo.netoAnual - base.netoAnual;

  /// Cuánto neto adicional al mes (repartido en 12 mensualidades).
  double get deltaNetoMensual => deltaNetoAnual / 12;

  /// Cuánto neto adicional por paga (según el número de pagas elegido).
  double get deltaNetoPorPaga => nuevo.netoMensual - base.netoMensual;

  /// Impuestos + cotización adicionales al año por la subida.
  double get deltaImpuestosAnual =>
      (nuevo.irpfTotal + nuevo.ssEmpleado) - (base.irpfTotal + base.ssEmpleado);

  /// Porcentaje de cada euro bruto de subida que acaba en tu bolsillo.
  double get porcentajeQueTeQuedas =>
      incrementoBruto == 0 ? 0 : (deltaNetoAnual / incrementoBruto) * 100;

  /// Porcentaje de cada euro bruto de subida que se va en impuestos.
  double get porcentajeQuePierdes => 100 - porcentajeQueTeQuedas;
}
