import "package:dio/dio.dart";
import "../models/periodo_academico.dart";
import "api_service.dart";

class PeriodoAcademicoService {
  final ApiService _apiService = ApiService();

  // Obtener todos los periodos
  Future<List<PeriodoAcademico>> getPeriodos() async {
    try {
      final response = await _apiService.dio.get(
        "/periodos-academicos",
      );
      return (response.data as List)
          .map((json) => PeriodoAcademico.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener periodos");
    }
  }

  // Obtener periodo actual
  Future<PeriodoAcademico?> getPeriodoActual() async {
    try {
      final response = await _apiService.dio.get(
        "/periodos-academicos/actual",
      );
      return PeriodoAcademico.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener periodo actual");
    }
  }

  // Crear periodo
  Future<PeriodoAcademico> crearPeriodo({
    required String nombre,
    required String codigo,
    required String fechaInicio,
    required String fechaFin,
    String? fechaLimiteInscripcion,
    String? fechaLimitePago,
    bool activo = false,
    bool actual = false,
  }) async {
    try {
      final response = await _apiService.dio.post(
        "/periodos-academicos",
        data: {
          "nombre": nombre,
          "codigo": codigo,
          "fecha_inicio": fechaInicio,
          "fecha_fin": fechaFin,
          "fecha_limite_inscripcion": fechaLimiteInscripcion,
          "fecha_limite_pago": fechaLimitePago,
          "activo": activo,
          "actual": actual,
        },
      );
      return PeriodoAcademico.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al crear periodo");
    }
  }

  // Actualizar periodo
  Future<PeriodoAcademico> actualizarPeriodo(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        "/periodos-academicos/$id",
        data: data,
      );
      return PeriodoAcademico.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al actualizar periodo");
    }
  }
}
