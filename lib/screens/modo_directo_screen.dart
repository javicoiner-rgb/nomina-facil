import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../models/tax_calculator.dart';
import '../models/tax_data_2026.dart';
import '../widgets/ccaa_selector_widget.dart';
import '../widgets/opciones_nomina_widget.dart';
import '../widgets/result_card_widget.dart';
import '../widgets/salary_slider_widget.dart';

/// Modo Directo: mueve el slider de bruto anual y mira tu neto al
/// instante. No hay botón "calcular": el resultado se recalcula en
/// tiempo real con cada cambio.
class ModoDirectoScreen extends StatefulWidget {
  const ModoDirectoScreen({super.key});

  @override
  State<ModoDirectoScreen> createState() => _ModoDirectoScreenState();
}

class _ModoDirectoScreenState extends State<ModoDirectoScreen> {
  static const _calculadora = TaxCalculator();

  double _bruto = AppConstants.brutoPorDefecto;
  String _ccaaId = TaxData2026.ccaaPorDefecto;
  int _pagas = AppConstants.pagasPorDefecto;
  int _numHijos = 0;

  @override
  Widget build(BuildContext context) {
    final resultado = _calculadora.calcularNeto(
      bruto: _bruto,
      ccaa: _ccaaId,
      pagas: _pagas,
      numHijos: _numHijos,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.modoDirectoTitulo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SalarySliderWidget(
              titulo: AppStrings.modoDirectoCabecera,
              valor: _bruto,
              minimo: AppConstants.brutoMinimo,
              maximo: AppConstants.brutoMaximo,
              paso: 500,
              onChanged: (v) => setState(() => _bruto = v),
            ),
            const SizedBox(height: 20),
            ResultCardWidget(resultado: resultado),
            const SizedBox(height: 24),
            CcaaSelectorWidget(
              ccaaId: _ccaaId,
              onChanged: (v) => setState(() => _ccaaId = v),
            ),
            CcaaNotaRetencionWidget(ccaaId: _ccaaId),
            const SizedBox(height: 20),
            SelectorPagasWidget(
              pagas: _pagas,
              onChanged: (v) => setState(() => _pagas = v),
            ),
            const SizedBox(height: 20),
            SelectorHijosWidget(
              numHijos: _numHijos,
              onChanged: (v) => setState(() => _numHijos = v),
            ),
          ],
        ),
      ),
    );
  }
}
