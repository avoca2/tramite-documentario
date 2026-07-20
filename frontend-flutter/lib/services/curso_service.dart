import "package:dio/dio.dart";
import "../models/curso.dart";
import "api_service.dart";

class CursoService {
  final ApiService _apiService = ApiService();

  // Obtener cursos por carrera
  Future<List<Curso>> getCursosByCarrera(int carreraId) async {
    try {
      final response = await _apiService.dio.get(
        "/cursos/carrera/$carreraId",
      );
      return (response.data as List)
          .map((json) => Curso.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener cursos");
    }
  }

  // Obtener todos los cursos
  Future<List<Curso>> getCursos() async {
    try {
      final response = await _apiService.dio.get(
        "/cursos",
      );
      return (response.data as List)
          .map((json) => Curso.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener cursos");
    }
  }

  // Crear curso
  Future<Curso> crearCurso({
    required int carreraId,
    required String codigo,
    required String nombre,
    int creditos = 0,
    int horasTeoria = 0,
    int horasPractica = 0,
    int ciclo = 1,
    String? descripcion,
  }) async {
    try {
      final response = await _apiService.dio.post(
        "/cursos",
        data: {
          "carrera_id": carreraId,
          "codigo": codigo,
          "nombre": nombre,
          "creditos": creditos,
          "horas_teoria": horasTeoria,
          "horas_practica": horasPractica,
          "ciclo": ciclo,
          "descripcion": descripcion,
        },
      );
      return Curso.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al crear curso");
    }
  }

  // Actualizar curso
  Future<Curso> actualizarCurso(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        "/cursos/$id",
        data: data,
      );
      return Curso.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al actualizar curso");
    }
  }
}
