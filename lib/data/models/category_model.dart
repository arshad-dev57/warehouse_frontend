// lib/data/models/category_model.dart

import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final Color color;
  final IconData icon;
  final int productCount;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    this.productCount = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      color: _getColorFromString(json['color'] ?? 'blue'),
      icon: _getIconFromString(json['icon'] ?? 'inventory'),
      productCount: json['productCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  static Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      default: return Colors.grey;
    }
  }

  static IconData _getIconFromString(String icon) {
    switch (icon.toLowerCase()) {
      case 'electronics': return Icons.devices;
      case 'medicine': return Icons.medical_services;
      case 'hardware': return Icons.hardware;
      case 'garments': return Icons.checkroom;
      case 'food': return Icons.fastfood;
      case 'furniture': return Icons.chair;
      default: return Icons.inventory;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.toString(),
      'icon': icon.toString(),
      'productCount': productCount,
      'isActive': isActive,
    };
  }
}