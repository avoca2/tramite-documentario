import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RoleProvider extends ChangeNotifier {
  final ApiService _apiService;
  String? _rol;
  Map<String, bool>? _permissions;
  bool _isLoading = false;

  RoleProvider(this._apiService);

  String? get rol => _rol;
  Map<String, bool>? get permissions => _permissions;
  bool get isLoading => _isLoading;
  bool get isAdmin => _rol == 'admin';

  Future<void> loadUserRole(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _apiService.setToken(token);
      final response = await _apiService.dio.get('/user-role');
      print('Rol cargado: ${response.data}');
      _rol = response.data['rol'] ?? 'usuario';
      _permissions = Map<String, bool>.from(response.data['permissions'] ?? {});
    } catch (e) {
      print('Error cargando rol: $e');
      _rol = 'usuario';
      _permissions = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    return _permissions?[permission] ?? false;
  }

  void clear() {
    _rol = null;
    _permissions = null;
    notifyListeners();
  }
}