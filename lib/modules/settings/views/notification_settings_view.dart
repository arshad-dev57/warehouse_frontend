// lib/modules/admin/settings/views/notification_settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/settings/controllers/notification_controller.dart';
import '../../../widgets/custom_button.dart';

class NotificationSettingsView extends GetView<NotificationSettingsController> {
  const NotificationSettingsView({super.key});

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
          'Notification Settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.saveSettings,
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E1E2F),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Email Notifications
          _buildSection('Email Notifications', [
            _buildSwitchTile(
              'Low Stock Alerts',
              'Get notified when products are low',
              controller.emailLowStock.value,
              (value) => controller.emailLowStock.value = value,
            ),
            _buildSwitchTile(
              'Expiry Alerts',
              'Get notified about expiring products',
              controller.emailExpiry.value,
              (value) => controller.emailExpiry.value = value,
            ),
            _buildSwitchTile(
              'Daily Summary',
              'Receive daily stock summary',
              controller.emailDailySummary.value,
              (value) => controller.emailDailySummary.value = value,
            ),
          ]),

          const SizedBox(height: 20),

          // Push Notifications
          _buildSection('Push Notifications', [
            _buildSwitchTile(
              'Low Stock Alerts',
              'Push notification for low stock',
              controller.pushLowStock.value,
              (value) => controller.pushLowStock.value = value,
            ),
            _buildSwitchTile(
              'Expiry Alerts',
              'Push notification for expiring items',
              controller.pushExpiry.value,
              (value) => controller.pushExpiry.value = value,
            ),
            _buildSwitchTile(
              'Stock Movements',
              'Get notified about stock in/out',
              controller.pushStockMovement.value,
              (value) => controller.pushStockMovement.value = value,
            ),
          ]),

          const SizedBox(height: 20),

          // Alert Thresholds
          _buildSection('Alert Thresholds', [
            _buildSliderTile(
              'Low Stock Threshold',
              'Alert when stock falls below',
              controller.lowStockThreshold.value,
              5, 50,
              (value) => controller.lowStockThreshold.value = value,
              'units',
            ),
            _buildSliderTile(
              'Expiry Alert Days',
              'Alert before expiry',
              controller.expiryAlertDays.value,
              7, 90,
              (value) => controller.expiryAlertDays.value = value,
              'days',
            ),
          ]),

          const SizedBox(height: 20),

          // Email Addresses
          _buildSection('Notification Emails', [
            ...controller.emailAddresses.map((email) => 
              _buildEmailTile(email)
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: controller.showAddEmailDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Email Address'),
            ),
          ]),

          const SizedBox(height: 32),

          CustomButton(
            text: 'Save Settings',
            onPressed: controller.saveSettings,
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 50,
            borderRadius: 12,
          ),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2F),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E1E2F),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  onChanged: onChanged,
                  activeColor: const Color(0xFF1E1E2F),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()} $unit',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTile(String email) {
    return ListTile(
      leading: const Icon(Icons.email_outlined, size: 20),
      title: Text(email),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18, color: Colors.red),
        onPressed: () => controller.removeEmail(email),
      ),
    );
  }
}