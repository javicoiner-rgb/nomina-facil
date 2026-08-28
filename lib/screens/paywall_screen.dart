import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/purchase_service.dart';

/// Pantalla de venta de la suscripción PRO. Solo bloquea el Modo
/// Negociación (modo inverso); los modos Directo y Sorpresa son gratis.
///
/// Se puede usar como ruta (`/paywall`) o incrustada dentro de otra
/// pantalla mediante [incrustado] (sin Scaffold propio).
class PaywallScreen extends StatelessWidget {
  final bool incrustado;

  const PaywallScreen({super.key, this.incrustado = false});

  Future<void> _comprar(BuildContext context) async {
    final service = context.read<PurchaseService>();
    if (service.paquetePro == null) {
      _aviso(context, AppStrings.paywallSinOfertas);
      return;
    }
    final ok = await service.comprarPro();
    if (!context.mounted) return;
    if (ok) {
      if (!incrustado) Navigator.of(context).maybePop(true);
    } else {
      _aviso(context, AppStrings.paywallError);
    }
  }

  Future<void> _restaurar(BuildContext context) async {
    final ok = await context.read<PurchaseService>().restaurar();
    if (!context.mounted) return;
    _aviso(
      context,
      ok ? 'Compra restaurada. ¡Bienvenido a PRO!' : AppStrings.paywallError,
    );
  }

  void _aviso(BuildContext context, String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<PurchaseService>();
    final precio = service.precioPro;

    final contenido = ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      shrinkWrap: incrustado,
      physics: incrustado ? const NeverScrollableScrollPhysics() : null,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientePro,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.handshake_rounded,
                  color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                AppStrings.paywallTitulo,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.paywallSubtitulo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (final ventaja in AppStrings.paywallVentajas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ventaja, style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: service.cargando ? null : () => _comprar(context),
          child: service.cargando
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  precio == null
                      ? AppStrings.paywallComprar
                      : '${AppStrings.paywallComprar} · $precio',
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: service.cargando ? null : () => _restaurar(context),
          child: const Text(AppStrings.paywallRestaurar),
        ),
        if (!incrustado)
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(false),
            child: const Text(AppStrings.paywallCerrar),
          ),
      ],
    );

    if (incrustado) return contenido;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.badgePro)),
      body: SafeArea(child: contenido),
    );
  }
}
