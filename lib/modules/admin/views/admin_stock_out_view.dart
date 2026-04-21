// lib/modules/admin/stock/views/stock_out_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stcok_out_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class StockOutView extends GetView<StockOutController> {
  const StockOutView({super.key});

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
        'Stock Out',
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

            // Selected Product Info
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

            // Reason
            _buildLabel('Reason *'),
            const SizedBox(height: 8),
            _buildReasonDropdown(),
            const SizedBox(height: 20),

            // Reference
            _buildLabel('Reference / Order #'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.referenceController,
              enabled: !controller.isSubmitting.value,
              decoration: InputDecoration(
                hintText: 'e.g., Order #123',
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
              text: 'Remove Stock',
              onPressed: controller.isSubmitting.value ? null : controller.submitStockOut,
              isLoading: controller.isSubmitting.value,
              backgroundColor: Colors.orange,
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.qr_code_scanner, color: Colors.orange.shade700, size: 20),
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
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.isProductFromDetails.value 
              ? Colors.green.shade200 
              : Colors.orange.shade200,
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
                    : Colors.orange.shade700,
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
                  'SKU: ${product.sku} | Available: ${product.currentStock}',
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

  Widget _buildReasonDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedReason.value,
        hint: const Text('Select reason'),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: controller.reasons.map<DropdownMenuItem<String>>((reason) {
          return DropdownMenuItem<String>(
            value: reason['id'].toString(),
            child: Text(reason['name'].toString()),
          );
        }).toList(),
        onChanged: controller.isSubmitting.value ? null : controller.selectReason,
      )),
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