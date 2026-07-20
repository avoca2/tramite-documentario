class Tramite {
  final int? id;
  final String codigo;
  final String estudianteId;
  final String tipo;
  final String estado;
  final String? descripcion;
  final String? numeroResolucion;
  final DateTime fechaSolicitud;
  final DateTime? fechaResolucion;
  final List<String>? documentos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tramite({
    this.id,
    required this.codigo,
    required this.estudianteId,
    required this.tipo,
    required this.estado,
    this.descripcion,
    this.numeroResolucion,
    required this.fechaSolicitud,
    this.fechaResolucion,
    this.documentos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tramite.fromJson(Map<String, dynamic> json) {
    return Tramite(
      id: json['id'],
      codigo: json['codigo_tramite'] ?? '',
      estudianteId: json['estudiante_id']?.toString() ?? '',
      tipo: json['tipo'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      descripcion: json['descripcion'],
      numeroResolucion: json['numero_resolucion'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud'] ?? DateTime.now().toIso8601String()),
      fechaResolucion: json['fecha_resolucion'] != null 
          ? DateTime.parse(json['fecha_resolucion']) 
          : null,
      documentos: json['documentos'] != null ? List<String>.from(json['documentos']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo_tramite': codigo,
      'estudiante_id': estudianteId,
      'tipo': tipo,
      'estado': estado,
      'descripcion': descripcion,
      'numero_resolucion': numeroResolucion,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
    };
  }

  String get tipoDisplay {
    final tipos = {
      'admision': 'Admisión',
      'matricula': 'Matrícula',
      'convalidacion': 'Convalidación',
      'traslado_interno': 'Traslado Interno',
      'traslado_externo': 'Traslado Externo',
      'certificacion': 'Certificación',
      'titulacion': 'Titulación',
      'evaluacion': 'Evaluación',
    };
    return tipos[tipo] ?? tipo;
  }

  String get estadoDisplay {
    final estados = {
      'pendiente': 'Pendiente',
      'en_proceso': 'En Proceso',
      'completado': 'Completado',
      'rechazado': 'Rechazado',
    };
    return estados[estado] ?? estado;
  }

  Color get estadoColor {
    final colores = {
      'pendiente': Colors.orange,
      'en_proceso': Colors.blue,
      'completado': Colors.green,
      'rechazado': Colors.red,
    };
    return colores[estado] ?? Colors.grey;
  }
}