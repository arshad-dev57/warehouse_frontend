// lib/modules/admin/dashboard/views/admin_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/alert_model.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_dashboard_controller.dart';
import 'package:warehouse_management_app/widgets/activity_tile.dart';
import 'package:warehouse_management_app/widgets/chart_widget.dart';
import 'package:warehouse_management_app/widgets/custom_button.dart';
import 'package:warehouse_management_app/widgets/drawer.dart';
import 'package:warehouse_management_app/widgets/error_widget.dart';
import 'package:warehouse_management_app/widgets/metrics_card.dart';
import 'package:warehouse_management_app/widgets/network_aware_widget.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  final List<Color> _chartColors = const [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFC107), // Amber
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfessionalDrawer(orderCount: controller.totalOrders.value.toString()),
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: NetworkAwareWidget(
        onlineChild: _buildBody(),
        offlineChild: _buildOfflineWidget(),
      ),
    );
  }

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
        // Settings button
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
        // Notification bell with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed(AppRoutes.alerts),
              color: const Color(0xFF1E1E2F),
            ),
            Obx(() {
              if (controller.alerts.isNotEmpty) {
                return Positioned(
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
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        // Profile avatar - Add if needed
        const SizedBox(width: 8),
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
                
                // Metrics Grid with Shimmer
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerLoading();
                  }
                  if (controller.error.isNotEmpty) {
                    return errorWidget(
                      message: controller.error.value,
                      onRetry: controller.loadDashboardData,
                    );
                  }
                  return Column(
                    children: [
                      _buildInventoryMetrics(),
                      const SizedBox(height: 24),
                      _buildOperationalMetrics(),
                      const SizedBox(height: 24),
                      _buildStockHealthMetrics(), // 🔥 NEW: Stock Health Section
                    ],
                  );
                }),
                const SizedBox(height: 24),
                
                // Charts Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerCharts();
                  }
                  return _buildChartsSection();
                }),
                const SizedBox(height: 24),
                
                // Alerts Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerAlerts();
                  }
                  return _buildAlertsSection();
                }),
                const SizedBox(height: 24),
                
                // Recent Activities
                Obx(() {
                  if (controller.isLoading.value) {
                    return _buildShimmerActivities();
                  }
                  return _buildRecentActivities();
                }),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SHIMMER LOADING WIDGETS ====================

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Inventory Metrics Shimmer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerSectionTitle(),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: List.generate(2, (_) => const ShimmerMetricsCard()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Operational Metrics Shimmer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerSectionTitle(),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: List.generate(2, (_) => const ShimmerMetricsCard()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Stock Health Shimmer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerSectionTitle(),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: List.generate(2, (_) => const ShimmerMetricsCard()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerSectionTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 150,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildShimmerCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerSectionTitle(),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmerSectionTitle(),
            _buildShimmerChip(),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: const ShimmerAlertTile(),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerChip() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 60,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmerSectionTitle(),
            _buildShimmerChip(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => const ShimmerActivityTile(),
          ),
        ),
      ],
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

  // Inventory Metrics Grid
  Widget _buildInventoryMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Overview',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
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
              title: 'Inventory Value',
              value: '₹${_formatNumber(controller.dashboardData.value?.totalStockValue ?? 0)}',
              icon: Icons.currency_rupee,
              color: Colors.green,
              trend: '+5.2% vs last week',
              onTap: () => Get.toNamed(AppRoutes.inventoryValuation),
            ),
          ],
        ),
      ],
    );
  }

  // 🔥 NEW: Stock Health Metrics
  Widget _buildStockHealthMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Health',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            MetricsCard(
              title: 'Low Stock',
              value: '${controller.dashboardData.value?.lowStockCount ?? 0}',
              icon: Icons.warning_amber_outlined,
              color: Colors.orange,
              isAlert: (controller.dashboardData.value?.lowStockCount ?? 0) > 0,
              onTap: () => Get.toNamed('${AppRoutes.adminproducts}?filter=low_stock'),
            ),
            MetricsCard(
              title: 'Expiring Soon',
              value: '${controller.dashboardData.value?.expiringCount ?? 0}',
              icon: Icons.event_outlined,
              color: Colors.red,
              isAlert: (controller.dashboardData.value?.expiringCount ?? 0) > 0,
              onTap: () => Get.toNamed('${AppRoutes.adminproducts}?filter=expiring'),
            ),
            MetricsCard(
              title: 'Out of Stock',
              value: '${controller.dashboardData.value?.outOfStockCount ?? 0}',
              icon: Icons.block,
              color: Colors.grey,
              isAlert: (controller.dashboardData.value?.outOfStockCount ?? 0) > 0,
              onTap: () => Get.toNamed('${AppRoutes.adminproducts}?filter=out_of_stock'),
            ),
            MetricsCard(
              title: 'Overstock',
              value: '${controller.dashboardData.value?.overstockCount ?? 0}',
              icon: Icons.inventory,
              color: Colors.purple,
              isAlert: (controller.dashboardData.value?.overstockCount ?? 0) > 0,
              onTap: () => Get.toNamed('${AppRoutes.adminproducts}?filter=overstock'),
            ),
          ],
        ),
      ],
    );
  }

  // Operational Metrics
  Widget _buildOperationalMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operations Overview',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            MetricsCard(
              title: 'Total Orders',
              value: '${controller.totalOrders}',
              icon: Icons.shopping_cart,
              color: Colors.indigo,
              trend: 'Revenue: ₹${_formatNumber(controller.todayRevenue.value)}',
              onTap: () => Get.toNamed(AppRoutes.orders),
            ),
            MetricsCard(
              title: 'Pending Orders',
              value: '${controller.pendingOrders}',
              icon: Icons.hourglass_empty,
              color: Colors.orange,
              isAlert: controller.pendingOrders > 0,
              onTap: () => Get.toNamed('${AppRoutes.orders}?status=pending'),
            ),
            MetricsCard(
  title: 'Today Stock In',
  value: '${controller.todayStockIn}',
  icon: Icons.arrow_downward,
  color: Colors.green,
  onTap: () => Get.toNamed(
    AppRoutes.todayStockHistory,
    arguments: {'filter': 'in'}, // Optional
  ),
),
         MetricsCard(
  title: 'Today Stock Out',
  value: '${controller.todayStockOut}',
  icon: Icons.arrow_upward,
  color: Colors.red,
  onTap: () => Get.toNamed(
    AppRoutes.todayStockHistory,
    arguments: {'filter': 'out'}, // Optional
  ),
),          ],
        ),
      ],
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is double || value is int) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toString();
    }
    return value.toString();
  }

  // Charts Section with Custom Colors
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
                    lineColor: _getLineChartColor(controller.stockMovementData),
                    fillColor: _getLineChartFillColor(controller.stockMovementData),
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
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.categories),
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF1E1E2F),
                        fontWeight: FontWeight.w600,
                      ),
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
                  
                  final topCategories = controller.categoryDistribution.length > 5
                      ? controller.categoryDistribution.sublist(0, 5)
                      : controller.categoryDistribution;
                  
                  final List<Color> categoryColors = _generateCategoryColors(topCategories);
                  
                  return Column(
                    children: [
                      Expanded(
                        child: ChartWidget.pie(
                          data: topCategories,
                          customColors: categoryColors,
                        ),
                      ),
                      if (controller.categoryDistribution.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Showing top 5 of ${controller.categoryDistribution.length} categories',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get line chart color based on data trend
  Color _getLineChartColor(List<dynamic> data) {
    if (data.isEmpty) return Colors.blue;
    
    final firstValue = _extractNumericValue(data.first);
    final lastValue = _extractNumericValue(data.last);
    
    if (lastValue > firstValue) {
      return Colors.green;
    } else if (lastValue < firstValue) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  // Helper method to get line chart fill color based on data trend
  Color _getLineChartFillColor(List<dynamic> data) {
    if (data.isEmpty) return Colors.blue.withOpacity(0.1);
    
    final firstValue = _extractNumericValue(data.first);
    final lastValue = _extractNumericValue(data.last);
    
    if (lastValue > firstValue) {
      return Colors.green.withOpacity(0.1);
    } else if (lastValue < firstValue) {
      return Colors.orange.withOpacity(0.1);
    } else {
      return Colors.blue.withOpacity(0.1);
    }
  }

  // Helper method to extract numeric value from chart data
  double _extractNumericValue(dynamic item) {
    if (item is Map) {
      if (item.containsKey('value')) {
        return item['value']?.toDouble() ?? 0;
      } else if (item.containsKey('y')) {
        return item['y']?.toDouble() ?? 0;
      }
    } else if (item is List && item.length > 1) {
      return item[1]?.toDouble() ?? 0;
    }
    return 0;
  }

  // Generate colors for category pie chart based on conditions
  List<Color> _generateCategoryColors(List<dynamic> categories) {
    List<Color> colors = [];
    
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = _extractNumericValue(category);
      
      if (value > 1000) {
        colors.add(Colors.red);
      } else if (value > 500) {
        colors.add(Colors.orange);
      } else if (value > 100) {
        colors.add(Colors.green);
      } else {
        colors.add(_chartColors[i % _chartColors.length]);
      }
    }
    
    return colors;
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
            Obx(() {
              if (controller.alerts.isNotEmpty) {
                return Container(
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
                );
              }
              return const SizedBox.shrink();
            }),
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
        Obx(() {
          if (controller.alerts.length > 3) {
            return Padding(
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
            );
          }
          return const SizedBox.shrink();
        }),
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

// ==================== SHIMMER WIDGETS ====================

class ShimmerMetricsCard extends StatelessWidget {
  const ShimmerMetricsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerAlertTile extends StatelessWidget {
  const ShimmerAlertTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerActivityTile extends StatelessWidget {
  const ShimmerActivityTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}