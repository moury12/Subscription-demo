import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food.dart';

class AiFoodService {
  static String get _baseUrl {
    return 'http://localhost:3000/api/ai';
  }

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    // Request permissions (Skipped on Web as browser handles it)
    if (!kIsWeb) {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (status.isDenied) return null;
      } else {
        await Permission.photos.request();
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<AiFoodAnalysisResult?> analyzeFood(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/food-scan'));
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      final bytes = await imageFile.readAsBytes();
      
      String extension = imageFile.name.split('.').last.toLowerCase();
      String subtype = (extension == 'png') ? 'png' : 'jpeg';
      
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', subtype),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return AiFoodAnalysisResult.fromJson(json);
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Network error: $e');
      return null;
    }
  }
}
