// lib/modules/admin/products/views/add_product_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/data/models/category_model.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_add_product_controller.dart';
import 'package:warehouse_management_app/widgets/image_picker_widget.dart';
import 'package:warehouse_management_app/widgets/location_selector_widget.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/loading_widget.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading product data...');
        }
        return _buildForm(context);
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
        onPressed: controller.cancel,
      ),
      title: Text(
        controller.isEditing.value ? 'Edit Product' : 'Add Product',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        // Save Button in AppBar
        TextButton(
          onPressed: controller.saveProduct,
          child: Text(
            'Save',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Main Form
  Widget _buildForm(BuildContext context){
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Section
            const Text(
              'Product Images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ImagePickerWidget(
              images: controller.images,
              onPickImage: controller.pickImage,
              onRemoveImage: controller.removeImage,
            ),
            const SizedBox(height: 20),

            // Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Product Name
            _buildLabel('Product Name *'),
            const SizedBox(height: 4),
            TextFormField(
              controller: controller.nameController,
              validator: controller.validateName,
              decoration: InputDecoration(
                hintText: 'Enter product name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SKU and Barcode Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('SKU *'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.skuController,
                        validator: controller.validateSku,
                        decoration: InputDecoration(
                          hintText: 'SKU-001',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Barcode'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.barcodeController,
                              decoration: InputDecoration(
                                hintText: 'Scan or generate',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (value) {
                                if (value == 'scan') {
                                  controller.scanBarcode();
                                } else if (value == 'generate') {
                                  controller.generateBarcode();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'scan',
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code_scanner, size: 18),
                                      SizedBox(width: 8),
                                      Text('Scan Barcode'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'generate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code, size: 18),
                                      SizedBox(width: 8),
                                      Text('Generate Barcode'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category and Supplier
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category *'),
                      const SizedBox(height: 4),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<CategoryModel>(
                          value: controller.selectedCategory.value,
                          hint: const Text('Select Category'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: controller.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: controller.selectCategory,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Supplier'),
                      const SizedBox(height: 4),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          value: controller.selectedSupplier.value,
                          hint: const Text('Select Supplier'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: controller.suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier,
                              child: Text(supplier['name']),
                            );
                          }).toList(),
                          onChanged: controller.selectSupplier,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pricing Section
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Cost and Selling Price Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Cost Price *'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.costPriceController,
                        validator: controller.validatePrice,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Selling Price *'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.sellingPriceController,
                        validator: controller.validatePrice,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock Section
            const Text(
              'Stock Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Current Stock
            _buildLabel('Current Stock *'),
            const SizedBox(height: 4),
            TextFormField(
              controller: controller.currentStockController,
              validator: controller.validateStock,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Min and Max Stock Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Min Stock *'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.minimumStockController,
                        validator: controller.validateStock,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Max Stock *'),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.maximumStockController,
                        validator: controller.validateStock,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '100',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location Section
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Location Selector
            LocationSelector(
              aisles: controller.aisles,
              racks: controller.racks,
              bins: controller.bins,
              selectedAisle: controller.selectedAisle,
              selectedRack: controller.selectedRack,
              selectedBin: controller.selectedBin,
            ),
            const SizedBox(height: 8),

            // Location Preview
        Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Location: ${controller.locationController.text}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date
            _buildLabel('Expiry Date (Optional)'),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) {
                  controller.selectExpiryDate(date);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.expiryDate.value != null
                          ? '${controller.expiryDate.value!.day}/${controller.expiryDate.value!.month}/${controller.expiryDate.value!.year}'
                          : 'Select expiry date',
                      style: TextStyle(
                        color: controller.expiryDate.value != null
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                )),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            _buildLabel('Description (Optional)'),
            const SizedBox(height: 4),
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter product description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Save and Cancel Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: controller.cancel,
                    backgroundColor: Colors.grey.shade200,
                    textColor: const Color(0xFF1E1E2F),
                    height: 45,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: controller.isEditing.value ? 'Update' : 'Save',
                    onPressed: controller.saveProduct,
                    backgroundColor: const Color(0xFF1E1E2F),
                    textColor: Colors.white,
                    height: 45,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method for labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }
}