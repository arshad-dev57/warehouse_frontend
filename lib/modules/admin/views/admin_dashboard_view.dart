// lib/modules/admin/dashboard/views/admin_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/alert_model.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_dashboard_controller.dart';
import 'package:warehouse_management_app/widgets/activity_tile.dart';
import 'package:warehouse_management_app/widgets/chart_widget.dart';
import 'package:warehouse_management_app/widgets/custom_button.dart';
import 'package:warehouse_management_app/widgets/drawer.dart';
import 'package:warehouse_management_app/widgets/error_widget.dart';
import 'package:warehouse_management_app/widgets/loading_widget.dart';
import 'package:warehouse_management_app/widgets/metrics_card.dart';
import 'package:warehouse_management_app/widgets/network_aware_widget.dart';


class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfessionalDrawer(),
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: NetworkAwareWidget(
        onlineChild: _buildBody(),
        offlineChild: _buildOfflineWidget(),
      ),
    );
  }

  // Professional App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Dashboard',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      actions: [
        // Notification bell with badge
          IconButton(
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Get.toNamed(AppRoutes.settings),
    ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed(AppRoutes.alerts),
              color: const Color(0xFF1E1E2F),
            ),
            if (controller.alerts.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${controller.alerts.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Profile avatar
        GestureDetector(
          onTap: () => Get.toNamed('/profile'),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ),
      ],
    );
  }

  // Main Body with Refresh Indicator
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      color: const Color(0xFF1E1E2F),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 20),
                
                // Metrics Grid
                Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingWidget(message: 'Loading dashboard...');
                  }
                  if (controller.error.isNotEmpty) {
                    return errorWidget(
                      message: controller.error.value,
                      onRetry: controller.loadDashboardData,
                    );
                  }
                  return _buildMetricsGrid();
                }),
                const SizedBox(height: 24),
                
                // Charts Section
                _buildChartsSection(),
                const SizedBox(height: 24),
                
                // Alerts Section
                _buildAlertsSection(),
                const SizedBox(height: 24),
                
                // Recent Activities
                _buildRecentActivities(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Welcome Section
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Admin! 👋',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s what\'s happening in your warehouse today',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Metrics Grid
  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        MetricsCard(
          title: 'Total Products',
          value: '${controller.dashboardData.value?.totalProducts ?? 0}',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
          trend: '+12 this week',
  onTap: () => Get.toNamed(AppRoutes.adminproducts),

        ),
        MetricsCard(
          title: 'Stock Value',
          value: '₹${controller.dashboardData.value?.totalStockValue ?? 0}',
          icon: Icons.currency_rupee,
          color: Colors.green,
          trend: '+5.2% vs last week',
onTap: () => Get.toNamed(AppRoutes.reportsDashboard),
        ),
       MetricsCard(
  title: 'Low Stock',
  value: '${controller.dashboardData.value?.lowStockCount ?? 0}',
  icon: Icons.warning_amber_outlined,
  color: Colors.orange,
  isAlert: (controller.dashboardData.value?.lowStockCount ?? 0) > 0,
),

MetricsCard(
  title: 'Expiring Soon',
  value: '${controller.dashboardData.value?.expiringCount ?? 0}',
  icon: Icons.event_outlined,
  color: Colors.red,
  isAlert: (controller.dashboardData.value?.expiringCount ?? 0) > 0,
),
      ],
    );
  }

  // Charts Section
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Stock Movement Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock Movement (Last 7 Days)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/admin/reports'),
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF1E1E2F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: Obx(() {
                  if (controller.stockMovementData.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ChartWidget.line(
                    data: controller.stockMovementData,
                  );
                }),
              ),
              const Divider(height: 24),
              
              // Category Distribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Distribution',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: Obx(() {
                  if (controller.categoryDistribution.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ChartWidget.pie(
                    data: controller.categoryDistribution,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Alerts Section
  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Alerts',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E2F),
              ),
            ),
            if (controller.alerts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Text(
                  '${controller.alerts.length} new',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.alerts.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All clear! No active alerts',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.alerts.length > 3 ? 3 : controller.alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final alert = controller.alerts[index];
              return _buildAlertTile(alert);
            },
          );
        }),
        if (controller.alerts.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton(
                onPressed: () => Get.toNamed('/admin/alerts'),
                child: Text(
                  'View all ${controller.alerts.length} alerts',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Alert Tile
  Widget _buildAlertTile(AlertModel alert) {
    Color color;
    IconData icon;
    
    switch(alert.severity) {
      case 'high':
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }
    
    return GestureDetector(
      onTap: () => controller.onAlertTap(alert),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              alert.time,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent Activities
  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E2F),
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/admin/activities'),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF1E1E2F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.recentActivities.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No recent activities'),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentActivities.length > 5 
                  ? 5 : controller.recentActivities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = controller.recentActivities[index];
                return ActivityTile(activity: activity);
              },
            );
          }),
        ),
      ],
    );
  }

  // Offline Widget
  Widget _buildOfflineWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: controller.loadDashboardData,
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 45,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}