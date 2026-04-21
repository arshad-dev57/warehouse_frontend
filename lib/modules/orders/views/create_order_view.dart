import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/create_order_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/barcode_scanner_widget.dart'; // Import scanner

class CreateOrderView extends GetView<CreateOrderController> {
  const CreateOrderView({super.key});

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
        'Create Order',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        // Recent orders button
        IconButton(
          icon: const Icon(Icons.history, color: Color(0xFF1E1E2F)),
          onPressed: () => Get.toNamed('/orders'),
        ),
      ],
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
            // Customer Section
            _buildSectionTitle('Customer Information'),
            const SizedBox(height: 12),
            
            _buildTextField(
              'Customer Name',
              controller.customerNameController,
              hint: 'Enter customer name (optional)',
            ),
            const SizedBox(height: 12),
            
            _buildTextField(
              'Phone Number',
              controller.customerPhoneController,
              hint: 'Enter phone number (optional)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            
            _buildTextField(
              'Address',
              controller.customerAddressController,
              hint: 'Enter delivery address (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Order Items Section
            _buildSectionTitle('Order Items'),
            const SizedBox(height: 12),
            
            // Action Buttons Row - SCAN & ADD
            Row(
              children: [
                // SCAN BARCODE BUTTON (Primary)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showBarcodeScanner,
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    label: Text(
                      'Scan Barcode',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // ADD PRODUCT BUTTON (Secondary - Manual)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Info Bar (Shows when scanning)
            Obx(() {
              if (controller.isScanning.value) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Items List
            Obx(() {
              if (controller.items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No items added',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan barcode or add product manually',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return _buildItemTile(item, index);
                },
              );
            }),
            const SizedBox(height: 24),

            // Order Summary
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '\$${controller.subtotal.value.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Discount', '- \$${controller.discount.value.toStringAsFixed(0)}'),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Total',
                    '\$${controller.total.value.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Discount Field
            TextFormField(
              controller: controller.discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Discount (Optional)',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => controller.calculateTotal(),
            ),
            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle('Additional Notes'),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: controller.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any notes about the order...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            Obx(() => CustomButton(
              text: 'Create Order',
              onPressed: controller.isSubmitting.value ? null : controller.createOrder,
              isLoading: controller.isSubmitting.value,
              backgroundColor: const Color(0xFF1E1E2F),
              textColor: Colors.white,
              height: 50,
              borderRadius: 12,
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Show barcode scanner
  // Show barcode scanner - FIXED VERSION
void _showBarcodeScanner() async {
  print("📱 Opening barcode scanner...");
  
  // Scanner screen se result await karo
  final scannedBarcode = await Get.to(
    () => const BarcodeScannerScreen(),
    fullscreenDialog: true,
  );
  
  // Scanner screen band hone ke baad result handle karo
  if (scannedBarcode != null && scannedBarcode is String) {
    print("✅ Barcode received: $scannedBarcode");
    controller.searchProductByBarcode(scannedBarcode);
  } else {
    print("📱 Scanner closed without barcode");
  }
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E1E2F),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item['quantity']}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item['sku'] != null)
                  Text(
                    'SKU: ${item['sku']}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                Text(
                  '\$${item['price']} x ${item['quantity']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            onPressed: () => controller.removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
            color: isTotal ? const Color(0xFF1E1E2F) : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w700,
            color: isTotal ? Colors.green : const Color(0xFF1E1E2F),
          ),
        ),
      ],
    );
  }
}