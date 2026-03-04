// lib/modules/admin/orders/bindings/orders_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/modules/orders/controllers/create_order_controller.dart';
import 'package:warehouse_management_app/modules/orders/controllers/order_detail_controller.dart';
import 'package:warehouse_management_app/modules/orders/controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    // Product Repository (for CreateOrderController)
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(),
      fenix: true,
    );
    
    // Order Repository
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(),
      fenix: true,
    );
    
    // Orders Controller
    Get.lazyPut<OrdersController>(
      () => OrdersController(
        orderRepository: Get.find<OrderRepository>(),
      ),
      fenix: true,
    );
    
    // Create Order Controller (needs both repositories)
    Get.lazyPut<CreateOrderController>(
      () => CreateOrderController(
        orderRepository: Get.find<OrderRepository>(),
        productRepository: Get.find<ProductRepository>(), 
      ),
      fenix: true,
    );
    
    // Order Details Controller
    Get.lazyPut<OrderDetailsController>(
      () => OrderDetailsController(
        orderRepository: Get.find<OrderRepository>(),
      ),
      fenix: true,
    );
  }
}