// lib/modules/admin/alerts/bindings/alerts_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/alert_repository.dart';
import '../controllers/alerts_controller.dart';

class AlertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlertRepository>(
      () => AlertRepository(),
      fenix: true,
    );
    
    Get.lazyPut<AlertsController>(
      () => AlertsController(
        alertRepository: Get.find<AlertRepository>(),
      ),
      fenix: true,
    );
  }
}