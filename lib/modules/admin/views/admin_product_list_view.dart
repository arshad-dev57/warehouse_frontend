// lib/modules/admin/products/views/product_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_list_controller.dart';
import 'package:warehouse_management_app/widgets/custom_button.dart';
import 'package:warehouse_management_app/widgets/filter_bottom_sheet.dart';
import 'package:warehouse_management_app/widgets/product_card.dart';
import 'package:warehouse_management_app/widgets/product_list_item.dart';

import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/error_widget.dart';

class ProductListView extends GetView<ProductListController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading products...');
              }
              
              if (controller.error.isNotEmpty) {
                return errorWidget(
                  message: controller.error.value,
                  onRetry: controller.refreshData,
                );
              }

              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }

              return _buildProductList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToAddProduct,
        backgroundColor: const Color(0xFF1E1E2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // MARK: - App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Products',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      actions: [
        // View toggle
        Obx(() => IconButton(
          onPressed: controller.toggleViewMode,
          icon: Icon(
            controller.isGridView.value
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            color: const Color(0xFF1E1E2F),
          ),
        )),
        
        // Filter button
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: Obx(() => Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.filter_list_rounded, color: Color(0xFF1E1E2F)),
              if (controller.selectedCategory.value != null || 
                  controller.selectedStockStatus.value != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  // MARK: - Search Bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.searchQuery.value = '';
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                        )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Sort button
          Obx(() => _buildSortButton()),
        ],
      ),
    );
  }

  // MARK: - Sort Button
  Widget _buildSortButton() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'toggle_order') {
            controller.toggleSortOrder();
          } else {
            controller.setSortBy(value);
          }
        },
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                _getSortIcon(),
                size: 18,
                color: const Color(0xFF1E1E2F),
              ),
              const SizedBox(width: 4),
              Icon(
                controller.sortAscending.value
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'name',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha_rounded,
                    size: 18,
                    color: controller.sortBy.value == 'name'
                        ? Colors.blue
                        : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Name',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: controller.sortBy.value == 'name'
                        ? Colors.blue
                        : Colors.grey.shade700,
                    fontWeight: controller.sortBy.value == 'name'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'price',
            child: Row(
              children: [
                Icon(Icons.attach_money_rounded,
                    size: 18,
                    color: controller.sortBy.value == 'price'
                        ? Colors.blue
                        : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Price',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: controller.sortBy.value == 'price'
                        ? Colors.blue
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'stock',
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 18,
                    color: controller.sortBy.value == 'stock'
                        ? Colors.blue
                        : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Stock',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: controller.sortBy.value == 'stock'
                        ? Colors.blue
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'date',
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 18,
                    color: controller.sortBy.value == 'date'
                        ? Colors.blue
                        : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Date Added',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: controller.sortBy.value == 'date'
                        ? Colors.blue
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'toggle_order',
            child: Row(
              children: [
                Icon(
                  controller.sortAscending.value
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.sortAscending.value
                      ? 'Ascending'
                      : 'Descending',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon() {
    switch (controller.sortBy.value) {
      case 'name':
        return Icons.sort_by_alpha_rounded;
      case 'price':
        return Icons.attach_money_rounded;
      case 'stock':
        return Icons.inventory_2_outlined;
      case 'date':
        return Icons.access_time_rounded;
      default:
        return Icons.sort_rounded;
    }
  }

  // MARK: - Filter Chips
  Widget _buildFilterChips() {
    return Obx(() {
      if (controller.selectedCategory.value == null &&
          controller.selectedStockStatus.value == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (controller.selectedCategory.value != null)
                _buildFilterChip(
                  label: controller.selectedCategory.value!.name,
                  onDelete: () => controller.selectedCategory.value = null,
                ),
              if (controller.selectedStockStatus.value != null)
                _buildFilterChip(
                  label: _getStockStatusLabel(controller.selectedStockStatus.value!),
                  onDelete: () => controller.selectedStockStatus.value = null,
                ),
              _buildFilterChip(
                label: 'Clear All',
                isClear: true,
                onDelete: controller.clearFilters,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    VoidCallback? onDelete,
    bool isClear = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isClear ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isClear ? Colors.grey.shade300 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isClear ? Colors.grey.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: isClear ? Colors.grey.shade600 : Colors.blue.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStockStatusLabel(String value) {
    final option = controller.stockStatusOptions.firstWhere(
      (o) => o['value'] == value,
      orElse: () => {'label': value},
    );
    return option['label'] as String;
  }

  // MARK: - Product List
  Widget _buildProductList() {
    return Obx(() {
      if (controller.isGridView.value) {
        return _buildGridView();
      } else {
        return _buildListView();
      }
    });
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => controller.navigateToProductDetails(product.id),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return ProductListItem(
          product: product,
          onTap: () => controller.navigateToProductDetails(product.id),
        );
      },
    );
  }

  // MARK: - Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No products match your search'
                : 'Get started by adding your first product',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty)
            CustomButton(
              text: 'Clear Search',
              onPressed: () => controller.searchQuery.value = '',
              backgroundColor: Colors.grey.shade200,
              textColor: const Color(0xFF1E1E2F),
              height: 45,
              borderRadius: 8,
            )
          else
            CustomButton(
              text: 'Add Product',
              onPressed: controller.navigateToAddProduct,
              backgroundColor: const Color(0xFF1E1E2F),
              textColor: Colors.white,
              height: 45,
              borderRadius: 8,
            ),
        ],
      ),
    );
  }

  // MARK: - Filter Bottom Sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}