import "package:dio/dio.dart";
import "../models/seguimiento.dart";
import "api_service.dart";

class SeguimientoService {
  final ApiService _apiService = ApiService();

  // Obtener seguimientos de un trámite
  Future<List<Seguimiento>> getSeguimientosByTramite(int tramiteId) async {
    try {
      final response = await _apiService.dio.get(
        "/seguimientos/tramite/$tramiteId",
      );
      return (response.data as List)
          .map((json) => Seguimiento.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener seguimientos");
    }
  }

  // Registrar seguimiento
  Future<Seguimiento> registrarSeguimiento({
    required int tramiteId,
    required String estadoAnterior,
    required String estadoNuevo,
    String? comentario,
  }) async {
    try {
      final response = await _apiService.dio.post(
        "/seguimientos",
        data: {
          "tramite_id": tramiteId,
          "estado_anterior": estadoAnterior,
          "estado_nuevo": estadoNuevo,
          "comentario": comentario,
        },
      );
      return Seguimiento.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al registrar seguimiento");
    }
  }
}
