// lib/modules/admin/products/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_list_controller.dart';

class FilterBottomSheet extends GetView<ProductListController> {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Products',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                TextButton(
                  onPressed: controller.clearFilters,
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.grey.shade200, height: 1),
          
          // Category Filter
          _buildSection(
            title: 'Category',
            child: Obx(() {
              if (controller.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'All',
                    isSelected: controller.selectedCategory.value == null,
                    onTap: () => controller.selectedCategory.value = null,
                  ),
                  ...controller.categories.map((category) {
                    return _buildFilterChip(
                      label: category.name,
                      isSelected: controller.selectedCategory.value?.id == category.id,
                      onTap: () => controller.selectedCategory.value = category,
                    );
                  }),
                ],
              );
            }),
          ),
          
          // Stock Status Filter
          _buildSection(
            title: 'Stock Status',
            child: Obx(() {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.stockStatusOptions.map((option) {
                  final value = option['value'] as String;
                  final label = option['label'] as String;
                  
                  return _buildFilterChip(
                    label: label,
                    isSelected: controller.selectedStockStatus.value == value,
                    onTap: () {
                      if (controller.selectedStockStatus.value == value) {
                        controller.selectedStockStatus.value = null;
                      } else {
                        controller.selectedStockStatus.value = value;
                      }
                    },
                  );
                }).toList(),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}