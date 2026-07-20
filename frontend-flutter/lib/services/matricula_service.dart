import 'package:dio/dio.dart';
import '../models/matricula.dart';

class MatriculaService {
  final Dio dio;
  String? _token;

  MatriculaService(this.dio);

  void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Matricula>> getMatriculas() async {
    try {
      final response = await dio.get('/matricula');
      if (response.data is List) {
        return (response.data as List).map((e) => Matricula.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener matrículas');
    }
  }

  Future<Matricula?> getMatriculaById(int id) async {
    try {
      final response = await dio.get('/matricula/$id');
      if (response.data != null) {
        return Matricula.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.response?.data['message'] ?? 'Error al obtener matrícula');
    }
  }

  Future<Map<String, dynamic>> registrarMatricula(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/matricula', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al registrar matrícula');
    }
  }

  Future<Matricula> actualizarMatricula(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/matricula/$id', data: data);
      return Matricula.fromJson(response.data['matricula']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar matrícula');
    }
  }

  Future<void> eliminarMatricula(int id) async {
    try {
      await dio.delete('/matricula/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar matrícula');
    }
  }

  Future<List<Matricula>> getMatriculasByEstudiante(int estudianteId) async {
    try {
      final response = await dio.get('/matricula/estudiante/$estudianteId');
      if (response.data is List) {
        return (response.data as List).map((e) => Matricula.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener matrículas del estudiante');
    }
  }

  Future<List<String>> getPeriodos() async {
    try {
      final response = await dio.get('/matricula/periodos');
      if (response.data is List) {
        return (response.data as List).map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener periodos');
    }
  }
}
