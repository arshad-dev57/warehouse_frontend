// lib/modules/admin/orders/views/order_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/data/models/order_model.dart';
import 'package:warehouse_management_app/modules/orders/controllers/order_detail_controller.dart';
import 'package:warehouse_management_app/widgets/order_status_chip.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading order details...');
        }
        
        if (controller.error.isNotEmpty) {
          return _buildErrorWidget();
        }
        
        if (controller.order.value == null) {
          return _buildNotFoundWidget();
        }
        
        return _buildContent();
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
        'Order Details',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        if (controller.order.value?.status != OrderStatus.completed && 
            controller.order.value?.status != OrderStatus.cancelled)
          PopupMenuButton<OrderStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: controller.updateOrderStatus,
            itemBuilder: (context) => [
              if (controller.order.value?.status == OrderStatus.pending)
                const PopupMenuItem(
                  value: OrderStatus.processing,
                  child: Text('Mark as Processing'),
                ),
              if (controller.order.value?.status == OrderStatus.processing)
                const PopupMenuItem(
                  value: OrderStatus.completed,
                  child: Text('Mark as Completed'),
                ),
              const PopupMenuItem(
                value: OrderStatus.cancelled,
                child: Text('Cancel Order'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildContent() {
    final order = controller.order.value!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Order Header Card
          _buildOrderHeader(order),
          const SizedBox(height: 16),

          // Customer Info Card
          if (order.customerName != null)
            _buildCustomerInfo(order),
          if (order.customerName != null) const SizedBox(height: 16),

          // Items Card
          _buildItemsCard(order),
          const SizedBox(height: 16),

          // Summary Card
          _buildSummaryCard(order),
          const SizedBox(height: 16),

          // Notes Card
          if (order.notes != null)
            _buildNotesCard(order),
          if (order.notes != null) const SizedBox(height: 16),

          // Action Buttons
          if (order.status == OrderStatus.pending)
            _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(OrderModel order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_outline, color: Colors.blue.shade700, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Name', order.customerName ?? ''),
            if (order.customerPhone != null)
              _buildInfoRow(Icons.phone, 'Phone', order.customerPhone!),
            if (order.customerAddress != null)
              _buildInfoRow(Icons.location_on, 'Address', order.customerAddress!),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.green.shade700, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _buildItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
                  item.productName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'SKU: ${item.productSku}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(OrderModel order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            if (order.discount > 0)
              _buildSummaryRow('Discount', '- \$${order.discount.toStringAsFixed(0)}'),
            if (order.discount > 0) const SizedBox(height: 8),
            const Divider(),
            _buildSummaryRow(
              'Total',
              '\$${order.total.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(OrderModel order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.note_outlined, color: Colors.orange.shade700, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.notes!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Process Order',
            onPressed: () => controller.updateOrderStatus(OrderStatus.completed),
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            height: 50,
            borderRadius: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: () => controller.updateOrderStatus(OrderStatus.cancelled),
            backgroundColor: Colors.red.shade100,
            textColor: Colors.red.shade700,
            height: 50,
            borderRadius: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: isTotal ? Colors.green : const Color(0xFF1E1E2F),
          ),
        ),
      ],
    );
  }

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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            onPressed: controller.loadOrderDetails,
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
          Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Order Not Found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The order you are looking for does not exist',
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