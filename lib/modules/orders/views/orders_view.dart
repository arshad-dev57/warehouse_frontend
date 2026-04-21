// lib/modules/admin/orders/views/orders_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/data/models/order_model.dart';
import 'package:warehouse_management_app/widgets/custom_button.dart';
import 'package:warehouse_management_app/widgets/orders_card.dart';
import '../controllers/orders_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusTabs(),
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading orders...');
              }
              
              if (controller.error.isNotEmpty) {
                return errorWidget(
                  message: controller.error.value,
                  onRetry: controller.refreshOrders,
                );
              }

              if (controller.filteredOrders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                color: const Color(0xFF1E1E2F),
                child: _buildOrdersList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToCreateOrder,
        backgroundColor: const Color(0xFF1E1E2F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Orders',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(() => Row(
          children: controller.tabs.map((tab) {
            final status = tab['status'] as OrderStatus?;
            final isSelected = controller.selectedStatus.value == status;
            
            return GestureDetector(
              onTap: () => controller.setStatusFilter(status),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF1E1E2F)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected 
                      ? null
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    if (tab['status'] != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.3)
                              : status?.color ?? Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCountForStatus(tab['status'] as OrderStatus).toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  int _getCountForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return controller.pendingCount;
      case OrderStatus.processing:
        return controller.processingCount;
      case OrderStatus.completed:
        return controller.completedCount;
      case OrderStatus.cancelled:
        return controller.cancelledCount;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search by order number or customer...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = controller.filteredOrders[index];
        return OrderCard(
          order: order,
          onTap: () => controller.navigateToOrderDetails(order.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E1E2F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No orders match your search'
                  : 'Create your first order',
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
                onPressed: () {
                  controller.searchQuery.value = '';
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                backgroundColor: Colors.grey.shade200,
                textColor: const Color(0xFF1E1E2F),
                height: 45,
                borderRadius: 8,
              )
            else
              CustomButton(
                text: 'Create Order',
                onPressed: controller.navigateToCreateOrder,
                backgroundColor: const Color(0xFF1E1E2F),
                textColor: Colors.white,
                height: 45,
                borderRadius: 8,
              ),
          ],
        ),
      ),
    );
  }
}