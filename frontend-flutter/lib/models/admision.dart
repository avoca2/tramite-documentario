class Admision {
  final int? id;
  final int estudianteId;
  final String estudianteNombre;
  final String dni;
  final String modalidad;
  final double? notaFinal;
  final String estado;
  final String? lugarProcedencia;
  final String? colegioProcedencia;
  final String? observaciones;
  final DateTime? fechaInscripcion;
  final DateTime? fechaEvaluacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admision({
    this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.dni,
    required this.modalidad,
    this.notaFinal,
    required this.estado,
    this.lugarProcedencia,
    this.colegioProcedencia,
    this.observaciones,
    this.fechaInscripcion,
    this.fechaEvaluacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Admision.fromJson(Map<String, dynamic> json) {
    return Admision(
      id: json['id'],
      estudianteId: json['estudiante_id'] ?? 0,
      estudianteNombre: json['estudiante_nombre'] ?? '',
      dni: json['dni'] ?? '',
      modalidad: json['modalidad'] ?? 'ordinaria',
      notaFinal: json['nota_final'] != null 
          ? double.tryParse(json['nota_final'].toString()) 
          : null,
      estado: json['estado'] ?? 'inscrito',
      lugarProcedencia: json['lugar_procedencia'],
      colegioProcedencia: json['colegio_procedencia'],
      observaciones: json['observaciones'],
      fechaInscripcion: json['fecha_inscripcion'] != null 
          ? DateTime.parse(json['fecha_inscripcion']) 
          : null,
      fechaEvaluacion: json['fecha_evaluacion'] != null 
          ? DateTime.parse(json['fecha_evaluacion']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get modalidadDisplay {
    final modalidades = {
      'ordinaria': 'Ordinaria',
      'exoneracion': 'Exoneración',
    };
    return modalidades[modalidad] ?? modalidad;
  }

  String get estadoDisplay {
    final estados = {
      'inscrito': 'Inscrito',
      'evaluado': 'Evaluado',
      'ingresante': 'Ingresante',
      'no_ingresante': 'No Ingresante',
    };
    return estados[estado] ?? estado;
  }

  String get estadoColor {
    switch (estado) {
      case 'inscrito': return 'orange';
      case 'evaluado': return 'blue';
      case 'ingresante': return 'green';
      case 'no_ingresante': return 'red';
      default: return 'grey';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'estudiante_id': estudianteId,
      'modalidad': modalidad,
      'nota_final': notaFinal,
      'estado': estado,
      'lugar_procedencia': lugarProcedencia,
      'colegio_procedencia': colegioProcedencia,
      'observaciones': observaciones,
      'fecha_inscripcion': fechaInscripcion?.toIso8601String(),
      'fecha_evaluacion': fechaEvaluacion?.toIso8601String(),
    };
  }
}