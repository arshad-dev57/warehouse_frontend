import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/product_model.dart';
import 'package:warehouse_management_app/modules/search/controllers/search_product_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/barcode_scanner_widget.dart';

class ProductSearchView extends GetView<ProductSearchController> {
  const ProductSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Product',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1E1E2F)),
            onPressed: _showBarcodeScanner,
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Scan Button
          _buildSearchBar(),
          
          // Scanning Indicator
          _buildScanningIndicator(),
          
          // Recent Scans
          _buildRecentScans(),
          
          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.searchProducts(value),
              decoration: InputDecoration(
                hintText: 'Search by name or SKU...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: controller.clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              autofocus: true,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              onPressed: _showBarcodeScanner,
              tooltip: 'Scan Barcode',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Obx(() {
      if (controller.isScanning.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Scanning barcode...',
                  style: GoogleFonts.inter(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: controller.cancelScan,
                color: Colors.blue.shade700,
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildRecentScans() {
    return Obx(() {
      if (controller.recentScans.isNotEmpty && !controller.isScanning.value) {
        return Container(
          height: 40,
          margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.recentScans.length,
            itemBuilder: (context, index) {
              final scan = controller.recentScans[index];
              return GestureDetector(
                onTap: () => controller.searchByBarcode(scan),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(scan),
                    onDeleted: () => controller.removeRecentScan(index),
                    backgroundColor: Colors.grey.shade100,
                    deleteIcon: const Icon(Icons.close, size: 14),
                  ),
                ),
              );
            },
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(message: 'Searching...');
      }
      
      if (controller.error.value.isNotEmpty) {
        return _buildErrorState();
      }
      
      if (controller.products.isEmpty) {
        if (controller.searchController.text.isEmpty) {
          return _buildInitialState();
        }
        return _buildEmptyState(
          message: 'No products found for "${controller.searchController.text}"',
          showAddButton: true,
          barcode: controller.lastScannedBarcode.value,
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductTile(product);
        },
      );
    });
  }

  // ==================== FIXED BARCODE SCANNER METHOD ====================
  
  /// Show barcode scanner and handle the result
  Future<void> _showBarcodeScanner() async {
    print("📱 Opening barcode scanner...");
    
    // Navigate to scanner and wait for result
    final scannedBarcode = await Get.to(
      () => const BarcodeScannerScreen(),
      fullscreenDialog: true,
    );
    
    // Handle the result
    if (scannedBarcode != null && scannedBarcode is String) {
      print("✅ Barcode received: $scannedBarcode");
      
      // Show scanning indicator
      controller.isScanning.value = true;
      
      // Search for product with this barcode
      await controller.searchByBarcode(scannedBarcode);
      
      // Hide scanning indicator
      controller.isScanning.value = false;
    } else {
      print("📱 Scanner closed without barcode");
    }
  }

  // ==================== TILE BUILDERS ====================

  Widget _buildProductTile(ProductModel product) {
    return GestureDetector(
      onTap: () => Get.back(result: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            _buildProductImage(product),
            const SizedBox(width: 12),
            Expanded(child: _buildProductInfo(product)),
            _buildSelectIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: product.imageUrls.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade400,
                ),
              ),
            )
          : Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'SKU: ${product.sku}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Stock: ${product.currentStock}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (product.barcode != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Barcode: ${product.barcode}',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: 16,
        color: Colors.green.shade700,
      ),
    );
  }

  // ==================== STATE WIDGETS ====================

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Products',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type product name, SKU or scan barcode',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showBarcodeScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Barcode'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Updated Empty State with better UX
  Widget _buildEmptyState({
    required String message,
    required bool showAddButton,
    String? barcode,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 24),
            
            // Message
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Suggestion
            Text(
              'Would you like to add this product?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (barcode != null) ...[
              const SizedBox(height: 12),
              // Show barcode if available
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Barcode: $barcode',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Add Product Button (Primary Action)
            if (showAddButton)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (barcode != null) {
                        controller.addProductFromRecentScan(barcode);
                      } else {
                        // If no barcode, just go to add product screen
                        Get.toNamed(AppRoutes.AddProduct);
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      barcode != null ? 'Add This Product' : 'Add New Product',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            
            // Secondary Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Try Again Button
                OutlinedButton.icon(
                  onPressed: () {
                    if (barcode != null) {
                      controller.searchByBarcode(barcode);
                    } else {
                      controller.searchProducts(controller.searchController.text);
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E1E2F),
                    side: const BorderSide(color: Color(0xFF1E1E2F)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Scan Another Button
                ElevatedButton.icon(
                  onPressed: _showBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              controller.error.value = '';
              controller.searchProducts(controller.searchController.text);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}