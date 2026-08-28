import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/formatters.dart';
import '../models/calculation_result.dart';
import 'breakdown_row_widget.dart';

/// Tarjeta principal de resultado del Modo Directo: neto al mes en grande
/// sobre gradiente y, debajo, el desglose anual (bruto, IRPF, SS, neto).
class ResultCardWidget extends StatelessWidget {
  final CalculationResult resultado;

  const ResultCardWidget({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // --- Neto al mes, en grande -----------------------------------
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
                AppStrings.tuNetoMensual,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(
                  Formatters.euros(resultado.netoMensual, decimales: 0),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${resultado.pagas} pagas · '
                '${Formatters.euros(resultado.netoAnual)} netos al año',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // --- Desglose anual -------------------------------------------
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
              Text(
                AppStrings.desglose,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              BreakdownRowWidget(
                etiqueta: AppStrings.brutoAnual,
                valor: Formatters.euros(resultado.bruto),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              BreakdownRowWidget(
                etiqueta: AppStrings.irpf,
                subtitulo:
                    '${Formatters.porcentaje(resultado.irpfPorcentaje)} del bruto',
                valor: '− ${Formatters.euros(resultado.irpfTotal)}',
                color: AppColors.irpfColor,
              ),
              BreakdownRowWidget(
                etiqueta: AppStrings.seguridadSocial,
                subtitulo: resultado.bruto > 0
                    ? '${Formatters.porcentaje(resultado.ssEmpleado / resultado.bruto * 100)} del bruto'
                    : null,
                valor: '− ${Formatters.euros(resultado.ssEmpleado)}',
                color: AppColors.ssColor,
              ),
              const Divider(height: 24),
              BreakdownRowWidget(
                etiqueta: AppStrings.netoAnual,
                valor: Formatters.euros(resultado.netoAnual),
                color: AppColors.netoColor,
                destacado: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
