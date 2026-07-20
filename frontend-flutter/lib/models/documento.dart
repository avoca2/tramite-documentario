class Documento {
  final int id;
  final int estudianteId;
  final int tipoDocumentoId;
  final String nombreArchivo;
  final String ruta;
  final String mimeType;
  final int tamano;
  final String? hash;
  final String estado;
  final String? observaciones;
  final String? fechaVerificacion;
  final int? verificadoPor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Documento({
    required this.id,
    required this.estudianteId,
    required this.tipoDocumentoId,
    required this.nombreArchivo,
    required this.ruta,
    required this.mimeType,
    required this.tamano,
    this.hash,
    required this.estado,
    this.observaciones,
    this.fechaVerificacion,
    this.verificadoPor,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json["id"] ?? 0,
      estudianteId: json["estudiante_id"] ?? 0,
      tipoDocumentoId: json["tipo_documento_id"] ?? 0,
      nombreArchivo: json["nombre_archivo"] ?? "",
      ruta: json["ruta"] ?? "",
      mimeType: json["mime_type"] ?? "",
      tamano: json["tamano"] ?? 0,
      hash: json["hash"],
      estado: json["estado"] ?? "pendiente",
      observaciones: json["observaciones"],
      fechaVerificacion: json["fecha_verificacion"],
      verificadoPor: json["verificado_por"],
      createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
      deletedAt: json["deleted_at"] != null ? DateTime.parse(json["deleted_at"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "estudiante_id": estudianteId,
      "tipo_documento_id": tipoDocumentoId,
      "nombre_archivo": nombreArchivo,
      "ruta": ruta,
      "mime_type": mimeType,
      "tamano": tamano,
      "hash": hash,
      "estado": estado,
      "observaciones": observaciones,
      "fecha_verificacion": fechaVerificacion,
      "verificado_por": verificadoPor,
    };
  }
}

class TipoDocumento {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final bool obligatorio;
  final String formatoPermitidos;
  final int tamanoMaximo;
  final bool activo;

  TipoDocumento({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.obligatorio,
    required this.formatoPermitidos,
    required this.tamanoMaximo,
    required this.activo,
  });

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      id: json["id"] ?? 0,
      nombre: json["nombre"] ?? "",
      codigo: json["codigo"] ?? "",
      descripcion: json["descripcion"],
      obligatorio: json["obligatorio"] ?? false,
      formatoPermitidos: json["formato_permitidos"] ?? "pdf,jpg,png",
      tamanoMaximo: json["tamano_maximo"] ?? 5120,
      activo: json["activo"] ?? true,
    );
  }
}
