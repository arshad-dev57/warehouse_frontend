// lib/modules/admin/reports/views/expiry_report_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/data/models/product_model.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class ExpiryReportView extends GetView<ReportsController> {
  const ExpiryReportView({super.key});

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
        'Expiry Report',
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
      ],
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF1E1E2F),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF1E1E2F),
              tabs: const [
                Tab(text: 'Expiring Soon'),
                Tab(text: 'Expired'),
                Tab(text: 'All'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildExpiringSoonList(),
                _buildExpiredList(),
                _buildAllExpiryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonList() {
    return Obx(() {
      if (controller.expiringSoonProducts.isEmpty) {
        return _buildEmptyState('No products expiring soon');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.expiringSoonProducts.length,
        itemBuilder: (context, index) {
          final product = controller.expiringSoonProducts[index];
          return _buildExpiryCard(product, isExpiring: true);
        },
      );
    });
  }

  Widget _buildExpiredList() {
    return Obx(() {
      if (controller.expiredProducts.isEmpty) {
        return _buildEmptyState('No expired products');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.expiredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.expiredProducts[index];
          return _buildExpiryCard(product, isExpired: true);
        },
      );
    });
  }

  Widget _buildAllExpiryList() {
    return Obx(() {
      if (controller.productsWithExpiry.isEmpty) {
        return _buildEmptyState('No products with expiry dates');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.productsWithExpiry.length,
        itemBuilder: (context, index) {
          final product = controller.productsWithExpiry[index];
          return _buildExpiryCard(product);
        },
      );
    });
  }

  Widget _buildExpiryCard(ProductModel product, {bool isExpiring = false, bool isExpired = false}) {
    Color color = Colors.green;
    String status = 'Good';
    
    if (isExpired) {
      color = Colors.red;
      status = 'Expired';
    } else if (isExpiring) {
      color = Colors.orange;
      status = 'Expiring Soon';
    }

    final daysLeft = product.expiryDate!.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$daysLeft',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
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
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Stock: ${product.currentStock} units',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}',
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}