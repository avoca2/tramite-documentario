class Estudiante {
  final int? id;
  final String dni;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final DateTime fechaNacimiento;
  final String celular;
  final String email;
  final String? direccion;
  final int carreraId;
  final String carreraNombre;
  final String codigoEstudiante;
  final String estado;

  Estudiante({
    this.id,
    required this.dni,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.celular,
    required this.email,
    this.direccion,
    required this.carreraId,
    required this.carreraNombre,
    required this.codigoEstudiante,
    required this.estado,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      id: json['id'],
      dni: json['dni'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] ?? DateTime.now().toIso8601String()),
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'],
      carreraId: json['carrera_id'] ?? 0,
      carreraNombre: json['carrera_nombre'] ?? '',
      codigoEstudiante: json['codigo_estudiante'] ?? '',
      estado: json['estado'] ?? 'activo',
    );
  }

  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';
}