// lib/widgets/drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';

class ProfessionalDrawer extends StatelessWidget {
  final String orderCount;
  const ProfessionalDrawer({super.key, required this.orderCount});

  @override
  Widget build(BuildContext context) {
    
    return Drawer(
      width: 280,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2B3C), Color(0xFF2C3E50)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warehouse_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warehouse Pro',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      'A',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'admin@warehouse.com',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Sections with Expandable Tabs
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSection(
                    title: 'MAIN',
                    children: [
                      _buildMenuItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        route: AppRoutes.admindashbaord,
                      ),
                    ],
                  ),
                  
                  _buildSection(
                    title: 'INVENTORY',
                    children: [
                      _buildMenuItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products',
                        route: AppRoutes.adminproducts,
                      ),
                      _buildMenuItem(
                        icon: Icons.category_outlined,
                        label: 'Categories',
                        route: '/settings/categories',
                      ),
                      _buildMenuItem(
                        icon: Icons.business_outlined,
                        label: 'Suppliers',
                        route: '/settings/suppliers',
                      ),
                    ],
                  ),
                  
                  _buildSection(
                    title: 'STOCK',
                    children: [
                      _buildMenuItem(
                        icon: Icons.add_box_outlined,
                        label: 'Stock In',
                        route: AppRoutes.stockIn,
                      ),
                      _buildMenuItem(
                        icon: Icons.remove_shopping_cart_outlined,
                        label: 'Stock Out',
                        route: AppRoutes.stockOut,
                      ),
                   
                    ],
                  ),
                  
                  _buildSection(
                    title: 'SALES',
                    children: [
                      _buildMenuItem(
                        icon: Icons.receipt_outlined,
                        label: 'Orders',
                        route: AppRoutes.orders,
                        badge: orderCount.tr,
                      ),
                      _buildMenuItem(
                        icon: Icons.assessment_outlined,
                        label: 'Reports',
                        route: AppRoutes.reportsDashboard,
                      ),
                    ],
                  ),
                  
                  _buildSection(
                    title: 'SETTINGS',
                    children: [
                        _buildMenuItem(
                        icon: Icons.account_circle,
                        label: 'Users',
                        route: AppRoutes.users,
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        route: AppRoutes.settings,
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        label: 'Help',
                        route: '/help',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
                onTap: () => _showLogoutDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String route,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1E2B3C)),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      onTap: () {
        Get.back();
        Get.toNamed(route);
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        TextButton(
  onPressed: () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token'); // token delete

    Get.offAllNamed(AppRoutes.login);
  },
  style: TextButton.styleFrom(
    foregroundColor: Colors.red,
  ),
  child: const Text('Logout'),
)
        ],
      ),
    );
  }
}