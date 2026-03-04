// lib/modules/admin/stock/bindings/stock_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
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
    
    // Stock In Controller
    Get.lazyPut<StockInController>(
      () => StockInController(
        productRepository: Get.find<ProductRepository>(),
        stockRepository: Get.find<StockRepository>(),
      ),
      fenix: true,
    );
    

       // StockHistoryController mein ek comma missing tha
Get.lazyPut<StockHistoryController>(
  () => StockHistoryController(
    stockRepository: Get.find<StockRepository>(),  // 👈 Comma laga do
  ),
  fenix: true,
);
    

     Get.lazyPut<StockOutController>(
      () => StockOutController(
        productRepository: Get.find<ProductRepository>(),
        stockRepository: Get.find<StockRepository>(),
      ),
      fenix: true,
    );

    
    
  
  }
}