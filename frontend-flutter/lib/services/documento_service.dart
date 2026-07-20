import "package:dio/dio.dart";
import "../models/documento.dart";
import "api_service.dart";

class DocumentoService {
  final ApiService _apiService = ApiService();

  // Subir documento
  Future<Documento> subirDocumento({
    required int estudianteId,
    required int tipoDocumentoId,
    required String nombreArchivo,
    required String ruta,
    required String mimeType,
    required int tamano,
    String? hash,
  }) async {
    try {
      final response = await _apiService.dio.post(
        "/documentos",
        data: {
          "estudiante_id": estudianteId,
          "tipo_documento_id": tipoDocumentoId,
          "nombre_archivo": nombreArchivo,
          "ruta": ruta,
          "mime_type": mimeType,
          "tamano": tamano,
          "hash": hash,
        },
      );
      return Documento.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al subir documento");
    }
  }

  // Obtener documentos de un estudiante
  Future<List<Documento>> getDocumentosByEstudiante(int estudianteId) async {
    try {
      final response = await _apiService.dio.get(
        "/documentos/estudiante/$estudianteId",
      );
      return (response.data as List)
          .map((json) => Documento.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener documentos");
    }
  }

  // Verificar documento
  Future<Documento> verificarDocumento(int documentoId, String estado, String? observaciones) async {
    try {
      final response = await _apiService.dio.put(
        "/documentos/$documentoId/verificar",
        data: {
          "estado": estado,
          "observaciones": observaciones,
        },
      );
      return Documento.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al verificar documento");
    }
  }

  // Obtener tipos de documentos
  Future<List<TipoDocumento>> getTiposDocumentos() async {
    try {
      final response = await _apiService.dio.get(
        "/tipos-documentos",
      );
      return (response.data as List)
          .map((json) => TipoDocumento.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Error al obtener tipos de documentos");
    }
  }
}
