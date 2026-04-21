// lib/modules/admin/stock/controllers/stock_in_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import 'package:warehouse_management_app/data/reposotories/supplier_repository.dart';
import '../../../../data/models/product_model.dart';


class StockInController extends GetxController {
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;
  final SupplierRepository _supplierRepository;

  StockInController({
    required ProductRepository productRepository,
    required StockRepository stockRepository,
    required SupplierRepository supplierRepository,
  })  : _productRepository = productRepository,
        _stockRepository = stockRepository,
        _supplierRepository = supplierRepository;

  // Form
  final formKey = GlobalKey<FormState>();
  
  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isLoadingSuppliers = false.obs;

  // Data
  final selectedProduct = Rxn<ProductModel>();
  final suppliers = <Map<String, dynamic>>[].obs;
  final selectedSupplier = Rxn<String>();
  final selectedSupplierName = ''.obs;
  final selectedDate = Rxn<DateTime>();

  // Controllers
  final quantityController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();

  // Flag to track if product is from details screen
  final isProductFromDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
    selectedDate.value = DateTime.now();
    
    // Check if product passed from details screen
    if (Get.arguments != null && Get.arguments['product'] != null) {
      selectedProduct.value = Get.arguments['product'];
      isProductFromDetails.value = true;
      print("Product from details: ${selectedProduct.value!.name}");
    } else {
      isProductFromDetails.value = false;
      print("Direct menu - no product selected");
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    referenceController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadSuppliers() async {
    try {
      isLoadingSuppliers.value = true;
      final fetchedSuppliers = await _supplierRepository.getSuppliers();
      suppliers.value = fetchedSuppliers;
    } catch (e) {
      print('Error loading suppliers: $e');
    } finally {
      isLoadingSuppliers.value = false;
    }
  }

  // 🔥 UPDATED: Product select method - navigates to search screen
  Future<void> selectProduct() async {
    // Agar product details se aaya hai to search nahi karega
    if (isProductFromDetails.value) {
      Get.snackbar(
        'Info',
        'Product already selected from details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    // Navigate to product search screen and wait for result
    final result = await Get.toNamed('/admin/products/search');
    
    if (result != null && result is ProductModel) {
      selectedProduct.value = result;
      
      Get.snackbar(
        'Product Selected',
        '${result.name} selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void clearSelectedProduct() {
    if (isProductFromDetails.value) {
      Get.snackbar(
        'Info',
        'Product from details cannot be cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    selectedProduct.value = null;
  }

  void selectSupplier(String? supplierId) {
    if (supplierId != null) {
      final supplier = suppliers.firstWhereOrNull((s) => s['id'] == supplierId);
      if (supplier != null) {
        selectedSupplier.value = supplierId;
        selectedSupplierName.value = supplier['name'] ?? '';
      }
    } else {
      selectedSupplier.value = null;
      selectedSupplierName.value = '';
    }
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
    if (!formKey.currentState!.validate()) return;

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

      final result = await _stockRepository.addStock(
        productId: selectedProduct.value!.id,
        quantity: int.parse(quantityController.text),
        reason: 'purchase',
        supplierId: selectedSupplier.value,
        supplierName: selectedSupplierName.value.isNotEmpty ? selectedSupplierName.value : null,
        reference: referenceController.text.isNotEmpty ? referenceController.text : null,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );

      Get.snackbar(
        'Success',
        result['message'] ?? 'Stock added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back(result: true);
      });
      
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}