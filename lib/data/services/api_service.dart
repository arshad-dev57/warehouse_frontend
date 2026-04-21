// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:warehouse_management_app/config/app_config.dart';
import 'package:warehouse_management_app/core/utils/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:warehouse_management_app/data/models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetxService {
  late NetworkInfo _networkInfo;
  final String baseUrl = AppConfig.baseurl;

  @override
  void onInit() {
    super.onInit();
    _networkInfo = NetworkInfo(Connectivity());
  }

  /// SharedPreferences se token nikal kar headers banane ka method
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    print("🔑 [API Service] Token from SharedPreferences: '$token'");
    print("🔑 [API Service] Token length: ${token.length}");
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Internet check karne ka private method
  Future<bool> _checkInternet() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection. Please check your network.');
    }
    return true;
  }

  /// GET request
  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    print("\n========== 🌐 API GET REQUEST ==========");
    print("📍 Endpoint: $endpoint");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      await _checkInternet();

      final baseHeaders = await _headers();
      print("📋 Base Headers: ${baseHeaders.keys}");
      print("🔑 Auth Token Present: ${baseHeaders['Authorization'] != 'Bearer '}");
      
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      print("🌐 URL: $uri");
      
      final allHeaders = {...baseHeaders, ...?headers};
      
      final response = await http
          .get(
            uri,
            headers: allHeaders,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      print("========== END GET REQUEST ==========\n");

      return _handleResponse(response);
    } catch (e) {
      print("❌ GET Error: $e");
      print("========== END GET REQUEST (ERROR) ==========\n");
      return _handleError(e);
    }
  }

  /// POST request
  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    print("\n========== 🌐 API POST REQUEST ==========");
    print("📍 Endpoint: $endpoint");
    print("📦 Data: $data");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      await _checkInternet();

      final baseHeaders = await _headers();
      print("📋 Base Headers: ${baseHeaders.keys}");
      print("🔑 Auth Token Present: ${baseHeaders['Authorization'] != 'Bearer '}");
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      print("🌐 URL: $uri");

      final allHeaders = {...baseHeaders, ...?headers};
      
      final response = await http.post(
        uri,
        headers: allHeaders,
        body: data != null ? jsonEncode(data) : null,
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      print("========== END POST REQUEST ==========\n");

      return _handleResponse(response);
    } catch (e) {
      print("❌ POST Error: $e");
      print("========== END POST REQUEST (ERROR) ==========\n");
      return _handleError(e);
    }
  }

  /// PUT request
  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    print("\n========== 🌐 API PUT REQUEST ==========");
    print("📍 Endpoint: $endpoint");
    print("📦 Data: $data");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      await _checkInternet();

      final baseHeaders = await _headers();
      print("📋 Base Headers: ${baseHeaders.keys}");
      print("🔑 Auth Token Present: ${baseHeaders['Authorization'] != 'Bearer '}");
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      print("🌐 URL: $uri");

      final allHeaders = {...baseHeaders, ...?headers};
      
      final response = await http
          .put(
            uri,
            headers: allHeaders,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      print("========== END PUT REQUEST ==========\n");

      return _handleResponse(response);
    } catch (e) {
      print("❌ PUT Error: $e");
      print("========== END PUT REQUEST (ERROR) ==========\n");
      return _handleError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    print("\n========== 🌐 API DELETE REQUEST ==========");
    print("📍 Endpoint: $endpoint");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      await _checkInternet();

      final baseHeaders = await _headers();
      print("📋 Base Headers: ${baseHeaders.keys}");
      print("🔑 Auth Token Present: ${baseHeaders['Authorization'] != 'Bearer '}");
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      print("🌐 URL: $uri");

      final allHeaders = {...baseHeaders, ...?headers};
      
      final response = await http
          .delete(
            uri,
            headers: allHeaders,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      print("========== END DELETE REQUEST ==========\n");

      return _handleResponse(response);
    } catch (e) {
      print("❌ DELETE Error: $e");
      print("========== END DELETE REQUEST (ERROR) ==========\n");
      return _handleError(e);
    }
  }

  /// Response handle karne ka private method
  ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return ApiResponse(
            success: true,
            data: decodedBody['data'] ?? decodedBody,
            message: decodedBody['message'] ?? 'Success',
            statusCode: response.statusCode,
          );

        case 400:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Bad request',
            statusCode: response.statusCode,
          );

        case 401:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Unauthorized',
            statusCode: response.statusCode,
          );

        case 403:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Forbidden',
            statusCode: response.statusCode,
          );

        case 404:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Not found',
            statusCode: response.statusCode,
          );

        case 500:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Server error',
            statusCode: response.statusCode,
          );

        default:
          return ApiResponse(
            success: false,
            message: decodedBody['message'] ?? 'Something went wrong',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      print("❌ Response parsing error: $e");
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }
  }

  /// Error handle karne ka private method
  ApiResponse<dynamic> _handleError(dynamic error) {
    String message;

    if (error.toString().contains('No internet')) {
      message = 'No internet connection. Please check your network.';
    } else if (error.toString().contains('timeout')) {
      message = 'Request timeout. Please try again.';
    } else {
      message = error.toString().replaceAll('Exception:', '').trim();
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: null,
    );
  }

  /// Internet status check karne ka public method
  Future<bool> hasInternet() async {
    return await _networkInfo.isConnected;
  }

  /// Internet connection stream
  Stream<List<ConnectivityResult>> get internetStream {
    return _networkInfo.onConnectivityChanged;
  }
}