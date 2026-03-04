// lib/modules/admin/controller/admin_dashboard_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/chart_repository.dart';
import 'package:warehouse_management_app/data/reposotories/dashboard_repository.dart';

import '../../../data/models/dashboard_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/models/chart_data.dart';
import '../../../data/models/category_data.dart';

class AdminDashboardController extends GetxController {
  final DashboardRepository _dashboardRepository;
  final ChartRepository _chartRepository;

  AdminDashboardController({
    required DashboardRepository dashboardRepository,
    required ChartRepository chartRepository,
  })  : _dashboardRepository = dashboardRepository,
        _chartRepository = chartRepository;

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;

  // Data
  final dashboardData = Rxn<DashboardModel>();
  final recentActivities = <ActivityModel>[].obs;
  final alerts = <AlertModel>[].obs;

  // Chart data
  final stockMovementData = <ChartData>[].obs;
  final categoryDistribution = <CategoryData>[].obs;
  final topProductsData = <ChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load all data in parallel
      final results = await Future.wait([
        _dashboardRepository.getDashboardMetrics(),
        _dashboardRepository.getRecentActivities(),
        _dashboardRepository.getAlerts(),
        _chartRepository.getStockMovementData(),
        _chartRepository.getCategoryDistribution(),
        _chartRepository.getTopProducts(),
      ]);

      dashboardData.value = results[0] as DashboardModel;
      recentActivities.value = results[1] as List<ActivityModel>;
      alerts.value = results[2] as List<AlertModel>;
      stockMovementData.value = results[3] as List<ChartData>;
      categoryDistribution.value = results[4] as List<CategoryData>;
      topProductsData.value = results[5] as List<ChartData>;

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardData();
    } finally {
      isRefreshing.value = false;
    }
  }

  void onAlertTap(AlertModel alert) {
    switch(alert.type) {
      case 'low_stock':
        Get.toNamed('/admin/products?filter=low_stock');
        break;
      case 'expiry':
        Get.toNamed('/admin/products?filter=expiring');
        break;
      default:
        Get.toNamed('/admin/alerts/${alert.id}');
    }
  }

  // Getters for quick access
  bool get hasLowStock => (dashboardData.value?.lowStockCount ?? 0) > 0;
  bool get hasExpiring => (dashboardData.value?.expiringCount ?? 0) > 0;
}