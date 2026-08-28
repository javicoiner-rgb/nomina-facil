/// Todos los textos de la interfaz, centralizados y en español.
class AppStrings {
  AppStrings._();

  // --- Generales -----------------------------------------------------

  static const String appName = 'Nómina Fácil';
  static const String tagline = 'Tu sueldo real, sin sorpresas';

  static const String brutoAnual = 'Bruto anual';
  static const String brutoMensual = 'Bruto mensual';
  static const String netoAnual = 'Neto anual';
  static const String netoMensual = 'Neto al mes';
  static const String irpf = 'IRPF';
  static const String seguridadSocial = 'Seguridad Social';
  static const String comunidadAutonoma = 'Comunidad Autónoma';
  static const String notaRetencionComun =
      'La retención mensual es igual en todas las comunidades de régimen '
      'común. Las diferencias autonómicas se ajustan en tu declaración de '
      'junio.';
  static const String numeroPagas = 'Número de pagas';
  static const String hijos = 'Hijos a cargo';
  static const String pagas12 = '12 pagas';
  static const String pagas14 = '14 pagas';

  // --- Home ----------------------------------------------------------

  static const String saludoHome = '¿Cuánto cobras de verdad?';
  static const String subtituloHome =
      'Calcula tu nómina neta en segundos. Sin registros, sin rollos.';

  static const String modoDirectoTitulo = 'Modo Directo';
  static const String modoDirectoDesc =
      'Mueve el slider y mira tu neto al instante.';

  static const String modoSorpresaTitulo = 'Modo Sorpresa';
  static const String modoSorpresaDesc =
      '¿Cuánto ganarías de verdad con una subida?';

  static const String modoInversoTitulo = 'Modo Negociación';
  static const String modoInversoDesc =
      'Di el neto que quieres y te decimos el bruto que pedir.';

  static const String badgePro = 'PRO';
  static const String disclaimerHome =
      'Cálculo orientativo basado en la normativa estatal y autonómica '
      '$_anio. No sustituye a tu nómina oficial ni a tu asesor fiscal.';

  static const String _anio = '2026';

  // --- Modo directo -----------------------------------------------

  static const String modoDirectoCabecera = 'Ajusta tu bruto anual';
  static const String tuNetoMensual = 'Tu neto al mes';
  static const String desglose = 'Desglose anual';

  // --- Modo sorpresa ---------------------------------------------

  static const String modoSorpresaCabecera = 'Tu bruto actual';
  static const String incrementoLabel = 'Subida bruta que te ofrecen';
  static const String ganariasAlMes = 'Ganarías al mes';
  static const String masNeto = 'más de neto';
  static const String deCadaEuro = 'De cada euro de subida, te quedas';
  static const String compartir = 'Compartir';

  // --- Modo inverso --------------------------------------------

  static const String modoInversoCabecera = 'Neto que quieres cobrar al mes';
  static const String debesPedir = 'Debes pedir un bruto anual de';
  static const String equivaleBrutoMes = 'Equivale a un bruto mensual de';
  static const String copiar = 'Copiar frase';
  static const String copiado = 'Frase copiada al portapapeles';

  // --- Paywall -------------------------------------------------

  static const String paywallTitulo = 'Desbloquea el Modo Negociación';
  static const String paywallSubtitulo =
      'Calcula el bruto exacto que pedir para el neto que quieres. '
      'Ideal para tu próxima revisión salarial o cambio de curro.';
  static const List<String> paywallVentajas = [
    'Cálculo inverso neto → bruto',
    'Frases listas para tu email de negociación',
    'Sin anuncios, para siempre',
    'Futuras funciones PRO incluidas',
  ];
  static const String paywallComprar = 'Hazte PRO';
  static const String paywallRestaurar = 'Restaurar compra';
  static const String paywallCerrar = 'Ahora no';
  static const String paywallError =
      'No se ha podido completar la compra. Inténtalo de nuevo.';
  static const String paywallSinOfertas =
      'No hay ofertas disponibles ahora mismo.';

  // --- Errores / validación ------------------------------------

  static const String introduceBruto = 'Introduce tu bruto anual';
  static const String introduceNeto = 'Introduce el neto mensual deseado';
  static const String valorNoValido = 'Valor no válido';
}
