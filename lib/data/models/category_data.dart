// lib/data/models/category_data.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:warehouse_management_app/data/models/chart_data.dart';

class CategoryData {
  final String categoryId;
  final String categoryName;
  final int productCount;
  final double percentage;
  final Color color;

  CategoryData({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.percentage,
    required this.color,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      productCount: json['productCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      color: _getCategoryColor(json['categoryName'] ?? ''),
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'medicines':
        return Colors.green;
      case 'hardware':
        return Colors.orange;
      case 'garments':
        return Colors.purple;
      case 'food':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Convert to ChartData for pie chart
  ChartData toChartData() {
    return ChartData.category(
      categoryName,
      percentage,
      color,
    );
  }
}