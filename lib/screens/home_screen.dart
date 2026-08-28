import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../services/purchase_service.dart';
import '../widgets/modo_card_widget.dart';

/// Pantalla de inicio: título, tres modos y aviso legal.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esPro = context.watch<PurchaseService>().isPro;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.fondoSuave),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              // --- Cabecera ---------------------------------------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientePrimario,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.savings_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  if (esPro)
                    Chip(
                      label: const Text('PRO'),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                      backgroundColor: AppColors.secondary,
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                AppStrings.saludoHome,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.subtituloHome,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // --- Modos -----------------------------------------------
              ModoCardWidget(
                titulo: AppStrings.modoDirectoTitulo,
                descripcion: AppStrings.modoDirectoDesc,
                icono: Icons.tune_rounded,
                colorIcono: AppColors.primary,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppConstants.rutaModoDirecto,
                ),
              ),
              const SizedBox(height: 14),
              ModoCardWidget(
                titulo: AppStrings.modoSorpresaTitulo,
                descripcion: AppStrings.modoSorpresaDesc,
                icono: Icons.auto_awesome_rounded,
                colorIcono: AppColors.ssColor,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppConstants.rutaModoSorpresa,
                ),
              ),
              const SizedBox(height: 14),
              ModoCardWidget(
                titulo: AppStrings.modoInversoTitulo,
                descripcion: AppStrings.modoInversoDesc,
                icono: Icons.handshake_rounded,
                colorIcono: AppColors.secondary,
                esPro: !esPro,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppConstants.rutaModoInverso,
                ),
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.disclaimerHome,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
