// lib/modules/admin/products/controllers/add_product_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'dart:io';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_model.dart';

class AddProductController extends GetxController {
  final ProductRepository _repository;

  AddProductController({required ProductRepository repository})
      : _repository = repository;

  // Form state
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isEditing = false.obs;
  String? productId;

  // Text Controllers
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final costPriceController = TextEditingController();
  final currentStockController = TextEditingController();
  final minimumStockController = TextEditingController();
  final maximumStockController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable values
  final selectedCategory = Rxn<CategoryModel>();
  final selectedSupplier = Rxn<Map<String, dynamic>>();
  final expiryDate = Rxn<DateTime>();
  final images = <File>[].obs;
  final categories = <CategoryModel>[].obs;
  final suppliers = <Map<String, dynamic>>[].obs;

  // Dropdown options
  final aisles = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final racks = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final bins = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10'];

  final selectedAisle = 'A'.obs;
  final selectedRack = '1'.obs;
  final selectedBin = 'B1'.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    
    // Check if editing
    if (Get.arguments != null) {
      productId = Get.arguments['productId'];
      if (productId != null) {
        isEditing.value = true;
        loadProductData(productId!);
      }
    }
    
    // Update location when dropdowns change
    ever(selectedAisle, (_) => updateLocation());
    ever(selectedRack, (_) => updateLocation());
    ever(selectedBin, (_) => updateLocation());
    
