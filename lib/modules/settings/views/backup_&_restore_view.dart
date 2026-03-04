// lib/modules/admin/settings/views/backup_restore_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/backup_controller.dart';

class BackupRestoreView extends GetView<BackupController> {
  const BackupRestoreView({super.key});

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
          'Backup & Restore',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Last Backup Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_done,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Backup',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        controller.lastBackup.value,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  controller.backupSize.value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Backup Options
          _buildSection('Backup Options', [
            _buildOptionTile(
              'Auto Backup',
              'Automatically backup data daily',
              Icons.autorenew,
              controller.autoBackup.value,
              (value) => controller.autoBackup.value = value,
            ),
            _buildOptionTile(
              'Include Images',
              'Backup product images',
              Icons.image,
              controller.includeImages.value,
              (value) => controller.includeImages.value = value,
            ),
            _buildOptionTile(
              'Compress Data',
              'Compress backup to save space',
              Icons.compress,
              controller.compressData.value,
              (value) => controller.compressData.value = value,
            ),
          ]),

          const SizedBox(height: 20),

          // Backup Actions
          _buildSection('Actions', [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.backup, color: Colors.green.shade700),
              ),
              title: const Text('Create Backup Now'),
              subtitle: const Text('Manual backup of all data'),
              onTap: controller.createBackup,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restore, color: Colors.orange.shade700),
              ),
              title: const Text('Restore Data'),
              subtitle: const Text('Restore from last backup'),
              onTap: controller.showRestoreDialog,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.cloud_upload, color: Colors.blue.shade700),
              ),
              title: const Text('Export to Cloud'),
              subtitle: const Text('Upload backup to cloud storage'),
              onTap: controller.exportToCloud,
            ),
          ]),

          const SizedBox(height: 20),

          // Backup History
          _buildSection('Backup History', [
            ...controller.backupHistory.map((backup) => 
              _buildBackupTile(backup)
            ),
          ]),

          const SizedBox(height: 20),

          // Danger Zone
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                 Divider(height: 1, color: Colors.redAccent),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                  title: Text(
                    'Delete All Backups',
                    style: GoogleFonts.inter(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: controller.deleteAllBackups,
                ),
              ],
            ),
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

  Widget _buildOptionTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
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

  Widget _buildBackupTile(Map<String, String> backup) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(backup['date']!),
      subtitle: Text('Size: ${backup['size']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.restore, size: 18),
            onPressed: () => controller.restoreBackup(backup['id']!),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => controller.deleteBackup(backup['id']!),
          ),
        ],
      ),
    );
  }
}