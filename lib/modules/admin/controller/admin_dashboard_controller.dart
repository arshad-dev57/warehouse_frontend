// lib/modules/admin/controller/admin_dashboard_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/chart_repository.dart';
import 'package:warehouse_management_app/data/reposotories/dashboard_repository.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';

import '../../../data/models/dashboard_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/models/chart_data.dart';
import '../../../data/models/category_data.dart';
import '../../../data/models/order_model.dart';

class AdminDashboardController extends GetxController {
  final DashboardRepository _dashboardRepository;
  final ChartRepository _chartRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final StockRepository _stockRepository;

  AdminDashboardController({
    required DashboardRepository dashboardRepository,
    required ChartRepository chartRepository,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
    required StockRepository stockRepository,
  })  : _dashboardRepository = dashboardRepository,
        _chartRepository = chartRepository,
        _productRepository = productRepository,
        _orderRepository = orderRepository,
        _stockRepository = stockRepository;

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

  // Operational metrics
  final todayStockIn = 0.obs;
  final todayStockOut = 0.obs;
  final todayOrders = 0.obs;
  final pendingOrders = 0.obs;
  final todayRevenue = 0.0.obs;
  
  // Total orders
  final totalOrders = 0.obs;
  
  // Stock health metrics
  final lowStockCount = 0.obs;
  final expiringCount = 0.obs;
  final outOfStockCount = 0.obs;
  final overstockCount = 0.obs;

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
        _getOperationalMetrics(),
      ]);

      dashboardData.value = results[0] as DashboardModel;
      recentActivities.value = results[1] as List<ActivityModel>;
      alerts.value = results[2] as List<AlertModel>;
      stockMovementData.value = results[3] as List<ChartData>;
      categoryDistribution.value = results[4] as List<CategoryData>;
      topProductsData.value = results[5] as List<ChartData>;
      
      // Set operational metrics
      final metrics = results[6] as Map<String, dynamic>;
      todayStockIn.value = metrics['todayStockIn'] ?? 0;
      todayStockOut.value = metrics['todayStockOut'] ?? 0;
      todayOrders.value = metrics['todayOrders'] ?? 0;
      pendingOrders.value = metrics['pendingOrders'] ?? 0;
      todayRevenue.value = metrics['todayRevenue'] ?? 0.0;
      totalOrders.value = metrics['totalOrders'] ?? 0;
      
      // Set stock health metrics from dashboard data
      if (dashboardData.value != null) {
        lowStockCount.value = dashboardData.value!.lowStockCount;
        expiringCount.value = dashboardData.value!.expiringCount;
        outOfStockCount.value = dashboardData.value!.outOfStockCount;
        overstockCount.value = dashboardData.value!.overstockCount;
      }

    } catch (e) {
      error.value = e.toString();
      print('Error loading dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> _getOperationalMetrics() async {
    try {
      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch orders
      final orders = await _orderRepository.getOrders();
      
      // Calculate metrics
      final todayOrdersList = orders.where((order) {
        final orderDate = order.createdAt;
        return orderDate.isAfter(startOfDay) && orderDate.isBefore(endOfDay);
      }).toList();

      final pendingOrdersList = orders.where((order) {
        return order.status == OrderStatus.pending;
      }).toList();

      // Calculate revenue from today's orders
      final todayRevenue = todayOrdersList.fold<double>(
        0, (sum, order) => sum + order.total
      );

      // Get today's stock movements
      final stockMovements = await _stockRepository.getAllStockHistory();
      final todayStockInList = stockMovements.where((m) {
        final moveDate = DateTime.parse(m['createdAt']);
        return moveDate.isAfter(startOfDay) && 
               moveDate.isBefore(endOfDay) && 
               m['type'] == 'stock_in';
      }).toList();

      final todayStockOutList = stockMovements.where((m) {
        final moveDate = DateTime.parse(m['createdAt']);
        return moveDate.isAfter(startOfDay) && 
               moveDate.isBefore(endOfDay) && 
               m['type'] == 'stock_out';
      }).toList();

      // Get total orders count
      final ordersCount = await _orderRepository.getOrdersCount();
      final totalOrdersCount = (ordersCount['pending'] ?? 0) + 
                               (ordersCount['processing'] ?? 0) + 
                               (ordersCount['completed'] ?? 0) + 
                               (ordersCount['cancelled'] ?? 0);

      return {
        'todayStockIn': todayStockInList.fold<int>(0, (sum, m) => sum + (m['quantity'] ?? 0) as int),
        'todayStockOut': todayStockOutList.fold<int>(0, (sum, m) => sum + (m['quantity'] ?? 0) as int),
        'todayOrders': todayOrdersList.length,
        'pendingOrders': pendingOrdersList.length, 
        'todayRevenue': todayRevenue,
        'totalOrders': totalOrdersCount,
      };
    } catch (e) {
      print('Error loading operational metrics: $e');
      return {
        'todayStockIn': 0,
        'todayStockOut': 0,
        'todayOrders': 0,
        'pendingOrders': 0,
        'todayRevenue': 0.0,
        'totalOrders': 0,
      };
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
  bool get hasLowStock => lowStockCount.value > 0;
  bool get hasExpiring => expiringCount.value > 0;
  
  // Helper for formatting
  String formatNumber(dynamic value) {
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
}