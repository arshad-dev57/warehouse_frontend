// lib/data/repositories/staff_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';

class StaffRepository extends GetxService {
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

  // Get all staff
  Future<Map<String, dynamic>> getStaff({
    String? role,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{};
      if (role != null && role != 'all') queryParams['role'] = role;
      if (status != null && status != 'all') queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/staff').replace(
        queryParameters: queryParams,
      );

      print("===== GET STAFF =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'data': [], 'counts': {}};
      }
    } catch (e) {
      print('Error loading staff: $e');
      return {'data': [], 'counts': {}};
    }
  }

  // Create staff
  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> staffData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/staff'),
        headers: headers,
        body: jsonEncode(staffData),
      );

      print("===== CREATE STAFF =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create staff');
      }
    } catch (e) {
      print('Error creating staff: $e');
      throw Exception('Failed to create staff: $e');
    }
  }

  // Update staff
  Future<Map<String, dynamic>> updateStaff(String id, Map<String, dynamic> staffData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/staff/$id'),
        headers: headers,
        body: jsonEncode(staffData),
      );

      print("===== UPDATE STAFF =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update staff');
      }
    } catch (e) {
      print('Error updating staff: $e');
      throw Exception('Failed to update staff: $e');
    }
  }

  // Toggle staff status
  Future<Map<String, dynamic>> toggleStaffStatus(String id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/staff/$id/toggle-status'),
        headers: headers,
      );

      print("===== TOGGLE STAFF STATUS =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to toggle status');
      }
    } catch (e) {
      print('Error toggling staff status: $e');
      throw Exception('Failed to toggle status: $e');
    }
  }

  // Delete staff
  Future<bool> deleteStaff(String id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$id'),
        headers: headers,
      );

      print("===== DELETE STAFF =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting staff: $e');
      return false;
    }
  }
}