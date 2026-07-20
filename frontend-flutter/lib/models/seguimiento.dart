class Seguimiento {
  final int id;
  final int tramiteId;
  final String estadoAnterior;
  final String estadoNuevo;
  final String? comentario;
  final int usuarioId;
  final String? ip;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seguimiento({
    required this.id,
    required this.tramiteId,
    required this.estadoAnterior,
    required this.estadoNuevo,
    this.comentario,
    required this.usuarioId,
    this.ip,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: json["id"] ?? 0,
      tramiteId: json["tramite_id"] ?? 0,
      estadoAnterior: json["estado_anterior"] ?? "",
      estadoNuevo: json["estado_nuevo"] ?? "",
      comentario: json["comentario"],
      usuarioId: json["usuario_id"] ?? 0,
      ip: json["ip"],
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    );
  }
}
