// lib/modules/admin/reports/bindings/reports_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';


class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    Get.lazyPut<ReportsController>(
      () => ReportsController(
        productRepository: Get.find<ProductRepository>(),
      ),
      fenix: true,
    );
  }
}