// lib/modules/admin/stock/views/today_stock_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_todays_stockhistory_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class TodayStockHistoryView extends GetView<TodayStockHistoryController> {
  const TodayStockHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSummaryBar(),
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading today\'s movements...');
              }
              
              if (controller.error.isNotEmpty) {
                return _buildErrorWidget();
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
        'Today\'s Movements',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => Column(
                children: [
                  Text(
                    'Stock In Today',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.totalStockIn}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => Column(
                children: [
                  Text(
                    'Stock Out Today',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.totalStockOut}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Stock In', 'in'),
          _buildFilterChip('Stock Out', 'out'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() => Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: controller.filterType.value == value
                    ? const Color(0xFF1E1E2F)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: controller.filterType.value == value
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: controller.filterType.value == value
                  ? const Color(0xFF1E1E2F)
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildMovementsList() {
    return RefreshIndicator(
      onRefresh: controller.refreshMovements,
      color: const Color(0xFF1E1E2F),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!controller.isLoadingMore.value &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
            controller.loadMore();
          }
          return true;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.movements.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.movements.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final movement = controller.movements[index];
            return _buildMovementCard(movement);
          },
        ),
      ),
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> movement) {
    final isStockIn = movement['type'] == 'stock_in';
    final color = isStockIn ? Colors.green : Colors.orange;
    final icon = isStockIn ? Icons.arrow_downward : Icons.arrow_upward;
    final quantity = movement['quantity'] as int? ?? 0;
    
    DateTime date;
    try {
      date = DateTime.parse(movement['createdAt'] ?? movement['date'] ?? '');
    } catch (e) {
      date = DateTime.now();
    }

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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
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
                    if (movement['reason'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movement['reason'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (movement['notes'] != null && movement['notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      movement['notes'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (movement['createdBy'] != null)
                Text(
                  movement['createdBy']['name'] ?? 'System',
                  style: GoogleFonts.inter(
                    fontSize: 11,
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
            'No movements today',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock in/out movements for today will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            'Error Loading Data',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            onPressed: controller.refreshMovements,
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