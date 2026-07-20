import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_analysis.dart';

class ProductScanController {
  static String get _baseUrl {
    // Deployed AWS Backend
    return 'https://backend.getgocal.com/api/ai';

    /* Local Development fallbacks:
    if (kReleaseMode) {
      return 'https://backend.getgocal.com/api/ai';
    }
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:5000/api/ai';
    }
    return 'http://localhost:5000/api/ai';
    */
  }

  /**
   * Sends the barcode to the backend to lookup and analyze the product.
   * Returns [ProductAnalysisResult] if successful, null if the product is not found,
   * and throws an exception for other API errors.
   */
  Future<ProductAnalysisResult?> scanBarcode(String barcode, {String languageCode = 'en'}) async {
    try {
      final url = Uri.parse('$_baseUrl/scan-product?lang=$languageCode');
      debugPrint('[ProductScanController] Calling: $url for barcode: $barcode');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'barcode': barcode}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ProductAnalysisResult.fromJson(json);
      } else if (response.statusCode == 404) {
        debugPrint('[ProductScanController] Barcode not found: $barcode');
        return null; // Return null so screen knows to offer fallback
      } else {
        debugPrint('[ProductScanController] Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ProductScanController] scanBarcode exception: $e');
      rethrow;
    }
  }

  /**
   * Uploads a captured product label/packaging image for OCR and AI analysis.
   * Returns [ProductAnalysisResult] if successful.
   */
  Future<ProductAnalysisResult?> scanLabel(XFile imageFile, {String languageCode = 'en'}) async {
    try {
      final url = Uri.parse('$_baseUrl/scan-label?lang=$languageCode');
      debugPrint('[ProductScanController] Calling: $url for label OCR');

      var request = http.MultipartRequest('POST', url);
      
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

      var responseStream = await request.send();
      var response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ProductAnalysisResult.fromJson(json);
      } else {
        debugPrint('[ProductScanController] Label scan error: ${response.statusCode} - ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ProductScanController] scanLabel exception: $e');
      rethrow;
    }
  }
}
