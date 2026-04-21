// lib/modules/admin/products/bindings/product_search_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/modules/search/controllers/search_product_controller.dart';

class ProductSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductSearchController>(
      () => ProductSearchController(),
      fenix: true,
    );
  }
}