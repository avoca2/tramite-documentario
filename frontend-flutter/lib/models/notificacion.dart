class Notificacion {
  final int id;
  final int usuarioId;
  final String titulo;
  final String contenido;
  final String tipo;
  final String? icono;
  final String? link;
  final bool leida;
  final String? fechaLectura;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    this.icono,
    this.link,
    required this.leida,
    this.fechaLectura,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json["id"] ?? 0,
      usuarioId: json["usuario_id"] ?? 0,
      titulo: json["titulo"] ?? "",
      contenido: json["contenido"] ?? "",
      tipo: json["tipo"] ?? "info",
      icono: json["icono"],
      link: json["link"],
      leida: json["leida"] ?? false,
      fechaLectura: json["fecha_lectura"],
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
    );
  }
}
