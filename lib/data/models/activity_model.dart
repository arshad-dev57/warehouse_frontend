// lib/data/models/activity_model.dart

import 'package:flutter/material.dart';

class ActivityModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String action;
  final String actionType; // stock_in, stock_out, order, etc.
  final String productName;
  final int quantity;
  final String time;
  final String timeAgo;
  final bool isRead;

  ActivityModel({
    required this.id,
    required this.userName,
    this.userAvatar = '',
    required this.action,
    required this.actionType,
    required this.productName,
    required this.quantity,
    required this.time,
    required this.timeAgo,
    this.isRead = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      action: json['action'] ?? '',
      actionType: json['actionType'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      time: json['time'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  // Get icon based on action type
  IconData getIcon() {
    switch (actionType) {
      case 'stock_in':
        return Icons.arrow_downward;
      case 'stock_out':
        return Icons.arrow_upward;
      case 'order':
        return Icons.shopping_cart;
      case 'add':
        return Icons.add_box;
      default:
        return Icons.circle;
    }
  }

  // Get color based on action type
  Color getColor() {
    switch (actionType) {
      case 'stock_in':
        return Colors.green;
      case 'stock_out':
        return Colors.orange;
      case 'order':
        return Colors.blue;
      case 'add':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}