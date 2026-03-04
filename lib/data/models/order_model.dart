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
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
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
      productId: json['productId'],
      productName: json['productName'],
      productSku: json['productSku'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
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
    return OrderModel(
      id: json['id'],
      orderNumber: json['orderNumber'],
      orderDate: DateTime.parse(json['orderDate']),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      status: OrderStatus.values[json['status']],
      subtotal: json['subtotal'].toDouble(),
      discount: json['discount']?.toDouble() ?? 0,
      total: json['total'].toDouble(),
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
}