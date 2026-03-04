// lib/data/repositories/order_repository.dart

import 'package:get/get.dart';
import '../models/order_model.dart';

class OrderRepository extends GetxService {
  
  final List<OrderModel> _orders = [];

  OrderRepository() {
    _initMockData();
  }

  void _initMockData() {
    // Mock orders
    _orders.addAll([
      OrderModel(
        id: '1',
        orderNumber: 'ORD-001',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        customerName: 'Ali Store',
        customerPhone: '0300-1234567',
        items: [
          OrderItem(
            productId: 'p1',
            productName: 'iPhone 14 Case',
            productSku: 'MB001',
            quantity: 5,
            price: 999,
          ),
          OrderItem(
            productId: 'p2',
            productName: 'Screen Guard',
            productSku: 'SG001',
            quantity: 10,
            price: 299,
          ),
        ],
        status: OrderStatus.completed,
        subtotal: 7985,
        discount: 0,
        total: 7985,
        createdBy: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        id: '2',
        orderNumber: 'ORD-002',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        customerName: 'Khan Traders',
        customerPhone: '0301-7654321',
        items: [
          OrderItem(
            productId: 'p3',
            productName: 'Hammer 500g',
            productSku: 'HR001',
            quantity: 3,
            price: 350,
          ),
          OrderItem(
            productId: 'p4',
            productName: 'Screwdriver Set',
            productSku: 'SD001',
            quantity: 2,
            price: 450,
          ),
        ],
        status: OrderStatus.processing,
        subtotal: 1950,
        discount: 50,
        total: 1900,
        createdBy: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        id: '3',
        orderNumber: 'ORD-003',
        orderDate: DateTime.now(),
        customerName: 'Raza Electronics',
        customerPhone: '0302-9876543',
        items: [
          OrderItem(
            productId: 'p1',
            productName: 'iPhone 14 Case',
            productSku: 'MB001',
            quantity: 2,
            price: 999,
          ),
        ],
        status: OrderStatus.pending,
        subtotal: 1998,
        discount: 0,
        total: 1998,
        createdBy: 'Staff',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  // Get all orders
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    var filtered = List<OrderModel>.from(_orders);
    
    if (status != null) {
      filtered = filtered.where((o) => o.status == status).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((o) =>
        o.orderNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (o.customerName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    
    return filtered;
  }

  // Get single order
  Future<OrderModel?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create order
  Future<OrderModel> createOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderNumber: 'ORD-${(_orders.length + 1).toString().padLeft(3, '0')}',
      orderDate: DateTime.now(),
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      customerAddress: order.customerAddress,
      items: order.items,
      status: OrderStatus.pending,
      subtotal: order.subtotal,
      discount: order.discount,
      total: order.total,
      notes: order.notes,
      createdBy: 'Admin',
      createdAt: DateTime.now(),
    );
    
    _orders.add(newOrder);
    return newOrder;
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String id, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final updated = OrderModel(
        id: _orders[index].id,
        orderNumber: _orders[index].orderNumber,
        orderDate: _orders[index].orderDate,
        customerName: _orders[index].customerName,
        customerPhone: _orders[index].customerPhone,
        customerAddress: _orders[index].customerAddress,
        items: _orders[index].items,
        status: status,
        subtotal: _orders[index].subtotal,
        discount: _orders[index].discount,
        total: _orders[index].total,
        notes: _orders[index].notes,
        createdBy: _orders[index].createdBy,
        createdAt: _orders[index].createdAt,
        completedAt: status == OrderStatus.completed ? DateTime.now() : null,
      );
      _orders[index] = updated;
      return updated;
    }
    throw Exception('Order not found');
  }

  // Get orders count by status
  Future<Map<OrderStatus, int>> getOrdersCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      OrderStatus.pending: _orders.where((o) => o.status == OrderStatus.pending).length,
      OrderStatus.processing: _orders.where((o) => o.status == OrderStatus.processing).length,
      OrderStatus.completed: _orders.where((o) => o.status == OrderStatus.completed).length,
      OrderStatus.cancelled: _orders.where((o) => o.status == OrderStatus.cancelled).length,
    };
  }
}