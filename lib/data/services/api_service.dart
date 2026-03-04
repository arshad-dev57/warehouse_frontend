// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:warehouse_management_app/config/app_config.dart';
import 'package:warehouse_management_app/core/utils/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:warehouse_management_app/data/models/api_response.dart';

class ApiService extends GetxService {
  late NetworkInfo _networkInfo;
  final String baseUrl = AppConfig.baseurl;
  
  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  @override
  void onInit() {
    super.onInit();
    _networkInfo = NetworkInfo(Connectivity());
  }
  
  // Internet check karne ka private method
  Future<bool> _checkInternet() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection. Please check your network.');
    }
    return true;
  }
  
  // GET request
  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      await _checkInternet();
      
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {..._headers, ...?headers},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // POST request
  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      await _checkInternet();
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      print("uri $uri");
      final response = await http.post(
        uri,
        headers: {..._headers, ...?headers},
        body: data != null ? jsonEncode(data) : null,
      );
      print("response body data  ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // PUT request
  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      await _checkInternet();
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      print("uri $uri");
      
      final response = await http.put(
        uri,
        headers: {..._headers, ...?headers},
        body: data != null ? jsonEncode(data) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // DELETE request
  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      await _checkInternet();
      
      final uri = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.delete(
        uri,
        headers: {..._headers, ...?headers},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // Response handle karne ka private method
  ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);
      
      switch (response.statusCode) {
        case 200:
        case 201:
          return ApiResponse(
            success: true,
            data: decodedBody,
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
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }
  }
  
  // Error handle karne ka private method
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
  
  // Internet status check karne ka public method
  Future<bool> hasInternet() async {
    return await _networkInfo.isConnected;
  }
  
  // Internet connection stream
  Stream<List<ConnectivityResult>> get internetStream {
    return _networkInfo.onConnectivityChanged;
  }
}