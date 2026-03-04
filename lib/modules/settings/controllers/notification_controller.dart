// lib/modules/admin/settings/controllers/notification_settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  // Email notifications
  final emailLowStock = true.obs;
  final emailExpiry = true.obs;
  final emailDailySummary = false.obs;

  // Push notifications
  final pushLowStock = true.obs;
  final pushExpiry = true.obs;
  final pushStockMovement = true.obs;

  // Thresholds
  final lowStockThreshold = 10.0.obs;
  final expiryAlertDays = 30.0.obs;

  // Email addresses
  final emailAddresses = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    // Mock data - replace with API call
    emailAddresses.value = [
      'admin@warehouse.com',
      'manager@warehouse.com',
    ];
  }

  void showAddEmailDialog() {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Enter email address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty && 
                  GetUtils.isEmail(emailController.text)) {
                addEmail(emailController.text);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid email',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addEmail(String email) {
    if (!emailAddresses.contains(email)) {
      emailAddresses.add(email);
      
      Get.snackbar(
        'Success',
        'Email added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void removeEmail(String email) {
    emailAddresses.remove(email);
    
    Get.snackbar(
      'Success',
      'Email removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> saveSettings() async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Close loading
      Get.back();

      Get.snackbar(
        'Success',
        'Notification settings saved',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
      
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to save settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}