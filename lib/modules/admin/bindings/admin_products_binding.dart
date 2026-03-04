// lib/modules/admin/products/bindings/products_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_add_product_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_details_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_list_controller.dart';


class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    Get.lazyPut<ProductListController>(
      () => ProductListController(repository: Get.find<ProductRepository>()),
    );
    
    Get.lazyPut<AddProductController>(
      () => AddProductController(repository: Get.find<ProductRepository>()),
    );
    
    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(repository: Get.find<ProductRepository>()),
    );
  }
}