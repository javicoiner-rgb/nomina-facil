/// Utilidades de formato de números para la interfaz (formato español:
/// punto de millares y coma decimal), sin dependencias externas.
class Formatters {
  Formatters._();

  /// Formatea [valor] como euros. Por defecto sin decimales.
  ///
  /// Ejemplos: `1234.5 -> "1.234 €"`, con `decimales: 2 -> "1.234,50 €"`.
  static String euros(num valor, {int decimales = 0}) {
    return '${_numero(valor, decimales)} €';
  }

  /// Formatea [valor] como porcentaje con [decimales] cifras (por defecto 1).
  static String porcentaje(num valor, {int decimales = 1}) {
    return '${_numero(valor, decimales)} %';
  }

  static String _numero(num valor, int decimales) {
    final negativo = valor < 0;
    final absoluto = valor.abs();
    final texto = absoluto.toStringAsFixed(decimales);

    final partes = texto.split('.');
    final entera = partes[0];
    final decimal = partes.length > 1 ? partes[1] : '';

    final buffer = StringBuffer();
    for (int i = 0; i < entera.length; i++) {
      if (i > 0 && (entera.length - i) % 3 == 0) buffer.write('.');
      buffer.write(entera[i]);
    }

    final signo = negativo ? '-' : '';
    return decimal.isEmpty
        ? '$signo$buffer'
        : '$signo$buffer,$decimal';
  }
}
