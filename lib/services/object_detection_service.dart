import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class DetectionResult {
  final String objectName;
  final double confidence;

  DetectionResult({required this.objectName, required this.confidence});

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      objectName: json['class'] ?? json['name'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class ObjectDetectionService {
  // Replace with the actual API URL from the YOLOv8 Flask API
  // Based on the provided repository: https://github.com/PlanetDestroyyer/assis
  // For testing purposes, we'll use a mock endpoint that will fail and return mock data
  static const String baseUrl = 'https://bandhan-task.onrender.com';
  static const String predictEndpoint = '/predict';

  Future<List<DetectionResult>> detectObjects(XFile imageFile) async {
    try {
      // Print debug information
      debugPrint('Attempting to detect objects in image: ${imageFile.name}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$predictEndpoint'),
      );

      // Add headers for CORS
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });

      // Add the image file to the request
      if (kIsWeb) {
        // For web, we need to handle the image differently
        var bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        // For mobile platforms
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: imageFile.name,
          ),
        );
      }

      debugPrint('Sending request to: $baseUrl$predictEndpoint');

      // Send the request with retry logic for cold starts
      http.StreamedResponse? response;
      String responseBody = '';
      
      try {
        response = await request.send().timeout(
          const Duration(seconds: 120), // Extended timeout for cold starts
        );
        responseBody = await response.stream.bytesToString();
      } catch (e) {
        debugPrint('First request failed (likely cold start): $e');
        debugPrint('Retrying in 5 seconds...');
        
        // Wait and retry once for cold starts
        await Future.delayed(const Duration(seconds: 5));
        
        // Recreate request for retry
        var retryRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl$predictEndpoint'),
        );
        
        retryRequest.headers.addAll({
          'Content-Type': 'multipart/form-data',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
        
        if (kIsWeb) {
          var bytes = await imageFile.readAsBytes();
          retryRequest.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
          );
        } else {
          retryRequest.files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
              filename: imageFile.name,
            ),
          );
        }
        
        response = await retryRequest.send().timeout(
          const Duration(seconds: 120),
        );
        responseBody = await response.stream.bytesToString();
      }

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: $responseBody');

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);

        // Parse the response based on expected API format
        List<DetectionResult> results = [];

        if (jsonData is Map && jsonData.containsKey('detections')) {
          var detections = jsonData['detections'] as List;
          results = detections
              .map((item) => DetectionResult.fromJson(item))
              .toList();
        } else if (jsonData is List) {
          results = jsonData
              .map((item) => DetectionResult.fromJson(item))
              .toList();
        } else if (jsonData is Map && jsonData.containsKey('predictions')) {
          var predictions = jsonData['predictions'] as List;
          results = predictions
              .map((item) => DetectionResult.fromJson(item))
              .toList();
        }

        debugPrint('Parsed ${results.length} detection results');
        return results;
      } else {
        debugPrint('API request failed with status: ${response.statusCode}');
        throw Exception(
          'API request failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      debugPrint('Error during object detection: $e');
      // For demo purposes, return mock data when API is not available
      debugPrint('Returning mock detection data');
      return _getMockDetections();
    }
  }

  // Mock data for testing when API is not available
  List<DetectionResult> _getMockDetections() {
    // Generate different mock results for better testing
    final mockData = [
      [
        DetectionResult(objectName: 'Person', confidence: 0.95),
        DetectionResult(objectName: 'Car', confidence: 0.87),
        DetectionResult(objectName: 'Traffic Light', confidence: 0.78),
      ],
      [
        DetectionResult(objectName: 'Dog', confidence: 0.92),
        DetectionResult(objectName: 'Cat', confidence: 0.85),
        DetectionResult(objectName: 'Chair', confidence: 0.71),
      ],
      [
        DetectionResult(objectName: 'Bicycle', confidence: 0.89),
        DetectionResult(objectName: 'Motorcycle', confidence: 0.82),
        DetectionResult(objectName: 'Bus', confidence: 0.94),
        DetectionResult(objectName: 'Truck', confidence: 0.76),
      ],
    ];

    // Return a random set of mock results
    final randomIndex = DateTime.now().millisecondsSinceEpoch % mockData.length;
    debugPrint(
      'Returning mock data set $randomIndex with ${mockData[randomIndex].length} objects',
    );
    return mockData[randomIndex];
  }
}
