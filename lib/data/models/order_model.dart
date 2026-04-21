// lib/data/models/order_model.dart

import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.price,
  }) : total = price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productSku: json['productSku']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<OrderItem> items;
  final OrderStatus status;
  final double subtotal;
  final double discount;
  final double total;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.status,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
  });

  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.index,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // 🔥 FIXED: Handle createdBy which can be either String or Object
    String createdBy = '';
    
    if (json['createdBy'] is Map) {
      // If createdBy is an object with user details (from populate)
      final userObj = json['createdBy'] as Map<String, dynamic>;
      createdBy = userObj['name']?.toString() ?? userObj['email']?.toString() ?? 'Unknown';
      print("👤 User object found: $createdBy"); // Debug
    } else {
      // If createdBy is just a string ID (fallback)
      createdBy = json['createdBy']?.toString() ?? 'Unknown';
      print("🆔 User ID only: $createdBy"); // Debug
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? 'ORD-000',
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      customerName: json['customerName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      customerAddress: json['customerAddress']?.toString(),
      items: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status']?.toString().toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      notes: json['notes']?.toString(),
      createdBy: createdBy,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
    );
  }
}