// lib/modules/admin/settings/views/settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/settings/controllers/settings_controllers.dart';
import 'package:warehouse_management_app/widgets/settings_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'admin@warehouse.com',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Get.toNamed('/settings/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Sections
            _buildSection('Store Management', [
              SettingsTile(
                icon: Icons.store_outlined,
                title: 'Company Profile',
                subtitle: 'Update store information',
                onTap: () => Get.toNamed('/settings/company'),
              ),
              SettingsTile(
                icon: Icons.category_outlined,
                title: 'Categories',
                subtitle: 'Manage product categories',
                onTap: () => Get.toNamed('/settings/categories'),
              ),
              SettingsTile(
                icon: Icons.business_outlined,
                title: 'Suppliers',
                subtitle: 'Manage supplier list',
                onTap: () => Get.toNamed('/settings/suppliers'),
              ),
            ]),

            _buildSection('User Management', [
              SettingsTile(
                icon: Icons.people_outline,
                title: 'Staff Users',
                subtitle: 'Add or remove staff members',
                onTap: () => Get.toNamed('/settings/users'),
              ),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Roles & Permissions',
                subtitle: 'Set user access levels',
                onTap: () => Get.snackbar('Info', 'Coming soon'),
              ),
            ]),

            _buildSection('System Settings', [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Configure alert preferences',
                onTap: () => Get.toNamed('/settings/notifications'),
              ),
              SettingsTile(
                icon: Icons.attach_money_outlined,
                title: 'Tax & Currency',
                subtitle: 'Set tax rates and currency',
                onTap: () => Get.snackbar('Info', 'Coming soon'),
              ),
              SettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup & Restore',
                subtitle: 'Backup your data',
                onTap: () => Get.snackbar('Info', 'Coming soon'),
              ),
            ]),

            _buildSection('Support', [
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'FAQs and guides',
                onTap: () => Get.snackbar('Info', 'Coming soon'),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => Get.snackbar('Info', 'Coming soon'),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version 1.0.0',
                onTap: () => Get.snackbar('Info', 'Warehouse App v1.0.0'),
              ),
            ]),

            const SizedBox(height: 20),

            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: controller.logout,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}