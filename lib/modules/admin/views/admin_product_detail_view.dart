// lib/modules/admin/products/views/product_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/product_model.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_details_controller.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/loading_widget.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading product details...');
        }
        
        if (controller.error.isNotEmpty) {
          return _buildErrorWidget();
        }
        
        if (controller.product.value == null) {
          return _buildNotFoundWidget();
        }
        
        return _buildContent();
      }),
    );
  }

  // MARK: - App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Product Details',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        // Edit Button
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E1E2F)),
          onPressed: controller.navigateToEdit,
        ),
        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: controller.showDeleteDialog,
        ),
      ],
    );
  }

  // MARK: - Main Content
  Widget _buildContent() {
    final product = controller.product.value!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images
          _buildImageGallery(product),
          const SizedBox(height: 20),
          
          // Product Name and SKU
          _buildTitleSection(product),
          const SizedBox(height: 16),
          
          // Stock Status Card
          _buildStockStatusCard(product),
          const SizedBox(height: 20),
          
          // Quick Actions with Navigation
          _buildQuickActions(),
          const SizedBox(height: 20),
          
          // Pricing Information
          _buildPricingSection(product),
          const SizedBox(height: 20),
          
          // Location Information
          _buildLocationSection(product),
          const SizedBox(height: 20),
          
          // Additional Information
          _buildInfoSection(product),
          const SizedBox(height: 20),
          
          // Stock Movement History
          _buildStockHistory(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // MARK: - Image Gallery
  Widget _buildImageGallery(ProductModel product) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: product.imageUrls.isNotEmpty
            ? PageView.builder(
                itemCount: product.imageUrls.length,
                onPageChanged: (index) => controller.changeImage(index),
                itemBuilder: (context, index) {
                  return Image.network(
                    product.imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
      ),
    );
  }

  // MARK: - Title Section
  Widget _buildTitleSection(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.sku}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (product.barcode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Barcode: ${product.barcode}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: controller.stockStatusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: controller.stockStatusColor.withOpacity(0.3)),
            ),
            child: Text(
              controller.stockStatusText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: controller.stockStatusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Stock Status Card
  Widget _buildStockStatusCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStockInfo(
                label: 'Current',
                value: '${product.currentStock}',
                icon: Icons.inventory_2_outlined,
                color: Colors.blue,
              ),
              _buildStockInfo(
                label: 'Minimum',
                value: '${product.minimumStock}',
                icon: Icons.trending_down,
                color: Colors.orange,
              ),
              _buildStockInfo(
                label: 'Maximum',
                value: '${product.maximumStock}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ],
          ),
          if (product.isLowStock) ...[
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Low stock alert! Only ${product.currentStock} units left. Minimum required is ${product.minimumStock}.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockInfo({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
      ],
    );
  }

  // MARK: - Quick Actions with Navigation
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Stock In',
            icon: Icons.arrow_downward,
            color: Colors.green,
            onTap: () {
              // Navigate to Stock In with product and source
              Get.toNamed(
                AppRoutes.stockIn,
                arguments: {
                  'product': controller.product.value,
                  'source': 'product_details'
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Stock Out',
            icon: Icons.arrow_upward,
            color: Colors.orange,
            onTap: () {
              // Navigate to Stock Out with product and source
              Get.toNamed(
                AppRoutes.stockOut,
                arguments: {
                  'product': controller.product.value,
                  'source': 'product_details'
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Print',
            icon: Icons.print_outlined,
            color: Colors.blue,
            onTap: controller.printBarcode,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Pricing Section
  Widget _buildPricingSection(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Information',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow('Cost Price', '\$${product.costPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildInfoRow('Selling Price', '\$${product.sellingPrice.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                controller.profitText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: controller.profitColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Location Section
  Widget _buildLocationSection(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E2F),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map_outlined, color: Colors.blue, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              product.location,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E2F),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Aisle • Rack • Bin',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Additional Information
  Widget _buildInfoSection(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Category', product.categoryName),
          if (product.supplierName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Supplier', product.supplierName!),
          ],
          const SizedBox(height: 8),
          _buildInfoRow('Added On', '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}'),
          if (product.expiryDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Expiry Date', controller.expiryText),
          ],
          if (product.description != null && product.description!.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E1E2F),
          ),
        ),
      ],
    );
  }

  // MARK: - Stock History
  Widget _buildStockHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stock Movement History',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E2F),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (controller.product.value != null) {
                    Get.toNamed(
                      AppRoutes.stockHistory,
                      arguments: {
                        'productId': controller.product.value!.id,
                        'productName': controller.product.value!.name,
                      },
                    );
                  }
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // History items with loading state
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (controller.stockHistory.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No stock movements yet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.stockHistory.length > 5 ? 5 : controller.stockHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final movement = controller.stockHistory[index];
                return _buildHistoryItem(movement);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> movement) {
    final isStockIn = movement['type'] == 'stock_in';
    final color = isStockIn ? Colors.green : Colors.orange;
    final quantity = movement['quantity'] as int? ?? 0;
    
    DateTime date;
    try {
      date = DateTime.parse(movement['createdAt'] ?? movement['date'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      date = DateTime.now();
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 16,
        ),
      ),
      title: Text(
        '$quantity units ${isStockIn ? 'added' : 'removed'}',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        movement['reason'] ?? movement['note'] ?? '',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${date.day}/${date.month}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (movement['createdBy'] != null)
            Text(
              movement['createdBy']['name'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  // MARK: - Error Widgets
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
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
          CustomButton(
            text: 'Try Again',
            onPressed: () => controller.loadProductData(controller.productId!),
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 45,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Product Not Found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The product you are looking for does not exist',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Go Back',
            onPressed: () => Get.back(),
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 45,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}