import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/services/api_service.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final ApiService _api = ApiService();

  Future<String?> uploadFeedbackImage(List<int> bytes, String filename) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/upload/feedback-image');
      final request = http.MultipartRequest('POST', url);
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      String extension = filename.split('.').last.toLowerCase();
      String subtype = (extension == 'png') ? 'png' : 'jpeg';
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
          contentType: MediaType('image', subtype),
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['url'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitFeedback({
    required String title,
    required String description,
    required List<String> imageUrls,
  }) async {
    try {
      final response = await _api.post('/user/feedback', {
        'title': title,
        'description': description,
        'images': imageUrls,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
