import "package:dio/dio.dart";
import "api_service.dart";

class ConfiguracionService {
  final ApiService _apiService = ApiService();

  // Obtener configuración por grupo
  Future<Map<String, dynamic>> getConfiguracionesByGrupo(String grupo) async {
    try {
      final response = await _apiService.dio.get(
        "/configuraciones/grupo/$grupo",
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener configuraciones");
    }
  }

  // Obtener configuración específica
  Future<String> getConfiguracion(String grupo, String clave) async {
    try {
      final response = await _apiService.dio.get(
        "/configuraciones/$grupo/$clave",
      );
      return response.data["valor"] ?? "";
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener configuración");
    }
  }

  // Actualizar configuración
  Future<void> actualizarConfiguracion(String grupo, String clave, String valor) async {
    try {
      await _apiService.dio.put(
        "/configuraciones",
        data: {
          "grupo": grupo,
          "clave": clave,
          "valor": valor,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al actualizar configuración");
    }
  }
}
