class Convalidacion {
  final int? id;
  final int estudianteId;
  final String estudianteNombre;
  final String dni;
  final String carrera;
  final String tipo;
  final String tipoDisplay;
  final String institucionOrigen;
  final List<String>? unidadesConvalidadas;
  final int totalCreditos;
  final DateTime? fechaSolicitud;
  final String estado;
  final String estadoDisplay;
  final String estadoColor;
  final String? numeroResolucion;
  final DateTime? fechaResolucion;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Convalidacion({
    this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.dni,
    required this.carrera,
    required this.tipo,
    required this.tipoDisplay,
    required this.institucionOrigen,
    this.unidadesConvalidadas,
    required this.totalCreditos,
    this.fechaSolicitud,
    required this.estado,
    required this.estadoDisplay,
    required this.estadoColor,
    this.numeroResolucion,
    this.fechaResolucion,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Convalidacion.fromJson(Map<String, dynamic> json) {
    return Convalidacion(
      id: json['id'],
      estudianteId: json['estudiante_id'] ?? 0,
      estudianteNombre: json['estudiante_nombre'] ?? '',
      dni: json['dni'] ?? '',
      carrera: json['carrera'] ?? '',
      tipo: json['tipo'] ?? 'planes_estudio',
      tipoDisplay: json['tipo_display'] ?? 'Planes de Estudio',
      institucionOrigen: json['institucion_origen'] ?? '',
      unidadesConvalidadas: json['unidades_convalidadas'] != null
          ? List<String>.from(json['unidades_convalidadas'])
          : null,
      totalCreditos: json['total_creditos'] ?? 0,
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.parse(json['fecha_solicitud'])
          : null,
      estado: json['estado'] ?? 'pendiente',
      estadoDisplay: json['estado_display'] ?? 'Pendiente',
      estadoColor: json['estado_color'] ?? 'orange',
      numeroResolucion: json['numero_resolucion'],
      fechaResolucion: json['fecha_resolucion'] != null
          ? DateTime.parse(json['fecha_resolucion'])
          : null,
      observaciones: json['observaciones'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get estadoIcon {
    switch (estado) {
      case 'pendiente':
        return 'hourglass_empty';
      case 'en_proceso':
        return 'pending';
      case 'aprobado':
        return 'check_circle';
      case 'rechazado':
        return 'cancel';
      default:
        return 'help';
    }
  }
}
