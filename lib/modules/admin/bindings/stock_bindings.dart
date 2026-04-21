// lib/modules/admin/stock/bindings/stock_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import 'package:warehouse_management_app/data/reposotories/supplier_repository.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stcok_out_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stock_history_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_stock_in_controller.dart';


class StockBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    Get.lazyPut<StockRepository>(
      () => StockRepository(),
      fenix: true,
    );
    
    Get.lazyPut<SupplierRepository>(
      () => SupplierRepository(),
      fenix: true,
    );
    
    // Stock In Controller (UPDATED with all 3 repositories)
    Get.lazyPut<StockInController>(
      () => StockInController(
        productRepository: Get.find<ProductRepository>(),
        stockRepository: Get.find<StockRepository>(),
        supplierRepository: Get.find<SupplierRepository>(), // 👈 YEH ADD KARO
      ),
      fenix: true,
    );
    
    // Stock Out Controller
    Get.lazyPut<StockOutController>(
      () => StockOutController(
        productRepository: Get.find<ProductRepository>(),
        stockRepository: Get.find<StockRepository>(),
      ),
      fenix: true,
    );
    
    // Stock History Controller
    Get.lazyPut<StockHistoryController>(
      () => StockHistoryController(
        stockRepository: Get.find<StockRepository>(),
      ),
      fenix: true,
    );
  }
}