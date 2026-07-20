class Titulacion {
  final int? id;
  final int estudianteId;
  final String estudianteNombre;
  final String dni;
  final String carrera;
  final String modalidad;
  final String modalidadDisplay;
  final DateTime? fechaExamen;
  final double? notaExamen;
  final String estado;
  final String estadoDisplay;
  final String estadoColor;
  final String? numeroResolucion;
  final DateTime? fechaTitulacion;
  final String? numeroTitulo;
  final String? proyectoNombre;
  final String? proyectoDescripcion;
  final DateTime? fechaSolicitud;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Titulacion({
    this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.dni,
    required this.carrera,
    required this.modalidad,
    required this.modalidadDisplay,
    this.fechaExamen,
    this.notaExamen,
    required this.estado,
    required this.estadoDisplay,
    required this.estadoColor,
    this.numeroResolucion,
    this.fechaTitulacion,
    this.numeroTitulo,
    this.proyectoNombre,
    this.proyectoDescripcion,
    this.fechaSolicitud,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Titulacion.fromJson(Map<String, dynamic> json) {
    return Titulacion(
      id: json['id'],
      estudianteId: json['estudiante_id'] ?? 0,
      estudianteNombre: json['estudiante_nombre'] ?? '',
      dni: json['dni'] ?? '',
      carrera: json['carrera'] ?? '',
      modalidad: json['modalidad'] ?? 'innovacion_tecnologica',
      modalidadDisplay: json['modalidad_display'] ?? 'Innovación Tecnológica',
      fechaExamen: json['fecha_examen'] != null
          ? DateTime.tryParse(json['fecha_examen'])
          : null,
      notaExamen: json['nota_examen'] != null
          ? double.tryParse(json['nota_examen'].toString())
          : null,
      estado: json['estado'] ?? 'en_proceso',
      estadoDisplay: json['estado_display'] ?? 'En Proceso',
      estadoColor: json['estado_color'] ?? 'orange',
      numeroResolucion: json['numero_resolucion'],
      fechaTitulacion: json['fecha_titulacion'] != null
          ? DateTime.tryParse(json['fecha_titulacion'])
          : null,
      numeroTitulo: json['numero_titulo'],
      proyectoNombre: json['proyecto_nombre'],
      proyectoDescripcion: json['proyecto_descripcion'],
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud'])
          : null,
      observaciones: json['observaciones'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get estadoIcon {
    switch (estado) {
      case 'en_proceso':
        return 'pending';
      case 'aprobado':
        return 'check_circle';
      case 'desaprobado':
        return 'cancel';
      case 'titulado':
        return 'verified';
      case 'reprogramado':
        return 'update';
      default:
        return 'help';
    }
  }

  String get modalidadIcon {
    switch (modalidad) {
      case 'innovacion_tecnologica':
        return 'science';
      case 'suficiencia_profesional':
        return 'assignment';
      default:
        return 'help';
    }
  }
}
