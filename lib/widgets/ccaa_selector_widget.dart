import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/tax_data_2026.dart';

/// Selector de Comunidad Autónoma mediante un desplegable.
class CcaaSelectorWidget extends StatelessWidget {
  /// Id de la comunidad seleccionada.
  final String ccaaId;
  final ValueChanged<String> onChanged;

  const CcaaSelectorWidget({
    super.key,
    required this.ccaaId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.comunidadAutonoma,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: ccaaId,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final c in TaxData2026.comunidades)
              DropdownMenuItem(
                value: c.id,
                child: Text(c.nombre + (c.esForal ? '  ·  foral' : '')),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// Nota informativa discreta que se muestra bajo el selector de CCAA en
/// los modos Directo y Sorpresa: recuerda que la retención mensual no
/// varía entre comunidades de régimen común.
///
/// Se oculta (con transición) cuando la comunidad seleccionada es de
/// régimen foral (País Vasco), donde el resultado sí cambia.
class CcaaNotaRetencionWidget extends StatelessWidget {
  final String ccaaId;

  const CcaaNotaRetencionWidget({super.key, required this.ccaaId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esForal = TaxData2026.comunidadPorId(ccaaId).esForal;

    return AnimatedOpacity(
      opacity: esForal ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                AppStrings.notaRetencionComun,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
