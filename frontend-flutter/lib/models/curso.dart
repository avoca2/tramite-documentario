class Curso {
  final int id;
  final int carreraId;
  final String codigo;
  final String nombre;
  final int creditos;
  final int horasTeoria;
  final int horasPractica;
  final int ciclo;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Curso({
    required this.id,
    required this.carreraId,
    required this.codigo,
    required this.nombre,
    required this.creditos,
    required this.horasTeoria,
    required this.horasPractica,
    required this.ciclo,
    this.descripcion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json["id"] ?? 0,
      carreraId: json["carrera_id"] ?? 0,
      codigo: json["codigo"] ?? "",
      nombre: json["nombre"] ?? "",
      creditos: json["creditos"] ?? 0,
      horasTeoria: json["horas_teoria"] ?? 0,
      horasPractica: json["horas_practica"] ?? 0,
      ciclo: json["ciclo"] ?? 1,
      descripcion: json["descripcion"],
      activo: json["activo"] ?? true,
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    );
  }
}
