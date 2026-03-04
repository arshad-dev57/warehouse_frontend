// lib/modules/admin/stock/views/stock_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stock_history_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class StockHistoryView extends GetView<StockHistoryController> {
  const StockHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading history...');
              }
              
              if (controller.movements.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildMovementsList();
            }),
          ),
        ],
      ),
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
        'Stock History',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF1E1E2F)),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              String filterText = 'All Movements';
              if (controller.selectedType.value != 'all') {
                filterText = controller.selectedType.value == 'stock_in' 
                    ? 'Stock In' 
                    : 'Stock Out';
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      filterText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'This Month',
                  style: GoogleFonts.inter(
                    fontSize: 13,
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

  Widget _buildMovementsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.movements.length,
      itemBuilder: (context, index) {
        final movement = controller.movements[index];
        return _buildMovementCard(movement);
      },
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> movement) {
    final isStockIn = movement['type'] == 'stock_in';
    final color = isStockIn ? Colors.green : Colors.orange;
    final icon = isStockIn ? Icons.arrow_downward : Icons.arrow_upward;
    final quantity = movement['quantity'] as int;
    final date = DateTime.parse(movement['date'] ?? DateTime.now().toIso8601String());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement['productName'] ?? 'Unknown Product',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$quantity units',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (movement['reference'] != null && movement['reference'].isNotEmpty)
                      Text(
                        movement['reference'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${date.day}/${date.month}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Stock Movements',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock in/out movements will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Go to Stock In',
            onPressed: () => Get.toNamed('/admin/stock/in'),
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 45,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Movements',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Column(
              children: [
                _buildFilterOption('All', 'all', controller.selectedType.value),
                _buildFilterOption('Stock In', 'stock_in', controller.selectedType.value),
                _buildFilterOption('Stock Out', 'stock_out', controller.selectedType.value),
              ],
            )),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Apply Filter',
              onPressed: () => Get.back(),
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

  Widget _buildFilterOption(String label, String value, String selected) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: selected,
      onChanged: (val) {
        if (val != null) {
          controller.selectedType.value = val;
          controller.loadMovements();
        }
      },
      activeColor: const Color(0xFF1E1E2F),
    );
  }
}