    // Set initial location
    updateLocation();
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    sellingPriceController.dispose();
    costPriceController.dispose();
    currentStockController.dispose();
    minimumStockController.dispose();
    maximumStockController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load initial data (categories, suppliers)
  Future<void> loadInitialData() async {
    try {
      // Load categories
      final cats = await _repository.getCategories();
      categories.value = cats;
      
      // Mock suppliers (replace with actual API call)
      suppliers.value = [
        {'id': 'sup1', 'name': 'Mobile World', 'company': 'Tech Distributors', 'phone': '0300-1234567'},
        {'id': 'sup2', 'name': 'Medico Pharma', 'company': 'Pharma Ltd', 'phone': '0301-7654321'},
        {'id': 'sup3', 'name': 'Tools World', 'company': 'Hardware Inc', 'phone': '0302-9876543'},
        {'id': 'sup4', 'name': 'Fashion Hub', 'company': 'Garments Co', 'phone': '0303-4567890'},
        {'id': 'sup5', 'name': 'Food Suppliers', 'company': 'Food Corp', 'phone': '0304-1122334'},
      ];
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load product data for editing
  Future<void> loadProductData(String id) async {
    try {
      isLoading.value = true;
      final product = await _repository.getProductById(id);
      
      if (product != null) {
        // Fill controllers
        nameController.text = product.name;
        skuController.text = product.sku;
        barcodeController.text = product.barcode ?? '';
        sellingPriceController.text = product.sellingPrice.toString();
        costPriceController.text = product.costPrice.toString();
        currentStockController.text = product.currentStock.toString();
        minimumStockController.text = product.minimumStock.toString();
        maximumStockController.text = product.maximumStock.toString();
        descriptionController.text = product.description ?? '';
        
        // Set selections
        final category = categories.firstWhereOrNull((c) => c.id == product.categoryId);
        selectedCategory.value = category;
        
        final supplier = suppliers.firstWhereOrNull((s) => s['id'] == product.supplierId);
        selectedSupplier.value = supplier;
        
        expiryDate.value = product.expiryDate;
        
        // Parse location
        final locParts = product.location.split('-');
        if (locParts.length == 3) {
          selectedAisle.value = locParts[0];
          selectedRack.value = locParts[1];
          selectedBin.value = locParts[2];
        }
        
        // Note: Images will be loaded from network, not File
        // You'll need to handle network images separately
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update location string
  void updateLocation() {
    locationController.text = '${selectedAisle.value}-${selectedRack.value}-${selectedBin.value}';
  }

  // Pick image from camera/gallery
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source == ImageSource.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
        
        Get.snackbar(
          'Success',
          'Image added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove image
  void removeImage(int index) {
    images.removeAt(index);
    Get.snackbar(
      'Success',
      'Image removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Select category
  void selectCategory(CategoryModel? category) {
    selectedCategory.value = category;
  }

  // Select supplier
  void selectSupplier(Map<String, dynamic>? supplier) {
    selectedSupplier.value = supplier;
  }

  // Select expiry date
  void selectExpiryDate(DateTime? date) {
    expiryDate.value = date;
  }

  // Generate barcode
  Future<void> generateBarcode() async {
    // Mock barcode generation
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString().substring(0, 12);
    barcodeController.text = 'BC$random';
    
    Get.snackbar(
      'Success',
      'Barcode generated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Scan barcode
  Future<void> scanBarcode() async {
    // Mock barcode scanning - actual implementation will use barcode_scan package
    Get.snackbar(
      'Info',
      'Scanner will open here',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    
    // Simulate scan result after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    barcodeController.text = 'SCAN${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}';
    
    Get.snackbar(
      'Success',
      'Barcode scanned successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // MARK: - Validators

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateSku(String? value) {
    if (value == null || value.isEmpty) {
      return 'SKU is required';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Enter a valid number';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock quantity is required';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Enter a valid number';
    }
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    return null;
  }

  // MARK: - Save Product

  Future<void> saveProduct() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate category
    if (selectedCategory.value == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate min/max stock
    final minStock = int.parse(minimumStockController.text);
    final maxStock = int.parse(maximumStockController.text);
    
    if (minStock >= maxStock) {
      Get.snackbar(
        'Error',
        'Minimum stock must be less than maximum stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Create product object
      final product = ProductModel(
        id: isEditing.value ? productId! : '',
        name: nameController.text.trim(),
        sku: skuController.text.trim(),
        barcode: barcodeController.text.isNotEmpty ? barcodeController.text.trim() : null,
        categoryId: selectedCategory.value!.id,
        categoryName: selectedCategory.value!.name,
        supplierId: selectedSupplier.value?['id'],
        supplierName: selectedSupplier.value?['name'],
        sellingPrice: double.parse(sellingPriceController.text),
        costPrice: double.parse(costPriceController.text),
        currentStock: int.parse(currentStockController.text),
        minimumStock: int.parse(minimumStockController.text),
        maximumStock: int.parse(maximumStockController.text),
        location: locationController.text,
        imageUrls: [], // Will be updated after image upload
        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
        expiryDate: expiryDate.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to repository
      if (isEditing.value) {
        await _repository.updateProduct(product);
        Get.snackbar(
          'Success',
          'Product updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _repository.addProduct(product);
        Get.snackbar(
          'Success',
          'Product added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Navigate back and refresh
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back(result: true);
      });
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel and go back
  void cancel() {
    Get.back();
  }

  // MARK: - Helper Methods

  // Clear form
  void clearForm() {
    nameController.clear();
    skuController.clear();
    barcodeController.clear();
    sellingPriceController.clear();
    costPriceController.clear();
    currentStockController.clear();
    minimumStockController.clear();
    maximumStockController.clear();
    descriptionController.clear();
    
    selectedCategory.value = null;
    selectedSupplier.value = null;
    expiryDate.value = null;
    images.clear();
    
    selectedAisle.value = 'A';
    selectedRack.value = '1';
    selectedBin.value = 'B1';
  }

  // Check if form is valid (for enabling save button)
  bool get isFormValid {
    return nameController.text.isNotEmpty &&
           skuController.text.isNotEmpty &&
           sellingPriceController.text.isNotEmpty &&
           costPriceController.text.isNotEmpty &&
           currentStockController.text.isNotEmpty &&
           minimumStockController.text.isNotEmpty &&
           maximumStockController.text.isNotEmpty &&
           selectedCategory.value != null;
  }
}