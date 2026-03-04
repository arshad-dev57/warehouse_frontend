// lib/modules/admin/products/controllers/product_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import '../../../../data/models/product_model.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository _repository;

  ProductDetailsController({required ProductRepository repository})
      : _repository = repository;

  // State
  final isLoading = true.obs;
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
      loadStockHistory();
    } else {
      error.value = 'Product ID not found';
      isLoading.value = false;
    }
  }

  Future<void> loadProductData(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final data = await _repository.getProductById(id);
      if (data != null) {
        product.value = data;
      } else {
        error.value = 'Product not found';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void loadStockHistory() {
    // Mock stock history data
    stockHistory.value = [
      {
        'id': 'h1',
        'type': 'stock_in',
        'quantity': 50,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'user': 'Ali Raza',
        'note': 'New stock received',
      },
      {
        'id': 'h2',
        'type': 'stock_out',
        'quantity': 5,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'user': 'Sara Khan',
        'note': 'Order #123',
      },
      {
        'id': 'h3',
        'type': 'stock_out',
        'quantity': 3,
        'date': DateTime.now(),
        'user': 'Ahmed Malik',
        'note': 'Order #124',
      },
      {
        'id': 'h4',
        'type': 'stock_in',
        'quantity': 20,
        'date': DateTime.now(),
        'user': 'Fatima Ali',
        'note': 'Return from customer',
      },
    ];
  }

  void changeImage(int index) {
    selectedImageIndex.value = index;
  }

  void navigateToEdit() {
    Get.toNamed(
      '/admin/products/edit',
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
      
      final success = await _repository.deleteProduct(productId!);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back(result: true); // Go back and refresh list
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
      arguments: {'product': product.value},
    );
  }

  void navigateToStockOut() {
    Get.toNamed(
      AppRoutes.stockOut,
      arguments: {'product': product.value},
    );
  }

  void printBarcode() {
    Get.snackbar(
      'Info',
      'Printing barcode for ${product.value?.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement barcode printing
  }

  void shareProduct() {
    Get.snackbar(
      'Info',
      'Sharing product details',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement share functionality
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
    return '₹${profit.toStringAsFixed(2)} (${margin.toStringAsFixed(1)}%)';
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