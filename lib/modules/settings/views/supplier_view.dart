// lib/modules/admin/settings/views/suppliers_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/settings/controllers/supplier_controller.dart';
import 'package:warehouse_management_app/widgets/error_widget.dart';
import '../../../widgets/loading_widget.dart';

class SuppliersView extends GetView<SuppliersController> {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Suppliers',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1E1E2F)),
            onPressed: controller.showAddSupplierDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading suppliers...');
        }
        
        if (controller.error.isNotEmpty) {
          return errorWidget(
            message: controller.error.value,
            onRetry: controller.refreshSuppliers,
          );
        }
        
        if (controller.suppliers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSuppliers,
          color: const Color(0xFF1E1E2F),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = controller.suppliers[index];
              return _buildSupplierCard(supplier);
            },
          ),
        );
      }),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> supplier) {
    final isActive = supplier['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Supplier Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        supplier['name'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        supplier['status'],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (supplier['contactPerson'] != null && supplier['contactPerson'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Contact: ${supplier['contactPerson']}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (supplier['phone'] != null && supplier['phone'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supplier['phone'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (supplier['email'] != null && supplier['email'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supplier['email'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle') {
                controller.toggleSupplierStatus(supplier['id']);
              } else if (value == 'delete') {
                controller.deleteSupplier(supplier['id']);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      supplier['status'] == 'active' ? Icons.block : Icons.check_circle,
                      size: 18,
                      color: supplier['status'] == 'active' ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(supplier['status'] == 'active' ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Delete'),
                  ],
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
          Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Suppliers',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first supplier',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.showAddSupplierDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Supplier'),
          ),
        ],
      ),
    );
  }
}