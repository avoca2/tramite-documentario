import 'package:dio/dio.dart';
import '../models/convalidacion.dart';

class ConvalidacionService {
  final Dio dio;
  String? _token;

  ConvalidacionService(this.dio);

  void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Convalidacion>> getConvalidaciones() async {
    try {
      final response = await dio.get('/convalidacion');
      if (response.data is List) {
        return (response.data as List).map((e) => Convalidacion.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener convalidaciones');
    }
  }

  Future<Convalidacion?> getConvalidacionById(int id) async {
    try {
      final response = await dio.get('/convalidacion/$id');
      if (response.data != null) {
        return Convalidacion.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.response?.data['message'] ?? 'Error al obtener convalidación');
    }
  }

  Future<Map<String, dynamic>> solicitarConvalidacion(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/convalidacion/solicitar', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al solicitar convalidación');
    }
  }

  Future<Convalidacion> actualizarConvalidacion(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/convalidacion/$id', data: data);
      return Convalidacion.fromJson(response.data['convalidacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar convalidación');
    }
  }

  Future<void> eliminarConvalidacion(int id) async {
    try {
      await dio.delete('/convalidacion/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar convalidación');
    }
  }

  Future<List<Convalidacion>> getByEstudiante(int estudianteId) async {
    try {
      final response = await dio.get('/convalidacion/estudiante/$estudianteId');
      if (response.data is List) {
        return (response.data as List).map((e) => Convalidacion.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener convalidaciones del estudiante');
    }
  }

  Future<Convalidacion> aprobar(int id) async {
    try {
      final response = await dio.put('/convalidacion/aprobar/$id');
      return Convalidacion.fromJson(response.data['convalidacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al aprobar convalidación');
    }
  }

  Future<Convalidacion> rechazar(int id) async {
    try {
      final response = await dio.put('/convalidacion/rechazar/$id');
      return Convalidacion.fromJson(response.data['convalidacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al rechazar convalidación');
    }
  }
}
