import '../utils/constants.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  final Dio dio = Dio();
  String? _token;

  ApiService() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Agregar interceptor para logs
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    print('Token configurado: $token');
  }

  // ============ DASHBOARD ============
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await dio.get('/dashboard/stats');
      print('Dashboard stats cargados');
      return response.data;
    } on DioException catch (e) {
      print('Error cargando dashboard stats: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al obtener estadísticas');
    }
  }

  // ============ AUTENTICACIÓN ============
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Intentando login: $email');
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      print('Login exitoso');
      return response.data;
    } on DioException catch (e) {
      print('Error login: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> enviarCodigo(String email) async {
    try {
      print('Enviando código a: $email');
      final response = await dio.post(
        '/enviar-codigo',
        data: {'email': email},
      );
      print('Código enviado: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Error enviar código: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error al enviar código');
    }
  }

  Future<Map<String, dynamic>> verificarCodigo(String email, String codigo) async {
    try {
      final response = await dio.post(
        '/verificar-codigo',
        data: {'email': email, 'codigo': codigo},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Código inválido o expirado');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String dni, String password) async {
    try {
      final response = await dio.post(
        '/register',
        data: {'name': name, 'email': email, 'dni': dni, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al registrarse');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cerrar sesión');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await dio.get('/user');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener usuario');
    }
  }

  // ============ CONSULTAS SUNAT/RENIEC ============

  Future<Map<String, dynamic>> consultarDni(String dni) async {
    try {
      final response = await dio.get('/consulta/dni/$dni');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al consultar DNI');
    }
  }

  Future<Map<String, dynamic>> consultarRuc(String ruc) async {
    try {
      final response = await dio.get('/consulta/ruc/$ruc');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al consultar RUC');
    }
  }
}