// lib/modules/admin/orders/controllers/orders_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import '../../../../data/models/order_model.dart';

class OrdersController extends GetxController {
  final OrderRepository _orderRepository;

  OrdersController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  // State
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;

  // Data
  final orders = <OrderModel>[].obs;
  final filteredOrders = <OrderModel>[].obs;
  final orderCounts = <OrderStatus, int>{}.obs;

  // Filters
  final selectedStatus = Rxn<OrderStatus>();
  final searchQuery = ''.obs;

  // Status tabs
  final tabs = [
    {'status': null, 'label': 'All', 'icon': Icons.list},
    {'status': OrderStatus.pending, 'label': 'Pending', 'icon': Icons.hourglass_empty},
    {'status': OrderStatus.processing, 'label': 'Processing', 'icon': Icons.autorenew},
    {'status': OrderStatus.completed, 'label': 'Completed', 'icon': Icons.check_circle},
    {'status': OrderStatus.cancelled, 'label': 'Cancelled', 'icon': Icons.cancel},
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    
    debounce(
      searchQuery,
      (_) => filterOrders(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      error.value = '';

      final results = await Future.wait([
        _orderRepository.getOrders(),
        _orderRepository.getOrdersCount(),
      ]);

      orders.value = results[0] as List<OrderModel>;
      
      // 🔥 FIX: Convert Map<String, int> to Map<OrderStatus, int>
      final countsMap = results[1] as Map<String, int>;
      final convertedCounts = <OrderStatus, int>{};
      
      countsMap.forEach((key, value) {
        switch(key) {
          case 'pending':
            convertedCounts[OrderStatus.pending] = value;
            break;
          case 'processing':
            convertedCounts[OrderStatus.processing] = value;
            break;
          case 'completed':
            convertedCounts[OrderStatus.completed] = value;
            break;
          case 'cancelled':
            convertedCounts[OrderStatus.cancelled] = value;
            break;
        }
      });
      
      orderCounts.value = convertedCounts;
      
      filterOrders();
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    try {
      isRefreshing.value = true;
      await loadOrders();
    } finally {
      isRefreshing.value = false;
    }
  }

  void filterOrders() {
    var filtered = List<OrderModel>.from(orders);

    // Apply status filter
    if (selectedStatus.value != null) {
      filtered = filtered.where((o) => o.status == selectedStatus.value).toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((o) =>
        o.orderNumber.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        (o.customerName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }

    filteredOrders.value = filtered;
  }

  void setStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
    filterOrders();
  }

  void navigateToCreateOrder() {
    Get.toNamed('/orders/create');
  }

  void navigateToOrderDetails(String orderId) {
    Get.toNamed('/orders/$orderId');
  }

  // Getters
  int get pendingCount => orderCounts[OrderStatus.pending] ?? 0;
  int get processingCount => orderCounts[OrderStatus.processing] ?? 0;
  int get completedCount => orderCounts[OrderStatus.completed] ?? 0;
  int get cancelledCount => orderCounts[OrderStatus.cancelled] ?? 0;
}