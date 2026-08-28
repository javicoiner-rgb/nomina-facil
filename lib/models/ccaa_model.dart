/// Un tramo de una escala de IRPF: se aplica [tipo] (en tanto por uno)
/// a la parte de base liquidable comprendida entre el límite del tramo
/// anterior y [hasta].
class TramoIRPF {
  /// Límite superior del tramo en euros. Usa [double.infinity] en el
  /// último tramo.
  final double hasta;

  /// Tipo marginal en tanto por uno (p. ej. 0.19 = 19 %).
  final double tipo;

  const TramoIRPF(this.hasta, this.tipo);
}

/// Modelo de una Comunidad Autónoma con su escala autonómica del IRPF.
///
/// Las comunidades forales (País Vasco y Navarra) tienen un sistema
/// tributario propio: en ellas [esForal] es `true`, no se aplica la
/// escala estatal y [tramosAutonomicos] contiene la escala foral completa.
class CCAA {
  /// Identificador estable usado como clave (no traducible).
  final String id;

  /// Nombre para mostrar en la interfaz.
  final String nombre;

  /// Escala autonómica del IRPF (o escala foral completa si [esForal]).
  final List<TramoIRPF> tramosAutonomicos;

  /// `true` para comunidades de régimen foral.
  final bool esForal;

  /// Texto explicativo corto que se muestra junto al resultado.
  final String descripcion;

  const CCAA({
    required this.id,
    required this.nombre,
    required this.tramosAutonomicos,
    required this.descripcion,
    this.esForal = false,
  });
}
