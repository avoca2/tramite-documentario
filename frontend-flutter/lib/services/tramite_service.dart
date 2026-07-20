import 'package:dio/dio.dart';
import '../models/tramite.dart';

class TramiteService {
  final Dio _dio;
  String? _token;

  TramiteService(this._dio);

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Obtener todos los trámites
  Future<List<Tramite>> getTramites() async {
    try {
      final response = await _dio.get('/tramites');
      if (response.data is List) {
        return response.data.map((e) => Tramite.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener trámites');
    }
  }

  // Obtener trámites por estudiante
  Future<List<Tramite>> getTramitesByEstudiante(String estudianteId) async {
    try {
      final response = await _dio.get('/tramites/estudiante/$estudianteId');
      if (response.data is List) {
        return response.data.map((e) => Tramite.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener trámites');
    }
  }

  // Obtener trámites por tipo
  Future<List<Tramite>> getTramitesByTipo(String tipo) async {
    try {
      final response = await _dio.get('/tramites/tipo/$tipo');
      if (response.data is List) {
        return response.data.map((e) => Tramite.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener trámites');
    }
  }

  // Crear nuevo trámite
  Future<Tramite> crearTramite(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/tramites', data: data);
      return Tramite.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear trámite');
    }
  }

  // Actualizar trámite
  Future<Tramite> actualizarTramite(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/tramites/$id', data: data);
      return Tramite.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar trámite');
    }
  }

  // Eliminar trámite
  Future<void> eliminarTramite(int id) async {
    try {
      await _dio.delete('/tramites/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar trámite');
    }
  }
}