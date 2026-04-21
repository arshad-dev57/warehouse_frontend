// lib/data/repositories/order_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  String get baseUrl => _apiService.baseUrl;

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    print("🔑 OrderRepository Token: $token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

// lib/data/repositories/order_repository.dart

// Add this method if not exists

  // Get all orders
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/orders').replace(
        queryParameters: queryParams,
      );

      print("===== GET ORDERS =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> ordersJson = jsonData['data'] ?? [];
        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  // Get single order
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      print("===== GET ORDER BY ID =====");
      print("ID: $id");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error loading order: $e');
      return null;
    }
  }

  // Create order
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final headers = await _getHeaders();
      
      final body = {
        'customerName': order.customerName,
        'customerPhone': order.customerPhone,
        'customerAddress': order.customerAddress,
        'items': order.items.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
        }).toList(),
        'discount': order.discount,
        'notes': order.notes,
      };

      print("===== CREATE ORDER =====");
      print("URL: $baseUrl/orders");
      print("Body: $body");

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status) async {
    try {
      final headers = await _getHeaders();
      
      final body = {
        'status': status.name,
      };

      print("===== UPDATE ORDER STATUS =====");
      print("ID: $id");
      print("Status: ${status.name}");

      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return OrderModel.fromJson(jsonData['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update order');
      }
    } catch (e) {
      print('Error updating order: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  // Get orders count by status
  Future<Map<String, int>> getOrdersCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/counts'),
        headers: headers,
      );

      print("===== GET ORDERS COUNT =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Map<String, int>.from(jsonData['data'] ?? {});
      } else {
        return {
          'pending': 0,
          'processing': 0,
          'completed': 0,
          'cancelled': 0,
        };
      }
    } catch (e) {
      print('Error getting orders count: $e');
      return {
        'pending': 0,
        'processing': 0,
        'completed': 0,
        'cancelled': 0,
      };
    }
  }
}