// lib/modules/admin/stock/controllers/stock_out_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import '../../../data/models/product_model.dart';


class StockOutController extends GetxController {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;

  StockOutController({
    required ProductRepository productRepository,
    required StockRepository stockRepository,
  })  : _productRepository = productRepository,
        _stockRepository = stockRepository;

  // Form
  final formKey = GlobalKey<FormState>();
  
  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Data
  final selectedProduct = Rxn<ProductModel>();
  final reasons = <Map<String, dynamic>>[].obs;
  final selectedReason = Rxn<String>();
  final selectedDate = Rxn<DateTime>();

  // Controllers
  final quantityController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadReasons();
    selectedDate.value = DateTime.now();
    
    // Check if product passed from details screen
    if (Get.arguments != null && Get.arguments['product'] != null) {
      selectedProduct.value = Get.arguments['product'];
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    referenceController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void loadReasons() {
    reasons.value = [
      {'id': 'sale', 'name': 'Sale to Customer'},
      {'id': 'damage', 'name': 'Damaged/Expired'},
      {'id': 'return', 'name': 'Return to Supplier'},
      {'id': 'internal', 'name': 'Internal Use'},
      {'id': 'sample', 'name': 'Sample'},
    ];
  }

  void selectProduct() async {
    final result = await Get.toNamed('/admin/products/search');
    if (result != null && result is ProductModel) {
      selectedProduct.value = result;
    }
  }

  void clearSelectedProduct() {
    selectedProduct.value = null;
  }

  void selectReason(String? reasonId) {
    selectedReason.value = reasonId;
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Enter a valid number';
    }
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    if (selectedProduct.value != null && 
        quantity > selectedProduct.value!.currentStock) {
      return 'Insufficient stock. Available: ${selectedProduct.value!.currentStock}';
    }
    return null;
  }

  Future<void> submitStockOut() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedProduct.value == null) {
      Get.snackbar('Error', 'Please select a product');
      return;
    }

    if (selectedReason.value == null) {
      Get.snackbar('Error', 'Please select a reason');
      return;
    }

    try {
      isSubmitting.value = true;

      final movement = {
        'productId': selectedProduct.value!.id,
        'productName': selectedProduct.value!.name,
        'type': 'stock_out',
        'reason': selectedReason.value,
        'quantity': int.parse(quantityController.text),
        'reference': referenceController.text,
        'date': selectedDate.value?.toIso8601String(),
        'notes': notesController.text,
        'userId': 'current_user_id',
      };

      final updatedProduct = selectedProduct.value!.copyWith(
        currentStock: selectedProduct.value!.currentStock - 
                     int.parse(quantityController.text),
        updatedAt: DateTime.now(),
      );

      await _productRepository.updateProduct(updatedProduct);
      await _stockRepository.addMovement(movement);

      Get.snackbar(
        'Success',
        'Stock removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove stock: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}