// lib/modules/admin/inventory/bindings/inventory_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/inventory_repository.dart';
import 'package:warehouse_management_app/modules/innventory/controllers/inventory_vauation_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryRepository>(
      () => InventoryRepository(),
      fenix: true,
    );
    
    Get.lazyPut<InventoryValuationController>(
      () => InventoryValuationController(),
      fenix: true,
    );
  }
}