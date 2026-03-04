// lib/modules/admin/reports/views/stock_summary_report_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class StockSummaryReportView extends GetView<ReportsController> {
  const StockSummaryReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Generating report...');
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
        'Stock Summary Report',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: controller.exportAsPDF,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Color(0xFF1E1E2F)),
          onPressed: controller.shareReport,
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
          // Report Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Date',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.getCurrentDate(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.totalProducts} Products',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overall Summary
          Text(
            'Overall Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryTable(),
          const SizedBox(height: 24),

          // Category-wise Summary
          Text(
            'Category-wise Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryTable(),
          const SizedBox(height: 24),

          // Export Button
          CustomButton(
            text: 'Download PDF Report',
            onPressed: controller.exportAsPDF,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            height: 50,
            borderRadius: 12,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Products', '${controller.totalProducts}'),
          const Divider(),
          _buildSummaryRow('Total Stock Value', '₹${controller.totalStockValue}'),
          const Divider(),
          _buildSummaryRow('Average Price per Item', '₹${controller.averagePrice}'),
          const Divider(),
          _buildSummaryRow('Low Stock Items', '${controller.lowStockCount}', isWarning: true),
          const Divider(),
          _buildSummaryRow('Out of Stock', '${controller.outOfStockCount}', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isWarning ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTable() {
    return Obx(() {
      if (controller.categorySummary.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.categorySummary.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final category = controller.categorySummary[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    category['name'],
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${category['count']} items',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '₹${category['value']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}