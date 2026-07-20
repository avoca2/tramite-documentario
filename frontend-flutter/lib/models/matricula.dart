class Matricula {
  final int? id;
  final int estudianteId;
  final String estudianteNombre;
  final String dni;
  final String carrera;
  final String periodoAcademico;
  final String tipo;
  final String tipoDisplay;
  final String estado;
  final String estadoDisplay;
  final String codigoMatricula;
  final DateTime? fechaMatricula;
  final double? montoPagado;
  final String? comprobantePago;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Matricula({
    this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.dni,
    required this.carrera,
    required this.periodoAcademico,
    required this.tipo,
    required this.tipoDisplay,
    required this.estado,
    required this.estadoDisplay,
    required this.codigoMatricula,
    this.fechaMatricula,
    this.montoPagado,
    this.comprobantePago,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Matricula.fromJson(Map<String, dynamic> json) {
    return Matricula(
      id: json['id'],
      estudianteId: json['estudiante_id'] ?? 0,
      estudianteNombre: json['estudiante_nombre'] ?? '',
      dni: json['dni'] ?? '',
      carrera: json['carrera'] ?? '',
      periodoAcademico: json['periodo_academico'] ?? '',
      tipo: json['tipo'] ?? 'regular',
      tipoDisplay: json['tipo_display'] ?? 'Regular',
      estado: json['estado'] ?? 'activo',
      estadoDisplay: json['estado_display'] ?? 'Activo',
      codigoMatricula: json['codigo_matricula'] ?? '',
      fechaMatricula: json['fecha_matricula'] != null
          ? DateTime.parse(json['fecha_matricula'])
          : null,
      montoPagado: json['monto_pagado'] != null
          ? double.tryParse(json['monto_pagado'].toString())
          : null,
      comprobantePago: json['comprobante_pago'],
      observaciones: json['observaciones'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get estadoColor {
    switch (estado) {
      case 'activo':
        return 'green';
      case 'inactivo':
        return 'red';
      case 'reserva':
        return 'orange';
      default:
        return 'grey';
    }
  }

  String get tipoColor {
    switch (tipo) {
      case 'ingresante':
        return 'blue';
      case 'regular':
        return 'green';
      case 'extemporanea':
        return 'orange';
      case 'reserva':
        return 'purple';
      default:
        return 'grey';
    }
  }
}
