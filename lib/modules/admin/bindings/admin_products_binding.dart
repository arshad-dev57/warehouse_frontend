// lib/modules/admin/products/bindings/admin_products_binding.dart

import 'package:get/get.dart';

import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_add_product_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_details_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_list_controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    // Register ProductRepository
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    // 👈 ADD StockRepository
    Get.lazyPut<StockRepository>(
      () => StockRepository(),
      fenix: true,
    );
    
    // Register ProductListController
    Get.lazyPut<ProductListController>(
      () => ProductListController(
        repository: Get.find<ProductRepository>(),
      ),
      fenix: true,
    );
    
    // Register AddProductController
    Get.lazyPut<AddProductController>(
      () => AddProductController(
        repository: Get.find<ProductRepository>(),
      ),
      fenix: true,
    );
    
    // 👈 UPDATE ProductDetailsController with StockRepository
    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(
        productRepository: Get.find<ProductRepository>(),
        stockRepository: Get.find<StockRepository>(), // 👈 ADD THIS
      ),
      fenix: true,
    );
  }
}