import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../constants/formatters.dart';
import '../models/tax_calculator.dart';
import '../models/tax_data_2026.dart';
import '../services/purchase_service.dart';
import '../widgets/breakdown_row_widget.dart';
import '../widgets/ccaa_selector_widget.dart';
import '../widgets/opciones_nomina_widget.dart';
import 'paywall_screen.dart';

/// Modo Negociación (inverso): dime el neto que quieres cobrar al mes y
/// te digo el bruto anual que pedir. Función PRO: si el usuario no es
/// PRO, se muestra el paywall incrustado.
class ModoInversoScreen extends StatefulWidget {
  const ModoInversoScreen({super.key});

  @override
  State<ModoInversoScreen> createState() => _ModoInversoScreenState();
}

class _ModoInversoScreenState extends State<ModoInversoScreen> {
  static const _calculadora = TaxCalculator();

  final _netoController = TextEditingController(text: '1800');
  double _netoDeseado = 1800;
  String _ccaaId = TaxData2026.ccaaPorDefecto;
  int _pagas = AppConstants.pagasPorDefecto;
  int _numHijos = 0;

  @override
  void dispose() {
    _netoController.dispose();
    super.dispose();
  }

  double get _brutoNecesario => _calculadora.calcularBrutoDesdeNeto(
        netoDeseadoMensual: _netoDeseado,
        ccaa: _ccaaId,
        pagas: _pagas,
        numHijos: _numHijos,
      );

  String _frase(double brutoAnual) {
    final ccaa = TaxData2026.comunidadPorId(_ccaaId).nombre;
    return 'Para cobrar ${Formatters.euros(_netoDeseado)} netos al mes en '
        '$ccaa debo pedir ${Formatters.euros(brutoAnual)} brutos al año '
        '($_pagas pagas).';
  }

  @override
  Widget build(BuildContext context) {
    final esPro = context.watch<PurchaseService>().isPro;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.modoInversoTitulo)),
      body: SafeArea(
        child: esPro ? _contenido(context) : const PaywallScreen(incrustado: true),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    final theme = Theme.of(context);
    final brutoAnual = _brutoNecesario;
    final brutoMensual = brutoAnual / _pagas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          AppStrings.modoInversoCabecera,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _netoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.euro_rounded),
            suffixText: '/ mes',
            hintText: '1800',
          ),
          onChanged: (v) => setState(
            () => _netoDeseado = double.tryParse(v) ?? 0,
          ),
        ),
        const SizedBox(height: 20),

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
                AppStrings.debesPedir,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(
                  Formatters.euros(brutoAnual),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppStrings.equivaleBrutoMes} '
                '${Formatters.euros(brutoMensual)}',
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
                etiqueta: AppStrings.brutoAnual,
                valor: Formatters.euros(brutoAnual),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              BreakdownRowWidget(
                etiqueta: AppStrings.brutoMensual,
                subtitulo: '$_pagas pagas',
                valor: Formatters.euros(brutoMensual),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const Divider(height: 24),
              BreakdownRowWidget(
                etiqueta: AppStrings.netoMensual,
                valor: Formatters.euros(_netoDeseado),
                color: AppColors.netoColor,
                destacado: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- Frase lista para copiar ---------------------------------
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _frase(brutoAnual),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: _frase(brutoAnual)),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text(AppStrings.copiado)),
              );
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text(AppStrings.copiar),
        ),

        const SizedBox(height: 24),
        CcaaSelectorWidget(
          ccaaId: _ccaaId,
          onChanged: (v) => setState(() => _ccaaId = v),
        ),
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
    );
  }
}
