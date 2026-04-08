import 'dart:convert';
import '../../../core/services/api_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiService _api = ApiService();

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _api.put('/user/profile', profileData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _api.get('/user/profile');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
