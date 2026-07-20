class Nota {
  final int id;
  final int estudianteId;
  final int cursoId;
  final int periodoAcademicoId;
  final double? notaParcial1;
  final double? notaParcial2;
  final double? notaExamen;
  final double? notaFinal;
  final String? estado;
  final String? tipo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Nota({
    required this.id,
    required this.estudianteId,
    required this.cursoId,
    required this.periodoAcademicoId,
    this.notaParcial1,
    this.notaParcial2,
    this.notaExamen,
    this.notaFinal,
    this.estado,
    this.tipo,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json["id"] ?? 0,
      estudianteId: json["estudiante_id"] ?? 0,
      cursoId: json["curso_id"] ?? 0,
      periodoAcademicoId: json["periodo_academico_id"] ?? 0,
      notaParcial1: json["nota_parcial_1"] != null ? double.parse(json["nota_parcial_1"].toString()) : null,
      notaParcial2: json["nota_parcial_2"] != null ? double.parse(json["nota_parcial_2"].toString()) : null,
      notaExamen: json["nota_examen"] != null ? double.parse(json["nota_examen"].toString()) : null,
      notaFinal: json["nota_final"] != null ? double.parse(json["nota_final"].toString()) : null,
      estado: json["estado"],
      tipo: json["tipo"] ?? "regular",
      observaciones: json["observaciones"],
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    );
  }
}
