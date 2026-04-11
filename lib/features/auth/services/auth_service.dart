import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/app_settings.dart';
import '../../../core/services/user_data_sync.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      }, requiresAuth: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    try {
      final response = await _api.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
      }, requiresAuth: false);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    UserDataSync.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await _fetchAndSyncProfile();
  }

  Future<void> _fetchAndSyncProfile() async {
    try {
      final response = await _api.get('/user/profile');
      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        AppSettings().syncFromProfile(profileData);
      }
    } catch (e) {
      // Profile fetch failed silently
    }
  }
}
