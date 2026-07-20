import "package:dio/dio.dart";
import "../models/notificacion.dart";
import "api_service.dart";

class NotificacionService {
  final ApiService _apiService = ApiService();

  // Obtener notificaciones del usuario
  Future<List<Notificacion>> getNotificaciones() async {
    try {
      final response = await _apiService.dio.get(
        "/notificaciones",
      );
      return (response.data as List)
          .map((json) => Notificacion.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener notificaciones");
    }
  }

  // Marcar como leída
  Future<Notificacion> marcarComoLeida(int notificacionId) async {
    try {
      final response = await _apiService.dio.put(
        "/notificaciones/$notificacionId/leer",
      );
      return Notificacion.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al marcar como leída");
    }
  }

  // Marcar todas como leídas
  Future<void> marcarTodasComoLeidas() async {
    try {
      await _apiService.dio.put(
        "/notificaciones/marcar-todas",
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al marcar todas como leídas");
    }
  }

  // Obtener contador de no leídas
  Future<int> getContadorNoLeidas() async {
    try {
      final response = await _apiService.dio.get(
        "/notificaciones/contador",
      );
      return response.data["count"] ?? 0;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener contador");
    }
  }
}
