/// Constantes de configuración de la app (rangos de sliders, rutas, límites).
class AppConstants {
  AppConstants._();

  // --- Identidad --------------------------------------------------------

  static const String appName = 'Nómina Fácil';
  static const String version = '1.0.0';

  /// Año fiscal de los datos cargados. Se actualiza cada enero.
  static const int anioFiscal = 2026;

  // --- Rangos del modo directo ----------------------------------------

  /// Bruto anual mínimo del slider (aprox. SMI 2026 en 14 pagas).
  static const double brutoMinimo = 14000;

  /// Bruto anual máximo del slider.
  static const double brutoMaximo = 120000;

  static const double brutoPorDefecto = 30000;

  // --- Rangos del modo sorpresa (incremento salarial) ----------------

  static const double incrementoMinimo = 500;
  static const double incrementoMaximo = 15000;
  static const double incrementoPorDefecto = 3000;

  // --- Opciones de pagas --------------------------------------------------

  static const List<int> opcionesPagas = [12, 14];
  static const int pagasPorDefecto = 14;

  // --- Hijos -----------------------------------------------------------

  /// Índice máximo del selector de hijos: 0, 1, 2, 3+ (se trata como 3).
  static const int maxHijos = 3;

  // --- Cálculo inverso (bisección) --------------------------------------

  static const double toleranciaBiseccion = 0.01;
  static const int maxIteracionesBiseccion = 100;

  // --- RevenueCat -----------------------------------------------------

  /// Identificador del "entitlement" PRO en RevenueCat.
  static const String entitlementPro = 'pro';

  /// Clave pública de API de RevenueCat (rellenar en despliegue real).
  static const String revenueCatApiKeyAndroid = 'goog_TU_CLAVE_AQUI';
  static const String revenueCatApiKeyIos = 'appl_TU_CLAVE_AQUI';

  // --- Rutas nombradas ------------------------------------------------

  static const String rutaHome = '/';
  static const String rutaModoDirecto = '/modo-directo';
  static const String rutaModoSorpresa = '/modo-sorpresa';
  static const String rutaModoInverso = '/modo-inverso';
  static const String rutaPaywall = '/paywall';
}
