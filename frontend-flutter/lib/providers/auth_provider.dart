import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];
      _apiService.setToken(_token!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setUserAndToken(Map<String, dynamic> userData, String token) {
    _user = User.fromJson(userData);
    _token = token;
    _apiService.setToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {}
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> getUser() async {
    try {
      final response = await _apiService.getUser();
      if (response != null) {
        _user = User.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      _user = null;
      _token = null;
      notifyListeners();
    }
  }
}