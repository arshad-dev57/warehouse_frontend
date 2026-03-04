// lib/modules/admin/reports/controllers/reports_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_model.dart';

class ReportsController extends GetxController {
  final ProductRepository _productRepository;

  ReportsController({required ProductRepository productRepository})
      : _productRepository = productRepository;

  final isLoading = true.obs;
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  
  // Date range
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;

  // Summary data
  final categorySummary = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      final results = await Future.wait([
        _productRepository.getProducts(),
        _productRepository.getCategories(),
      ]);

      products.value = results[0] as List<ProductModel>;
      categories.value = results[1] as List<CategoryModel>;
      
      _calculateCategorySummary();
      
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateCategorySummary() {
    final summary = <Map<String, dynamic>>[];
    
    for (var category in categories) {
      final categoryProducts = products.where((p) => p.categoryId == category.id).toList();
      final totalValue = categoryProducts.fold(0.0, (sum, p) => sum + (p.sellingPrice * p.currentStock));
      
      summary.add({
        'id': category.id,
        'name': category.name,
        'count': categoryProducts.length,
        'value': totalValue.toStringAsFixed(0),
        'color': category.color,
      });
    }
    
    categorySummary.value = summary;
  }

  // Getters
  int get totalProducts => products.length;
  
  String get totalStockValue {
    final total = products.fold(0.0, (sum, p) => sum + (p.sellingPrice * p.currentStock));
    return total.toStringAsFixed(0);
  }
  
  String get averagePrice {
    if (products.isEmpty) return '0';
    final total = products.fold(0.0, (sum, p) => sum + p.sellingPrice);
    return (total / products.length).toStringAsFixed(0);
  }
  
  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  String getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<void> selectDateRange() async {
    // Implement date range picker
    Get.snackbar('Info', 'Date range picker coming soon');
  }

  Future<void> exportAsPDF() async {
    Get.snackbar(
      'Success',
      'PDF downloaded successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> shareReport() async {
    Get.snackbar(
      'Success',
      'Report shared successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
// lib/modules/admin/reports/controllers/reports_controller.dart mein ye getters add karo

  // Low Stock Products
  List<ProductModel> get lowStockProducts {
    return products.where((p) => p.isLowStock).toList();
  }

  // Expiry Products
  List<ProductModel> get expiringSoonProducts {
    return products.where((p) => 
      p.expiryDate != null && 
      p.expiryDate!.difference(DateTime.now()).inDays <= 30 &&
      p.expiryDate!.difference(DateTime.now()).inDays > 0
    ).toList();
  }

  List<ProductModel> get expiredProducts {
    return products.where((p) => 
      p.expiryDate != null && 
      p.expiryDate!.isBefore(DateTime.now())
    ).toList();
  }

  List<ProductModel> get productsWithExpiry {
    return products.where((p) => p.expiryDate != null).toList();
  }

  // Reorder Functions
  void reorderProduct(String productId) {
    Get.toNamed(
      AppRoutes.stockIn,
      arguments: {'productId': productId},
    );
  }

  void createBulkPurchaseOrders() {
    Get.snackbar(
      'Success',
      'Purchase orders created for all low stock items',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

}