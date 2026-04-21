// lib/modules/admin/stock/views/stock_in_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stock_in_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class StockInView extends GetView<StockInController> {
  const StockInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading...');
        }
        return _buildForm();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Stock In',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Selection
            _buildLabel('Select Product *'),
            const SizedBox(height: 8),
            _buildProductSelector(),
            const SizedBox(height: 20),

            // Selected Product Info (if product selected)
            if (controller.selectedProduct.value != null) ...[
              _buildSelectedProductCard(),
              const SizedBox(height: 20),
            ],

            // Quantity
            _buildLabel('Quantity *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.quantityController,
              keyboardType: TextInputType.number,
              validator: controller.validateQuantity,
              enabled: !controller.isSubmitting.value,
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Supplier
            _buildLabel('Supplier'),
            const SizedBox(height: 8),
            _buildSupplierDropdown(),
            const SizedBox(height: 20),

            // Reference / Purchase Order
            _buildLabel('Reference / PO Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.referenceController,
              enabled: !controller.isSubmitting.value,
              decoration: InputDecoration(
                hintText: 'e.g., PO-2025-001',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date
            _buildLabel('Date'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 20),

            // Notes
            _buildLabel('Notes'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.notesController,
              maxLines: 3,
              enabled: !controller.isSubmitting.value,
              decoration: InputDecoration(
                hintText: 'Add any notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Add Stock',
              onPressed: controller.isSubmitting.value ? null : controller.submitStockIn,
              isLoading: controller.isSubmitting.value,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              height: 50,
              borderRadius: 12,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E1E2F),
      ),
    );
  }

  Widget _buildProductSelector() {
    return GestureDetector(
      onTap: controller.selectProduct,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: controller.selectedProduct.value == null
                ? Colors.red.shade300
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: controller.isProductFromDetails.value 
              ? Colors.green.shade50 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              controller.isProductFromDetails.value 
                  ? Icons.check_circle 
                  : Icons.search,
              color: controller.isProductFromDetails.value 
                  ? Colors.green 
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.selectedProduct.value != null
                    ? controller.selectedProduct.value!.name
                    : 'Search or scan product',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: controller.selectedProduct.value != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
            if (!controller.isProductFromDetails.value) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.qr_code_scanner, color: Colors.blue.shade700, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductCard() {
    final product = controller.selectedProduct.value!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isProductFromDetails.value 
            ? Colors.green.shade50 
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.isProductFromDetails.value 
              ? Colors.green.shade200 
              : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined, 
                color: controller.isProductFromDetails.value 
                    ? Colors.green.shade700 
                    : Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                Text(
                  'SKU: ${product.sku} | Current Stock: ${product.currentStock}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (controller.isProductFromDetails.value)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '✓ Product from details',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!controller.isProductFromDetails.value)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: controller.clearSelectedProduct,
            ),
        ],
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        if (controller.isLoadingSuppliers.value) {
          return const SizedBox(
            height: 50,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        
        return DropdownButton<String>(
          value: controller.selectedSupplier.value,
          hint: const Text('Select supplier'),
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None'),
            ),
            ...controller.suppliers.map<DropdownMenuItem<String>>((supplier) {
              return DropdownMenuItem<String>(
                value: supplier['id'].toString(),
                child: Text(supplier['name'].toString()),
              );
            }).toList(),
          ],
          onChanged: controller.isSubmitting.value ? null : controller.selectSupplier,
        );
      }),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: controller.isSubmitting.value ? null : controller.selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.selectedDate.value != null
                  ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                  : 'Select date',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: controller.selectedDate.value != null
                    ? Colors.black
                    : Colors.grey.shade600,
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}