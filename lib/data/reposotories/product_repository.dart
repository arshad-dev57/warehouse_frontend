// lib/data/repositories/product_repository.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  String get baseUrl => _apiService.baseUrl;

  // Get auth token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    print("🔑 ProductRepository Token: $token");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== PRODUCT METHODS ====================

  // Get all products
  Future<List<ProductModel>> getProducts({
    String? searchQuery,
    String? categoryId,
    String? stockStatus,
    String? sortBy,
    bool ascending = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }
      if (stockStatus != null && stockStatus.isNotEmpty) {
        queryParams['stockStatus'] = stockStatus;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
        queryParams['sortOrder'] = ascending ? 'asc' : 'desc';
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/products').replace(
        queryParameters: queryParams,
      );

      print("===== GET PRODUCTS =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> productsJson = jsonData['data'] ?? [];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        print('Failed to load products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }
// lib/data/repositories/product_repository.dart

// ==================== BARCODE METHODS ====================

/// Get product by barcode
Future<ProductModel?> getProductByBarcode(String barcode) async {
  try {
    final headers = await _getHeaders();
    
    final uri = Uri.parse('$baseUrl/products/barcode/$barcode');
    
    print("===== GET PRODUCT BY BARCODE =====");
    print("URL: $uri");
    print("Barcode: $barcode");

    final response = await http.get(uri, headers: headers);

    print("Status: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ProductModel.fromJson(jsonData['data']);
    } else if (response.statusCode == 404) {
      print("Product not found for barcode: $barcode");
      return null;
    } else {
      print("Error response: ${response.body}");
      return null;
    }
  } catch (e) {
    print('❌ Error getting product by barcode: $e');
    return null;
  }
}

/// Check if barcode exists
Future<bool> checkBarcodeExists(String barcode) async {
  try {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/products/check-barcode/$barcode'),
      headers: headers,
    );

    print("===== CHECK BARCODE EXISTS =====");
    print("Barcode: $barcode");
    print("Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['exists'] ?? false;
    }
    return false;
  } catch (e) {
    print('❌ Error checking barcode: $e');
    return false;
  }
}

/// Search products by barcode (partial match)
Future<List<ProductModel>> searchByBarcode(String barcodePartial, {int limit = 20}) async {
  try {
    final headers = await _getHeaders();
    
    final uri = Uri.parse('$baseUrl/products/search/barcode').replace(
      queryParameters: {
        'q': barcodePartial,
        'limit': limit.toString(),
      },
    );

    print("===== SEARCH BY BARCODE =====");
    print("URL: $uri");
    print("Query: $barcodePartial");

    final response = await http.get(uri, headers: headers);

    print("Status: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> productsJson = jsonData['data'] ?? [];
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print('❌ Error searching by barcode: $e');
    return [];
  }
}  // Get single product
  Future<ProductModel?> getProductById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );
      
      print("===== GET PRODUCT BY ID =====");
      print("ID: $id");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error loading product: $e');
      return null;
    }
  }

  // Add product (with images if needed)
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final token = await _getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'),
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['name'] = product.name;
      request.fields['sku'] = product.sku;
      if (product.barcode != null) {
        request.fields['barcode'] = product.barcode!;
      }
      request.fields['categoryId'] = product.categoryId;
      request.fields['sellingPrice'] = product.sellingPrice.toString();
      request.fields['costPrice'] = product.costPrice.toString();
      request.fields['currentStock'] = product.currentStock.toString();
      request.fields['minimumStock'] = product.minimumStock.toString();
      request.fields['maximumStock'] = product.maximumStock.toString();
      request.fields['location'] = product.location;
      if (product.description != null) {
        request.fields['description'] = product.description!;
      }
      if (product.expiryDate != null) {
        request.fields['expiryDate'] = product.expiryDate!.toIso8601String();
      }

      print("===== ADD PRODUCT =====");
      print("Fields: ${request.fields}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add product');
      }
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  // Add product with images
  Future<ProductModel> addProductWithImages(
    ProductModel product,
    List<http.MultipartFile> imageFiles,
  ) async {
    try {
      final token = await _getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'),
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add fields
      request.fields['name'] = product.name;
      request.fields['sku'] = product.sku;
      if (product.barcode != null) {
        request.fields['barcode'] = product.barcode!;
      }
      request.fields['categoryId'] = product.categoryId;
      request.fields['sellingPrice'] = product.sellingPrice.toString();
      request.fields['costPrice'] = product.costPrice.toString();
      request.fields['currentStock'] = product.currentStock.toString();
      request.fields['minimumStock'] = product.minimumStock.toString();
      request.fields['maximumStock'] = product.maximumStock.toString();
      request.fields['location'] = product.location;
      if (product.description != null) {
        request.fields['description'] = product.description!;
      }
      if (product.expiryDate != null) {
        request.fields['expiryDate'] = product.expiryDate!.toIso8601String();
      }

      // Add images
      request.files.addAll(imageFiles);

      print("===== ADD PRODUCT WITH IMAGES =====");
      print("Fields: ${request.fields}");
      print("Images: ${imageFiles.length}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add product');
      }
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final headers = await _getHeaders();
      
      print("===== UPDATE PRODUCT =====");
      print("ID: ${product.id}");
      print("Data: ${product.toJson()}");

      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: headers,
        body: jsonEncode(product.toJson()),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      
      print("===== DELETE PRODUCT =====");
      print("ID: $id");

      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query, {int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      
      final uri = Uri.parse('$baseUrl/products/search').replace(
        queryParameters: {
          'q': query,
          'limit': limit.toString(),
        },
      );

      print("===== SEARCH PRODUCTS =====");
      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> productsJson = jsonData['data'] ?? [];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // ==================== CATEGORY METHODS ====================

  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      );

      print("===== GET CATEGORIES =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> categoriesJson = jsonData['data'] ?? [];
        
        for (var cat in categoriesJson) {
          print("Category from API: ${cat['_id']} - ${cat['name']}");
        }
        
        return categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
      );

      print("===== GET CATEGORY BY ID =====");
      print("ID: $id");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CategoryModel.fromJson(jsonData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error loading category: $e');
      return null;
    }
  }

  // Add category (returns CategoryModel)
  Future<CategoryModel?> addCategory(Map<String, dynamic> categoryData) async {
    try {
      final headers = await _getHeaders();
      
      print("===== ADD CATEGORY =====");
      print("Data: $categoryData");

      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
        body: jsonEncode(categoryData),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return CategoryModel.fromJson(jsonData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  // Update category (returns CategoryModel)
  Future<CategoryModel?> updateCategory(String id, Map<String, dynamic> categoryData) async {
    try {
      final headers = await _getHeaders();
      
      print("===== UPDATE CATEGORY =====");
      print("ID: $id");
      print("Data: $categoryData");

      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
        body: jsonEncode(categoryData),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CategoryModel.fromJson(jsonData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error updating category: $e');
      return null;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      final headers = await _getHeaders();
      
      print("===== DELETE CATEGORY =====");
      print("ID: $id");

      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Get categories with product counts
  Future<List<CategoryModel>> getCategoriesWithCounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories/with-counts'),
        headers: headers,
      );

      print("===== GET CATEGORIES WITH COUNTS =====");
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> categoriesJson = jsonData['data'] ?? [];
        return categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error loading categories with counts: $e');
      return [];
    }
  }
}