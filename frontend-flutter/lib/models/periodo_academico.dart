class PeriodoAcademico {
  final int id;
  final String nombre;
  final String codigo;
  final String fechaInicio;
  final String fechaFin;
  final String? fechaLimiteInscripcion;
  final String? fechaLimitePago;
  final bool activo;
  final bool actual;
  final DateTime createdAt;
  final DateTime updatedAt;

  PeriodoAcademico({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.fechaInicio,
    required this.fechaFin,
    this.fechaLimiteInscripcion,
    this.fechaLimitePago,
    required this.activo,
    required this.actual,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeriodoAcademico.fromJson(Map<String, dynamic> json) {
    return PeriodoAcademico(
      id: json["id"] ?? 0,
      nombre: json["nombre"] ?? "",
      codigo: json["codigo"] ?? "",
      fechaInicio: json["fecha_inicio"] ?? "",
      fechaFin: json["fecha_fin"] ?? "",
      fechaLimiteInscripcion: json["fecha_limite_inscripcion"],
      fechaLimitePago: json["fecha_limite_pago"],
      activo: json["activo"] ?? false,
      actual: json["actual"] ?? false,
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    );
  }
}
