import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'screens/home_screen.dart';
import 'screens/modo_directo_screen.dart';
import 'screens/modo_inverso_screen.dart';
import 'screens/modo_sorpresa_screen.dart';
import 'screens/paywall_screen.dart';

/// Raíz de la aplicación: tema Material 3 con color semilla verde menta,
/// tipografía moderna (Google Fonts) y rutas nombradas.
class NominaFacilApp extends StatelessWidget {
  const NominaFacilApp({super.key});

  ThemeData _tema(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      secondary: AppColors.secondary,
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      cardColor: brightness == Brightness.dark
          ? AppColors.cardDark
          : AppColors.cardLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      themeMode: ThemeMode.system,
      initialRoute: AppConstants.rutaHome,
      routes: {
        AppConstants.rutaHome: (_) => const HomeScreen(),
        AppConstants.rutaModoDirecto: (_) => const ModoDirectoScreen(),
        AppConstants.rutaModoSorpresa: (_) => const ModoSorpresaScreen(),
        AppConstants.rutaModoInverso: (_) => const ModoInversoScreen(),
        AppConstants.rutaPaywall: (_) => const PaywallScreen(),
      },
    );
  }
}
