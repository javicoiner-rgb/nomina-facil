import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../constants/formatters.dart';
import '../models/calculation_result.dart';
import '../models/tax_calculator.dart';
import '../models/tax_data_2026.dart';
import '../widgets/breakdown_row_widget.dart';
import '../widgets/ccaa_selector_widget.dart';
import '../widgets/opciones_nomina_widget.dart';
import '../widgets/salary_slider_widget.dart';

/// Modo Sorpresa: ¿cuánto ganarías DE VERDAD con una subida? Muestra en
/// grande los euros netos extra al mes y una frase lista para compartir.
class ModoSorpresaScreen extends StatefulWidget {
  const ModoSorpresaScreen({super.key});

  @override
  State<ModoSorpresaScreen> createState() => _ModoSorpresaScreenState();
}

class _ModoSorpresaScreenState extends State<ModoSorpresaScreen> {
  static const _calculadora = TaxCalculator();

  final _brutoController = TextEditingController(text: '30000');
  double _brutoActual = 30000;
  double _incremento = AppConstants.incrementoPorDefecto;
  String _ccaaId = TaxData2026.ccaaPorDefecto;
  int _pagas = AppConstants.pagasPorDefecto;
  int _numHijos = 0;

  @override
  void dispose() {
    _brutoController.dispose();
    super.dispose();
  }

  DeltaResult get _delta => _calculadora.calcularDelta(
        brutoBase: _brutoActual,
        incremento: _incremento,
        ccaa: _ccaaId,
        pagas: _pagas,
        numHijos: _numHijos,
      );

  String _fraseParaCompartir(DeltaResult d) {
    final ccaa = TaxData2026.comunidadPorId(_ccaaId).nombre;
    return 'Me suben ${Formatters.euros(_incremento)} brutos al año en $ccaa. '
        'Después de impuestos me quedan '
        '${Formatters.euros(d.deltaNetoMensual, decimales: 0)} netos más al mes '
        '(me quedo con el ${Formatters.porcentaje(d.porcentajeQueTeQuedas, decimales: 0)} '
        'de cada euro de subida). Calculado con ${AppStrings.appName}.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = _delta;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.modoSorpresaTitulo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              AppStrings.modoSorpresaCabecera,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _brutoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.euro_rounded),
                suffixText: '/ año',
                hintText: '30000',
              ),
              onChanged: (v) => setState(
                () => _brutoActual = double.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(height: 24),
            SalarySliderWidget(
              titulo: AppStrings.incrementoLabel,
              valor: _incremento,
              minimo: AppConstants.incrementoMinimo,
              maximo: AppConstants.incrementoMaximo,
              paso: 250,
              sufijo: 'brutos / año',
              onChanged: (v) => setState(() => _incremento = v),
            ),
            const SizedBox(height: 8),

            // --- Resultado en grande --------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientePrimario,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.ganariasAlMes,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      '+ ${Formatters.euros(d.deltaNetoMensual, decimales: 0)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.masNeto,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BreakdownRowWidget(
                    etiqueta: 'Neto extra al año',
                    valor: '+ ${Formatters.euros(d.deltaNetoAnual)}',
                    color: AppColors.netoColor,
                  ),
                  BreakdownRowWidget(
                    etiqueta: 'Se va en impuestos y SS',
                    valor: '− ${Formatters.euros(d.deltaImpuestosAnual)}',
                    color: AppColors.irpfColor,
                  ),
                  const Divider(height: 24),
                  BreakdownRowWidget(
                    etiqueta: AppStrings.deCadaEuro,
                    valor: Formatters.porcentaje(d.porcentajeQueTeQuedas),
                    color: AppColors.primary,
                    destacado: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Share.share(_fraseParaCompartir(d)),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text(AppStrings.compartir),
            ),

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
