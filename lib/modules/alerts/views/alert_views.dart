// lib/modules/admin/alerts/views/alerts_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/widgets/alert_tile.dart';
import '../controllers/alerts_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading alerts...');
              }
              
              if (controller.alerts.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildAlertsList();
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
        'Alerts & Notifications',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        if (controller.unreadCount > 0)
          TextButton(
            onPressed: controller.markAllAsRead,
            child: Text(
              'Mark all read',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'value': 'all', 'label': 'All', 'icon': Icons.notifications},
      {'value': 'unread', 'label': 'Unread', 'icon': Icons.mark_unread_chat_alt},
      {'value': 'low_stock', 'label': 'Low Stock', 'icon': Icons.inventory},
      {'value': 'expiry', 'label': 'Expiry', 'icon': Icons.event},
      {'value': 'damage', 'label': 'Damage', 'icon': Icons.error},
    ];

    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = controller.filterType.value == filter['value'];
          
          return GestureDetector(
            onTap: () => controller.setFilter(filter['value'] as String),
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
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsList() {
    return RefreshIndicator(
      onRefresh: controller.refreshAlerts,
      color: const Color(0xFF1E1E2F),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.alerts.length,
        itemBuilder: (context, index) {
          final alert = controller.alerts[index];
          return AlertTile(
            alert: alert,
            onTap: () => controller.onAlertTap(alert),
            onDismiss: () => controller.dismissAlert(alert.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'No alerts found';
    IconData icon = Icons.notifications_off_outlined;
    
    switch(controller.filterType.value) {
      case 'unread':
        message = 'No unread alerts';
        break;
      case 'low_stock':
        message = 'No low stock alerts';
        icon = Icons.inventory_outlined;
        break;
      case 'expiry':
        message = 'No expiry alerts';
        icon = Icons.event_outlined;
        break;
      case 'damage':
        message = 'No damage reports';
        icon = Icons.error_outline;
        break;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Clear Filter',
            onPressed: () => controller.setFilter('all'),
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 40,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}