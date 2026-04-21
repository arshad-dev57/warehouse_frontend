  // lib/data/repositories/stock_repository.dart

  import 'dart:convert';
  import 'package:get/get.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:warehouse_management_app/data/services/api_service.dart';

  class StockRepository extends GetxService {
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

    // ✅ STOCK IN API
    Future<Map<String, dynamic>> addStock({
      required String productId,
      required int quantity,
      required String reason,
      String? supplierId,
      String? supplierName,
      String? reference,
      String? notes,
    }) async {
      try {
        final headers = await _getHeaders();
        
        final body = {
          'productId': productId,
          'quantity': quantity,
          'reason': reason,
          if (supplierId != null) 'supplierId': supplierId,
          if (supplierName != null) 'supplierName': supplierName,
          if (reference != null) 'reference': reference,
          if (notes != null) 'notes': notes,
        };

        print("===== STOCK IN API CALL =====");
        print("URL: $baseUrl/stock/in");
        print("Body: $body");

        final response = await http.post(
          Uri.parse('$baseUrl/stock/in'),
          headers: headers,
          body: jsonEncode(body),
        );

        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");

        if (response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Failed to add stock');
        }
      } catch (e) {
        print('Error adding stock: $e');
        throw Exception('Failed to add stock: $e');
      }
    }

    // ✅ STOCK OUT API
    Future<Map<String, dynamic>> removeStock({
      required String productId,
      required int quantity,
      required String reason,
      String? reference,
      String? notes,
    }) async {
      try {
        final headers = await _getHeaders();
        
        final body = {
          'productId': productId,
          'quantity': quantity,
          'reason': reason,
          if (reference != null) 'reference': reference,
          if (notes != null) 'notes': notes,
        };

        print("===== STOCK OUT API CALL =====");
        print("URL: $baseUrl/stock/out");
        print("Body: $body");

        final response = await http.post(
          Uri.parse('$baseUrl/stock/out'),
          headers: headers,
          body: jsonEncode(body),
        );

        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");

        if (response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Failed to remove stock');
        }
      } catch (e) {
        print('Error removing stock: $e');
        throw Exception('Failed to remove stock: $e');
      }
    }

    // ✅ GET STOCK HISTORY FOR A SPECIFIC PRODUCT
    Future<Map<String, dynamic>> getStockHistory({
      required String productId,
      int page = 1,
      int limit = 20,
    }) async {
      try {
        final headers = await _getHeaders();
        
        final uri = Uri.parse('$baseUrl/stock/history/$productId').replace(
          queryParameters: {
            'page': page.toString(),
            'limit': limit.toString(),
          },
        );

        print("===== GET STOCK HISTORY =====");
        print("URL: $uri");

        final response = await http.get(uri, headers: headers);

        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return {
            'success': false,
            'data': [], 
            'pagination': {'page': page, 'limit': limit, 'total': 0, 'pages': 1}
          };
        }
      } catch (e) {
        print('Error getting stock history: $e');
        return {
          'success': false,
          'data': [], 
          'pagination': {'page': page, 'limit': limit, 'total': 0, 'pages': 1}
        };
      }
    }

    // ✅ GET ALL STOCK HISTORY (FOR DASHBOARD) - NEW METHOD
    Future<List<Map<String, dynamic>>> getAllStockHistory({
      int page = 1,
      int limit = 100,
    }) async {
      try {
        final headers = await _getHeaders();
        
        final uri = Uri.parse('$baseUrl/stock/history/all').replace(
          queryParameters: {
            'page': page.toString(),
            'limit': limit.toString(),
          },
        );

        print("===== GET ALL STOCK HISTORY =====");
        print("URL: $uri");

        final response = await http.get(uri, headers: headers);

        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        } else {
          return [];
        }
      } catch (e) {
        print('Error getting all stock history: $e');
        return [];
      }
    }

    // ✅ GET SUPPLIERS LIST
    Future<List<Map<String, dynamic>>> getSuppliers() async {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$baseUrl/suppliers'),
          headers: headers,
        );

        print("===== GET SUPPLIERS =====");
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
  }