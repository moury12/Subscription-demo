import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../../core/services/localization_service.dart';

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

  Future<bool> updateLanguagePreference(String languageCode) async {
    try {
      final response = await _api.put('/user/profile', {
        'language': languageCode,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserLanguagePreference() async {
    try {
      final response = await _api.get('/user/profile/language');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['language'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
