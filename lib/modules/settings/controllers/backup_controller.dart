// lib/modules/admin/settings/controllers/backup_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackupController extends GetxController {
  final autoBackup = true.obs;
  final includeImages = true.obs;
  final compressData = true.obs;

  final lastBackup = 'Today, 10:30 AM'.obs;
  final backupSize = '2.5 MB'.obs;

  final backupHistory = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBackupHistory();
  }

  void loadBackupHistory() {
    backupHistory.value = [
      {'id': '1', 'date': '2024-01-15 10:30 AM', 'size': '2.5 MB'},
      {'id': '2', 'date': '2024-01-14 10:30 AM', 'size': '2.4 MB'},
      {'id': '3', 'date': '2024-01-13 10:30 AM', 'size': '2.3 MB'},
      {'id': '4', 'date': '2024-01-12 10:30 AM', 'size': '2.2 MB'},
    ];
  }

  Future<void> createBackup() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 2));

    Get.back();

    Get.snackbar(
      'Success',
      'Backup created successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    lastBackup.value = 'Just now';
    backupSize.value = '2.6 MB';
  }

  void showRestoreDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('Are you sure you want to restore from last backup? Current data will be replaced.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              restoreBackup('last');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> restoreBackup(String id) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 2));

    Get.back();

    Get.snackbar(
      'Success',
      'Data restored successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> exportToCloud() async {
    Get.snackbar(
      'Info',
      'Exporting to cloud...',
      snackPosition: SnackPosition.BOTTOM,
    );

    await Future.delayed(const Duration(seconds: 2));

    Get.snackbar(
      'Success',
      'Backup uploaded to cloud',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void deleteBackup(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              backupHistory.removeWhere((b) => b['id'] == id);
              Get.back();

              Get.snackbar(
                'Success',
                'Backup deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void deleteAllBackups() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete All Backups'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              backupHistory.clear();
              Get.back();

              Get.snackbar(
                'Success',
                'All backups deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}