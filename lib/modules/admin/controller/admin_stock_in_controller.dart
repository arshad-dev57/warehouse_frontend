// lib/modules/admin/stock/controllers/stock_in_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import '../../../data/models/product_model.dart';

class StockInController extends GetxController {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;

  StockInController({
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
  final suppliers = <Map<String, dynamic>>[].obs;
  final selectedSupplier = Rxn<String>();
  final selectedDate = Rxn<DateTime>();

  // Controllers
  final quantityController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
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

  void loadSuppliers() {
    // Mock suppliers
    suppliers.value = [
      {'id': 'sup1', 'name': 'Mobile World'},
      {'id': 'sup2', 'name': 'Medico Pharma'},
      {'id': 'sup3', 'name': 'Tools World'},
      {'id': 'sup4', 'name': 'Fashion Hub'},
    ];
  }

  void selectProduct() async {
    // Navigate to product search screen
    final result = await Get.toNamed('/admin/products/search');
    if (result != null && result is ProductModel) {
      selectedProduct.value = result;
    }
  }

  void clearSelectedProduct() {
    selectedProduct.value = null;
  }

  void selectSupplier(String? supplierId) {
    selectedSupplier.value = supplierId;
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
    return null;
  }

  Future<void> submitStockIn() async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    // Validate product selected
    if (selectedProduct.value == null) {
      Get.snackbar(
        'Error',
        'Please select a product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      // Create stock movement record
      final movement = {
        'productId': selectedProduct.value!.id,
        'productName': selectedProduct.value!.name,
        'type': 'stock_in',
        'quantity': int.parse(quantityController.text),
        'supplierId': selectedSupplier.value,
        'reference': referenceController.text,
        'date': selectedDate.value?.toIso8601String(),
        'notes': notesController.text,
        'userId': 'current_user_id', // Get from auth
      };

      // Update product stock
      final updatedProduct = selectedProduct.value!.copyWith(
        currentStock: selectedProduct.value!.currentStock + int.parse(quantityController.text),
      );

      await _productRepository.updateProduct(updatedProduct);
      await _stockRepository.addMovement(movement);

      Get.snackbar(
        'Success',
        'Stock added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back and refresh
      Get.back(result: true);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add stock: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}