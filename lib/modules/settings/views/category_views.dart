// lib/modules/admin/settings/views/categories_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/data/models/category_model.dart';
import '../controllers/categories_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/custom_button.dart'; // Add this import

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Categories',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2B3C), Color(0xFF2C3E50)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: controller.showAddCategoryDialog,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading categories...');
        }
        
        if (controller.error.isNotEmpty) {
          return errorWidget(
            message: controller.error.value,
            onRetry: controller.loadCategories,
          );
        }
        
        if (controller.categories.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadCategories,
          color: const Color(0xFF1E1E2F),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _buildCategoryCard(category);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with gradient background
        
          const SizedBox(width: 16),

          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1E2F),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.productCount} products',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (category.description != null && category.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.description!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue.shade700),
                  onPressed: () => controller.showEditCategoryDialog(category),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                  onPressed: () => controller.deleteCategory(category.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Enhanced Add Category Dialog
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedColor = 'blue'.obs;
    final selectedIcon = 'inventory'.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E2B3C), Color(0xFF2C3E50)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.category_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Category',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E1E2F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a new product category',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Name Field
                  Text(
                    'Category Name',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category name is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter category name',
                      prefixIcon: const Icon(Icons.category_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  Text(
                    'Description',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter category description (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color Selection
                  Text(
                    'Color',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E2F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption('blue', selectedColor),
                      _buildColorOption('green', selectedColor),
                      _buildColorOption('orange', selectedColor),
                      _buildColorOption('purple', selectedColor),
                      _buildColorOption('red', selectedColor),
                      _buildColorOption('pink', selectedColor),
                      _buildColorOption('teal', selectedColor),
                      _buildColorOption('amber', selectedColor),
                    ],
                  )),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: () => Get.back(),
                          backgroundColor: Colors.grey.shade200,
                          textColor: Colors.grey.shade700,
                          height: 45,
                          borderRadius: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => CustomButton(
                          text: 'Create Category',
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    Get.back();
                                    await controller.addCategory(
                                      name: nameController.text,
                                      description: descriptionController.text,
                                    );
                                  }
                                },
                          isLoading: controller.isSubmitting.value,
                          backgroundColor: const Color(0xFF1E2B3C),
                          textColor: Colors.white,
                          height: 45,
                          borderRadius: 12,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for color selection
  Widget _buildColorOption(String colorName, RxString selectedColor) {
    Color color;
    switch (colorName) {
      case 'blue': color = Colors.blue; break;
      case 'green': color = Colors.green; break;
      case 'orange': color = Colors.orange; break;
      case 'purple': color = Colors.purple; break;
      case 'red': color = Colors.red; break;
      case 'pink': color = Colors.pink; break;
      case 'teal': color = Colors.teal; break;
      case 'amber': color = Colors.amber; break;
      default: color = Colors.grey;
    }

    return GestureDetector(
      onTap: () => selectedColor.value = colorName,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor.value == colorName 
                ? Colors.black 
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: selectedColor.value == colorName
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: selectedColor.value == colorName
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Categories Found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get started by creating your first category',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Category',
            onPressed: _showAddCategoryDialog,
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 45,
            borderRadius: 12,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}