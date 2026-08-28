import 'package:flutter/material.dart';

/// Paleta de color de Nómina Fácil.
///
/// Estilo: vibrante pero profesional, pensado para público joven
/// (Gen Z / Millennials). El color semilla del tema es [primary].
class AppColors {
  AppColors._();

  /// Verde menta principal. Representa el NETO (lo que te llevas a casa).
  static const Color primary = Color(0xFF00C896);

  /// Violeta secundario. Acentos, botones PRO, elementos interactivos.
  static const Color secondary = Color(0xFF6C63FF);

  /// Rojo para el IRPF (lo que se lleva Hacienda).
  static const Color irpfColor = Color(0xFFFF5252);

  /// Naranja para la cotización a la Seguridad Social.
  static const Color ssColor = Color(0xFFFF9800);

  /// Verde para el resultado neto (mismo tono que [primary]).
  static const Color netoColor = Color(0xFF00C896);

  // --- Neutros y superficies ---------------------------------------------

  static const Color scaffoldLight = Color(0xFFF6F8FB);
  static const Color scaffoldDark = Color(0xFF0E1214);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1A2024);

  // --- Gradientes --------------------------------------------------------

  /// Gradiente suave de fondo para la pantalla de inicio.
  static const LinearGradient fondoSuave = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE9FBF4),
      Color(0xFFEEF0FF),
    ],
  );

  /// Gradiente destacado (cabeceras, tarjeta de resultado principal).
  static const LinearGradient gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C896),
      Color(0xFF00A9B5),
    ],
  );

  /// Gradiente para la tarjeta / badge PRO.
  static const LinearGradient gradientePro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF9C4DFF),
    ],
  );
}
