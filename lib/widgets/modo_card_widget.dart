import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Tarjeta de un modo en la pantalla de inicio. Sombra moderna, icono
/// grande, título y descripción. Muestra el badge PRO si [esPro].
class ModoCardWidget extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color colorIcono;
  final bool esPro;
  final VoidCallback onTap;

  const ModoCardWidget({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorIcono,
    required this.onTap,
    this.esPro = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: colorIcono, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            titulo,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (esPro) ...[
                          const SizedBox(width: 8),
                          const _BadgePro(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgePro extends StatelessWidget {
  const _BadgePro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.gradientePro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppStrings.badgePro,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
