// lib/modules/admin/reports/views/reports_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';
import 'package:warehouse_management_app/widgets/report_card.dart';
import '../../../widgets/loading_widget.dart';

class ReportsDashboardView extends GetView<ReportsController> {
  const ReportsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading reports...');
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
        'Reports',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range, color: Color(0xFF1E1E2F)),
          onPressed: controller.selectDateRange,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Display
          Obx(() => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_formatDate(controller.startDate.value)} - ${_formatDate(controller.endDate.value)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )),
          const SizedBox(height: 20),

          // Summary Cards
          Text(
            'Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryCards(),
          const SizedBox(height: 24),

          // Report Categories
          Text(
            'Inventory Reports',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          _buildInventoryReports(),
          const SizedBox(height: 24),

          Text(
            'Financial Reports',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          _buildFinancialReports(),
          const SizedBox(height: 24),

          Text(
            'Movement Reports',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 12),
          _buildMovementReports(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Products',
            value: '${controller.totalProducts}',
            icon: Icons.inventory,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Value',
            value: '₹${controller.totalStockValue}',
            icon: Icons.currency_rupee,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Low Stock',
            value: '${controller.lowStockCount}',
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryReports() {
    return Column(
      children: [
        ReportCard(
          title: 'Stock Summary Report',
          subtitle: 'Current stock levels with values',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
          onTap: () => Get.toNamed(AppRoutes.stockSummaryReport),
        ),
        const SizedBox(height: 8),
        ReportCard(
          title: 'Low Stock Report',
          subtitle: 'Products below minimum level',
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
          onTap: () => Get.toNamed(AppRoutes.lowStockReport),
        ),
        const SizedBox(height: 8),
        ReportCard(
          title: 'Expiry Report',
          subtitle: 'Products expiring soon',
          icon: Icons.event_outlined,
          color: Colors.red,
          onTap: () => Get.toNamed(AppRoutes.expiryReport),
        ),
      ],
    );
  }

  Widget _buildFinancialReports() {
    return Column(
      children: [
        ReportCard(
          title: 'Profit & Loss Report',
          subtitle: 'Revenue, cost and parofit analysis',
          icon: Icons.trending_up,
          color: Colors.green,
          onTap: () => Get.snackbar('Info', 'Coming soon'),
        ),
        const SizedBox(height: 8),
        ReportCard(
          title: 'Category-wise Value',
          subtitle: 'Stock value by category',
          icon: Icons.pie_chart_outline,
          color: Colors.purple,
          onTap: () => Get.snackbar('Info', 'Coming soon'),
        ),
      ],
    );
  }

  Widget _buildMovementReports() {
    return Column(
      children: [
        ReportCard(
          title: 'Stock Movement Report',
          subtitle: 'All stock in/out transactions',
          icon: Icons.compare_arrows,
          color: Colors.teal,
          onTap: () => Get.toNamed(AppRoutes.stockHistory),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.day}/${date.month}/${date.year}';
  }
}