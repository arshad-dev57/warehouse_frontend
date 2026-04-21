// lib/data/repositories/inventory_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';

class InventoryRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  String get baseUrl => _apiService.baseUrl;

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get inventory valuation
  Future<Map<String, dynamic>> getInventoryValuation({
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final uri = Uri.parse('$baseUrl/inventory/valuation').replace(
        queryParameters: queryParams,
      );

      print("===== GET INVENTORY VALUATION =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error loading inventory valuation: $e');
      return {};
    }
  }

  // Get valuation summary
  Future<Map<String, dynamic>> getValuationSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inventory/valuation/summary'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error loading valuation summary: $e');
      return {};
    }
  }

  // Get category breakdown
  Future<List<Map<String, dynamic>>> getCategoryBreakdown() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inventory/valuation/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading category breakdown: $e');
      return [];
    }
  }
}