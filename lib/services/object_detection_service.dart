import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class DetectionResult {
  final String objectName;
  final double confidence;
  final Map<String, double>? bbox;

  DetectionResult({
    required this.objectName,
    required this.confidence,
    this.bbox,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      objectName: json['class_name'] ?? json['name'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      bbox: json['bbox'] != null ? {
        'x1': (json['bbox']['x1'] ?? 0.0).toDouble(),
        'y1': (json['bbox']['y1'] ?? 0.0).toDouble(),
        'x2': (json['bbox']['x2'] ?? 0.0).toDouble(),
        'y2': (json['bbox']['y2'] ?? 0.0).toDouble(),
      } : null,
    );
  }
}

class ObjectDetectionService {
  static const String baseUrl = 'https://bandhan-task.onrender.com';
  static const String predictEndpoint = '/predict';

  Future<List<DetectionResult>> detectObjects(XFile imageFile) async {
    try {
      debugPrint('🔍 Starting object detection for: ${imageFile.name}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$predictEndpoint'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add the image file
      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // Backend expects 'file'
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Backend expects 'file'
            imageFile.path,
            filename: imageFile.name,
          ),
        );
      }

      debugPrint('📤 Sending request to: $baseUrl$predictEndpoint');

      // Send request with cold start handling
      http.StreamedResponse response;
      String responseBody;
      
      try {
        // First attempt
        response = await request.send().timeout(
          const Duration(seconds: 120),
        );
        responseBody = await response.stream.bytesToString();
      } catch (e) {
        debugPrint('⏰ First request failed (cold start): $e');
        debugPrint('🔄 Retrying in 5 seconds...');
        
        await Future.delayed(const Duration(seconds: 5));
        
        // Recreate request for retry
        var retryRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl$predictEndpoint'),
        );
        
        retryRequest.headers.addAll({
          'Accept': 'application/json',
        });
        
        if (kIsWeb) {
          var bytes = await imageFile.readAsBytes();
          retryRequest.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
          );
        } else {
          retryRequest.files.add(
            await http.MultipartFile.fromPath('file', imageFile.path, filename: imageFile.name),
          );
        }
        
        response = await retryRequest.send().timeout(
          const Duration(seconds: 120),
        );
        responseBody = await response.stream.bytesToString();
      }

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: $responseBody');

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);

        List<DetectionResult> results = [];

        if (jsonData is List) {
          results = jsonData
              .map((item) => DetectionResult.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        debugPrint('✅ Successfully parsed ${results.length} detections');
        return results;
      } else {
        throw Exception('API Error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('❌ Detection failed: $e');
      rethrow;
    }
  }

  // Test API health
  static Future<bool> testApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }
}
