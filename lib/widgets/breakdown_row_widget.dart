import 'package:flutter/material.dart';

/// Fila de desglose: un punto de color, una etiqueta y un valor a la
/// derecha. Se usa en las tarjetas de resultado para mostrar bruto,
/// IRPF, Seguridad Social y neto.
class BreakdownRowWidget extends StatelessWidget {
  final String etiqueta;
  final String valor;

  /// Color del punto indicador. Si es `null`, no se muestra el punto.
  final Color? color;

  /// Texto secundario opcional bajo la etiqueta (p. ej. "12,5 % del bruto").
  final String? subtitulo;

  /// Resalta la fila (usado para el NETO).
  final bool destacado;

  const BreakdownRowWidget({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.color,
    this.subtitulo,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estiloEtiqueta = destacado
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyLarge;
    final estiloValor = destacado
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          )
        : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (color != null) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: estiloEtiqueta),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(valor, style: estiloValor),
        ],
      ),
    );
  }
}
