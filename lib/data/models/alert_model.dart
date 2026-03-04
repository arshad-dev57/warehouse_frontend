// lib/data/models/alert_model.dart

import 'package:flutter/material.dart';

class AlertModel {
  final String id;
  final String type; // low_stock, expiry, damage, etc.
  final String severity; // high, medium, low
  final String title;
  final String message;
  final String productName;
  final String? productId;
  final int currentStock;
  final int? minStock;
  final DateTime? expiryDate;
  final String time;
  final String timeAgo;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.productName,
    this.productId,
    required this.currentStock,
    this.minStock,
    this.expiryDate,
    required this.time,
    required this.timeAgo,
    this.isRead = false,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'low',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      productName: json['productName'] ?? '',
      productId: json['productId'],
      currentStock: json['currentStock'] ?? 0,
      minStock: json['minStock'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      time: json['time'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  // Get color based on severity
  Color getSeverityColor() {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Get icon based on type
  IconData getIcon() {
    switch (type) {
      case 'low_stock':
        return Icons.inventory;
      case 'expiry':
        return Icons.event;
      case 'damage':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }
}