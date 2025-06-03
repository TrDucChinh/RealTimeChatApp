import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

class NetworkService {
  final String baseUrl;
  final String token;

  NetworkService({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      // Check for common error status codes
      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      } else if (response.statusCode == 404) {
        throw Exception('Not found: The requested resource was not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      }
      
      return response;
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to load data: ${e.toString()}');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      
      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      } else if (response.statusCode == 404) {
        throw Exception('Not found: The requested resource was not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      }
      
      return response;
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to send data: ${e.toString()}');
    }
  }

  Future<http.Response> uploadFiles(String endpoint, List<File> files) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      
      // Add necessary headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      });

      // Add files to request as form-data
      for (var i = 0; i < files.length; i++) {
        print('Adding file ${i + 1}/${files.length} to request');
        final file = files[i];
        final fileSize = await file.length();
        print('File size before upload: $fileSize bytes');
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            file.path,
            contentType: MediaType('image', 'jpeg'), // Add content type
          ),
        );
      }

      print('Sending multipart request...');
      // Send request with longer timeout
      final streamedResponse = await request.send().timeout(
        Duration(seconds: 60), // Increased timeout
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );
      
      print('Converting streamed response to response...');
      final response = await http.Response.fromStream(streamedResponse);
      print('Response received with status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      } else if (response.statusCode == 404) {
        throw Exception('Not found: The requested resource was not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      }

      return response;
    } on TimeoutException {
      print('Request timed out');
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      print('Error uploading files: $e');
      throw Exception('Failed to upload files: ${e.toString()}');
    }
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      
      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      } else if (response.statusCode == 404) {
        throw Exception('Not found: The requested resource was not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      }
      
      return response;
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to update data: ${e.toString()}');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      } else if (response.statusCode == 404) {
        throw Exception('Not found: The requested resource was not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      }
      
      return response;
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to delete data: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    try {
      final response = await get('/message/$conversationId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid data format received from server');
      }
      rethrow;
    }
  }
}
