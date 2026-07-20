import 'package:dio/dio.dart';
import '../models/titulacion.dart';

class TitulacionService {
  final Dio dio;
  String? _token;

  TitulacionService(this.dio);

  void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<Titulacion>> getTitulaciones() async {
    try {
      final response = await dio.get('/titulacion');
      if (response.data is List) {
        return (response.data as List).map((e) => Titulacion.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener titulaciones');
    }
  }

  Future<Map<String, dynamic>> solicitarTitulacion(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/titulacion/solicitar', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al solicitar titulación');
    }
  }

  Future<Titulacion> reprogramarExamen(int id, String fechaExamen) async {
    try {
      final response = await dio.put('/titulacion/reprogramar/$id', data: {
        'fecha_examen': fechaExamen,
      });
      return Titulacion.fromJson(response.data['titulacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al reprogramar examen');
    }
  }

  Future<Titulacion> evaluar(int id, double nota) async {
    try {
      final response = await dio.put('/titulacion/evaluar/$id', data: {
        'nota_examen': nota,
      });
      return Titulacion.fromJson(response.data['titulacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al evaluar');
    }
  }

  Future<Titulacion> otorgarTitulo(int id) async {
    try {
      final response = await dio.put('/titulacion/otorgar/$id');
      return Titulacion.fromJson(response.data['titulacion']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al otorgar título');
    }
  }

  Future<void> eliminarTitulacion(int id) async {
    try {
      await dio.delete('/titulacion/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar titulación');
    }
  }
}
