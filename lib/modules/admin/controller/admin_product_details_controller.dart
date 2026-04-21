// lib/modules/admin/products/controllers/product_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';

import '../../../../data/models/product_model.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;

  ProductDetailsController({
    required ProductRepository productRepository,
    required StockRepository stockRepository,
  })  : _productRepository = productRepository,
        _stockRepository = stockRepository;

  // State
  final isLoading = true.obs;
  final isLoadingHistory = false.obs;
  final error = ''.obs;
  
  // Data
  final product = Rxn<ProductModel>();
  final stockHistory = <Map<String, dynamic>>[].obs;
  
  // UI
  final selectedImageIndex = 0.obs;
  final isShowingDeleteDialog = false.obs;

  String? productId;

  @override
  void onInit() {
    super.onInit();
    productId = Get.parameters['productId'];
    if (productId != null) {
      loadProductData(productId!);
      // ❌ loadStockHistory() removed from here - will be called from loadProductData
    } else {
      error.value = 'Product ID not found';
      isLoading.value = false;
    }
  }

  Future<void> loadProductData(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print("Loading product details for ID: $id");
      
      final data = await _productRepository.getProductById(id);
      
      if (data != null) {
        product.value = data;
        print("Product loaded: ${data.name}");
        // ✅ Load stock history after product is loaded
        await loadStockHistory();
      } else {
        error.value = 'Product not found';
      }
    } catch (e) {
      error.value = e.toString();
      print('Error loading product: $e');
    } finally {
      isLoading.value = false;
      print("isLoading set to false");
    }
  }

  Future<void> loadStockHistory() async {
    if (productId == null) return;
    
    try {
      isLoadingHistory.value = true;
      
      print("Loading stock history for product: $productId");
      
      final result = await _stockRepository.getStockHistory(
        productId: productId!,
        page: 1,
        limit: 5,
      );
      
      print("Stock history result: $result");
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        stockHistory.value = List<Map<String, dynamic>>.from(data);
        print("Loaded ${stockHistory.length} history items");
      } else {
        print("Failed to load history: ${result['message']}");
      }
      
    } catch (e) {
      print('Error loading stock history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void changeImage(int index) {
    selectedImageIndex.value = index;
  }

  void navigateToEdit() {
    Get.toNamed(
      AppRoutes.AddProduct,
      arguments: {'productId': productId},
    )?.then((result) {
      if (result == true) {
        loadProductData(productId!);
      }
    });
  }

  void showDeleteDialog() {
    isShowingDeleteDialog.value = true;
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.value?.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: deleteProduct,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((_) => isShowingDeleteDialog.value = false);
  }

  Future<void> deleteProduct() async {
    try {
      isLoading.value = true;
      Get.back(); // Close dialog
      
      print("Deleting product ID: $productId");
      
      final success = await _productRepository.deleteProduct(productId!);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(result: true);
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToStockIn() {
    Get.toNamed(
      AppRoutes.stockIn,
      arguments: {
        'product': product.value,
        'source': 'product_details'
      },
    );
  }

  void navigateToStockOut() {
    Get.toNamed(
      AppRoutes.stockOut,
      arguments: {
        'product': product.value,
        'source': 'product_details'
      },
    );
  }

  void printBarcode() {
    Get.snackbar(
      'Info',
      'Printing barcode for ${product.value?.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareProduct() {
    Get.snackbar(
      'Info',
      'Sharing product details',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Helper getters
  String get stockStatusText {
    if (product.value == null) return '';
    return product.value!.stockStatus;
  }

  Color get stockStatusColor {
    if (product.value == null) return Colors.grey;
    return product.value!.stockStatusColor;
  }

  String get profitText {
    if (product.value == null) return '';
    final profit = product.value!.profit;
    final margin = product.value!.profitMargin;
    return '\$${profit.toStringAsFixed(2)} (${margin.toStringAsFixed(1)}%)';
  }

  Color get profitColor {
    if (product.value == null) return Colors.grey;
    final profit = product.value!.profit;
    if (profit > 0) return Colors.green;
    if (profit < 0) return Colors.red;
    return Colors.grey;
  }

  String get locationText => product.value?.location ?? 'Not assigned';
  
  String get expiryText {
    if (product.value?.expiryDate == null) return 'No expiry';
    final date = product.value!.expiryDate!;
    final daysLeft = date.difference(DateTime.now()).inDays;
    
    if (daysLeft < 0) return 'Expired';
    if (daysLeft <= 30) return 'Expires in $daysLeft days';
    return 'Expires on ${_formatDate(date)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}