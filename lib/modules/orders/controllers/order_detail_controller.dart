// lib/modules/admin/orders/controllers/order_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import '../../../../data/models/order_model.dart';

class OrderDetailsController extends GetxController {
  final OrderRepository _orderRepository;

  OrderDetailsController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  final order = Rxn<OrderModel>();
  final isLoading = true.obs;
  final error = ''.obs;

  late String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.parameters['orderId'] ?? '';
    if (orderId.isNotEmpty) {
      loadOrderDetails();
    } else {
      error.value = 'Order ID not found';
      isLoading.value = false;
    }
  }

  Future<void> loadOrderDetails() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final data = await _orderRepository.getOrderById(orderId);
      
      if (data != null) {
        order.value = data;
      } else {
        error.value = 'Order not found';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(OrderStatus status) async {
    try {
      isLoading.value = true;
      
      final updated = await _orderRepository.updateOrderStatus(orderId, status);
      order.value = updated;
      
      Get.snackbar(
        'Success',
        'Order status updated to ${status.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}