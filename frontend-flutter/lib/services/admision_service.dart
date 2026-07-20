import 'package:dio/dio.dart';
import '../models/admision.dart';

class AdmisionService {
  final Dio dio;
  String? _token;

  AdmisionService(this.dio);

  void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Obtener todas las admisiones
  Future<List<Admision>> getAdmisiones() async {
    try {
      final response = await dio.get('/admision');
      
      // Verificar que la respuesta es una lista
      if (response.data is List) {
        // Convertir cada elemento a Admision
        return (response.data as List).map((e) => Admision.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener admisiones');
    }
  }

  // Obtener admisión por ID
  Future<Admision?> getAdmisionById(int id) async {
    try {
      final response = await dio.get('/admision/$id');
      if (response.data != null) {
        return Admision.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(e.response?.data['message'] ?? 'Error al obtener admisión');
    }
  }

  // Inscribir estudiante
  Future<Map<String, dynamic>> inscribir(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/admision/inscribir', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al inscribir');
    }
  }

  // Evaluar estudiante
  Future<Admision> evaluar(int id, double nota) async {
    try {
      final response = await dio.put('/admision/evaluar/$id', data: {
        'nota_final': nota,
      });
      return Admision.fromJson(response.data['admision']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al evaluar');
    }
  }

  // Cambiar estado
  Future<Admision> actualizarEstado(int id, String estado) async {
    try {
      final response = await dio.put('/admision/estado/$id', data: {
        'estado': estado,
      });
      return Admision.fromJson(response.data['admision']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar estado');
    }
  }

  // Eliminar admisión
  Future<void> eliminar(int id) async {
    try {
      await dio.delete('/admision/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar');
    }
  }
} 