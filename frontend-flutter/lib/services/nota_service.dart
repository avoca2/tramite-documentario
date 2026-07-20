import "package:dio/dio.dart";
import "../models/nota.dart";
import "api_service.dart";

class NotaService {
  final ApiService _apiService = ApiService();

  // Obtener notas de un estudiante
  Future<List<Nota>> getNotasByEstudiante(int estudianteId) async {
    try {
      final response = await _apiService.dio.get(
        "/notas/estudiante/$estudianteId",
      );
      return (response.data as List)
          .map((json) => Nota.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener notas");
    }
  }

  // Obtener notas de un estudiante por periodo
  Future<List<Nota>> getNotasByEstudianteAndPeriodo(int estudianteId, int periodoId) async {
    try {
      final response = await _apiService.dio.get(
        "/notas/estudiante/$estudianteId/periodo/$periodoId",
      );
      return (response.data as List)
          .map((json) => Nota.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener notas por periodo");
    }
  }

  // Registrar nota
  Future<Nota> registrarNota({
    required int estudianteId,
    required int cursoId,
    required int periodoAcademicoId,
    double? notaParcial1,
    double? notaParcial2,
    double? notaExamen,
    String? observaciones,
  }) async {
    try {
      final response = await _apiService.dio.post(
        "/notas",
        data: {
          "estudiante_id": estudianteId,
          "curso_id": cursoId,
          "periodo_academico_id": periodoAcademicoId,
          "nota_parcial_1": notaParcial1,
          "nota_parcial_2": notaParcial2,
          "nota_examen": notaExamen,
          "observaciones": observaciones,
        },
      );
      return Nota.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al registrar nota");
    }
  }

  // Actualizar nota
  Future<Nota> actualizarNota(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        "/notas/$id",
        data: data,
      );
      return Nota.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al actualizar nota");
    }
  }

  // Calcular promedio del estudiante
  Future<double> getPromedioEstudiante(int estudianteId) async {
    try {
      final response = await _apiService.dio.get(
        "/notas/promedio/$estudianteId",
      );
      return response.data["promedio"] ?? 0.0;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al calcular promedio");
    }
  }
}
