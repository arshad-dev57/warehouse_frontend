// lib/modules/admin/dashboard/bindings/admin_dashboard_binding.dart

import 'package:get/get.dart';

import 'package:warehouse_management_app/data/reposotories/chart_repository.dart';
import 'package:warehouse_management_app/data/reposotories/dashboard_repository.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_dashboard_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_list_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // API Service (already registered)
    // Get.find<ApiService>() will work
    
    // Product Repository
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    // Order Repository (for charts)
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(),
      fenix: true,
    );
    
    // Dashboard Repository
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    
    // Chart Repository (NEW)
    Get.lazyPut<ChartRepository>(
      () => ChartRepository(
        productRepository: Get.find<ProductRepository>(),
        orderRepository: Get.find<OrderRepository>(),
      ),
      fenix: true,
    );
    
    // Product List Controller
    Get.lazyPut<ProductListController>(
      () => ProductListController(repository: Get.find<ProductRepository>()),
      fenix: true,
    );
    
    // Admin Dashboard Controller (UPDATED)
    Get.lazyPut<AdminDashboardController>(
      () => AdminDashboardController(
        dashboardRepository: Get.find<DashboardRepository>(),
        chartRepository: Get.find<ChartRepository>(),  // 👈 Add this
      ),
      fenix: true,
    );
  }
}