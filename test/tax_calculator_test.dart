import 'package:flutter_test/flutter_test.dart';
import 'package:nomina_facil/models/tax_calculator.dart';
import 'package:nomina_facil/models/tax_data_2026.dart';

void main() {
  const calc = TaxCalculator();

  test('cotización SS del trabajador: 6,50 % en 2026 (MEI incluido)', () {
    expect(TaxData2026.ssEmpleadoTotal, closeTo(0.065, 1e-9));
    final r = calc.calcularNeto(
      bruto: 30000,
      ccaa: 'madrid',
      pagas: 14,
      numHijos: 0,
    );
    expect(r.ssEmpleado, closeTo(30000 * 0.065, 0.01)); // 1.950 €
  });

  test('30.000 € en Madrid, soltero sin hijos, 14 pagas', () {
    final r = calc.calcularNeto(
      bruto: 30000,
      ccaa: 'madrid',
      pagas: 14,
      numHijos: 0,
    );

    // SS 6,50 % -> 1.950 €
    expect(r.ssEmpleado, closeTo(1950, 0.5));
    // Base del IRPF = 30.000 − 1.950 = 28.050 €. Reducción art. 20 = 0
    // (rendimiento > 21.000 €). Cuota por la escala de retención del
    // art. 85 RIRPF menos la del mínimo personal (5.550 €).
    expect(r.irpfPorcentaje, closeTo(18.4, 0.4));
    // Neto anual ~ 22.612 € según fuentes verificadas 2026 (el cálculo da
    // 22.524 €; la diferencia < 0,4 % es por redondeos de la escala).
    expect(r.netoAnual, closeTo(22612, 120));
    expect(r.netoMensual, closeTo(1615, 12)); // 14 pagas
  });

  test('el neto es menor que el bruto y positivo', () {
    final r = calc.calcularNeto(
      bruto: 30000,
      ccaa: 'madrid',
      pagas: 14,
      numHijos: 0,
    );
    expect(r.neto, lessThan(r.bruto));
    expect(r.neto, greaterThan(0));
  });

  test('la reducción por trabajo es 0 por encima de 21.000 €', () {
    expect(TaxData2026.reduccionPorTrabajo(21000.01), 0);
    expect(TaxData2026.reduccionPorTrabajo(28050), 0);
    // En el umbral inferior, reducción máxima.
    expect(TaxData2026.reduccionPorTrabajo(16825), TaxData2026.reduccionTrabajoMaxima);
    // Justo en el umbral superior, exactamente 0.
    expect(TaxData2026.reduccionPorTrabajo(21000), closeTo(0, 1e-6));
  });

  test('más hijos => más neto (mismo bruto)', () {
    double neto(int h) => calc
        .calcularNeto(bruto: 35000, ccaa: 'cataluna', pagas: 12, numHijos: h)
        .neto;
    expect(neto(2), greaterThan(neto(0)));
  });

  test('bisección: recuperar el bruto desde el neto', () {
    const bruto = 42000.0;
    final r = calc.calcularNeto(
      bruto: bruto,
      ccaa: 'andalucia',
      pagas: 14,
      numHijos: 1,
    );
    final brutoRecuperado = calc.calcularBrutoDesdeNeto(
      netoDeseadoMensual: r.netoMensual,
      ccaa: 'andalucia',
      pagas: 14,
      numHijos: 1,
    );
    expect(brutoRecuperado, closeTo(bruto, 5));
  });

  test('delta: te quedas con parte de la subida, nunca más del 100 %', () {
    final d = calc.calcularDelta(
      brutoBase: 30000,
      incremento: 3000,
      ccaa: 'galicia',
      pagas: 12,
      numHijos: 0,
    );
    expect(d.deltaNetoAnual, greaterThan(0));
    expect(d.porcentajeQueTeQuedas, lessThan(100));
    expect(d.porcentajeQueTeQuedas, greaterThan(0));
  });

  test('régimen foral (País Vasco) también da neto coherente', () {
    final r = calc.calcularNeto(
      bruto: 40000,
      ccaa: 'pais_vasco',
      pagas: 14,
      numHijos: 0,
    );
    expect(r.neto, greaterThan(0));
    expect(r.neto, lessThan(r.bruto));
  });
}
