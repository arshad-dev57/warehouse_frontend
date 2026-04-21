// lib/modules/admin/stock/bindings/today_stock_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_todays_stockhistory_controller.dart';

class TodayStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodayStockHistoryController>(
      () => TodayStockHistoryController(
        stockRepository: Get.find<StockRepository>(),
      ),
      fenix: true,
    );
  }
}