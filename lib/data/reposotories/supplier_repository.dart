// lib/data/repositories/supplier_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';


class SupplierRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  String get baseUrl => _apiService.baseUrl;

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all suppliers
  Future<List<Map<String, dynamic>>> getSuppliers({
    String? searchQuery,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/suppliers').replace(
        queryParameters: queryParams,
      );

      print("===== GET SUPPLIERS =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading suppliers: $e');
      return [];
    }
  }

  // Get single supplier
  Future<Map<String, dynamic>?> getSupplierById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error loading supplier: $e');
      return null;
    }
  }

  // Create supplier
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/suppliers'),
        headers: headers,
        body: jsonEncode(supplierData),
      );

      print("===== CREATE SUPPLIER =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create supplier');
      }
    } catch (e) {
      print('Error creating supplier: $e');
      throw Exception('Failed to create supplier: $e');
    }
  }

  // Update supplier
  Future<Map<String, dynamic>> updateSupplier(String id, Map<String, dynamic> supplierData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: headers,
        body: jsonEncode(supplierData),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update supplier');
      }
    } catch (e) {
      print('Error updating supplier: $e');
      throw Exception('Failed to update supplier: $e');
    }
  }

  // Delete supplier
  Future<bool> deleteSupplier(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting supplier: $e');
      return false;
    }
  }
}