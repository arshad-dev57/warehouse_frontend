import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/product_model.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';

class ProductSearchController extends GetxController {
  final ProductRepository _repository = Get.find<ProductRepository>();
  
  // Text Controllers
  final searchController = TextEditingController();
  
  // Observable Variables
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final error = ''.obs;
  final recentScans = <String>[].obs;
  
  // Last scanned barcode - properly initialized as Rxn
  final lastScannedBarcode = Rxn<String>();

  // Debounce timer
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _loadRecentScans();
    
    // Listen to search controller changes
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchProducts(searchController.text);
    });
  }

  void _loadRecentScans() async {
    // Load from SharedPreferences if needed
    recentScans.value = [];
  }

  // ==================== BARCODE SEARCH METHOD ====================
  
  Future<void> searchByBarcode(String barcode) async {
    if (barcode.isEmpty) return;
    
    print("🔍 Searching by barcode: $barcode");
    lastScannedBarcode.value = barcode; // Store for later use
    
    try {
      isScanning.value = true;
      isLoading.value = true;
      error.value = '';
      
      // Add to recent scans
      if (!recentScans.contains(barcode)) {
        recentScans.insert(0, barcode);
        if (recentScans.length > 5) {
          recentScans.removeLast();
        }
      }
      
      final product = await _repository.getProductByBarcode(barcode);
      
      if (product != null) {
        print("✅ Product found: ${product.name}");
        products.value = [product];
        
        Get.snackbar(
          'Success',
          'Product found: ${product.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        print("❌ No product found for barcode: $barcode");
        products.clear();
        _showProductNotFoundDialog(barcode);
      }
      
    } catch (e) {
      print('❌ Barcode search error: $e');
      error.value = 'Failed to search by barcode';
      Get.snackbar(
        'Error',
        'Failed to search by barcode: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isScanning.value = false;
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Product Not Found',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  barcode,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No product exists with this barcode in the system.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _navigateToAddProduct(barcode);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E2F),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add Product',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Get.back();
                  searchController.text = barcode;
                  searchProducts(barcode);
                },
                icon: const Icon(Icons.search, size: 16),
                label: Text(
                  'Search manually instead',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddProduct(String barcode) {
    Get.toNamed(
      AppRoutes.AddProduct,
    
    )?.then((result) {
      if (result == true) {
        searchByBarcode(barcode);
      }
    });
  }

  void addProductFromRecentScan(String barcode) {
    _navigateToAddProduct(barcode);
  }

  // ==================== SEARCH METHODS ====================

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      products.clear();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      
      print("Searching for: $query");
      
      final results = await _repository.searchProducts(query);
      
      products.value = results;
      print("Found ${results.length} products");
      
    } catch (e) {
      error.value = e.toString();
      print('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    products.clear();
    lastScannedBarcode.value = null;
  }

  void cancelScan() {
    isScanning.value = false;
  }

  void removeRecentScan(int index) {
    recentScans.removeAt(index);
  }
}