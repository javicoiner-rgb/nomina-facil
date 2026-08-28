import 'package:flutter/material.dart';

import '../constants/formatters.dart';

/// Slider de salario con etiqueta, valor grande formateado y límites.
///
/// Notifica cada cambio en [onChanged] para permitir cálculo en tiempo
/// real sin botón "calcular".
class SalarySliderWidget extends StatelessWidget {
  final String titulo;
  final double valor;
  final double minimo;
  final double maximo;

  /// Paso del slider en euros.
  final double paso;

  final ValueChanged<double> onChanged;

  /// Sufijo del valor mostrado (por defecto "/ año").
  final String sufijo;

  const SalarySliderWidget({
    super.key,
    required this.titulo,
    required this.valor,
    required this.minimo,
    required this.maximo,
    required this.onChanged,
    this.paso = 500,
    this.sufijo = '/ año',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisiones = ((maximo - minimo) / paso).round().clamp(1, 100000);
    final valorAcotado = valor.clamp(minimo, maximo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Formatters.euros(valorAcotado),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              sufijo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: valorAcotado,
            min: minimo,
            max: maximo,
            divisions: divisiones,
            label: Formatters.euros(valorAcotado),
            onChanged: (v) => onChanged(v.roundToDouble()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Formatters.euros(minimo),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              Formatters.euros(maximo),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
