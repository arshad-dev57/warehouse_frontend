// lib/data/models/product_model.dart

import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String categoryId;
  final String categoryName;
  final String? supplierId;
  final String? supplierName;
  final double sellingPrice;
  final double costPrice;
  final int currentStock;
  final int minimumStock;
  final int maximumStock;
  final String location;
  final List<String> imageUrls;
  final String? description;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.categoryId,
    required this.categoryName,
    this.supplierId,
    this.supplierName,
    required this.sellingPrice,
    required this.costPrice,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.location,
    this.imageUrls = const [],
    this.description,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated properties
  double get profit => sellingPrice - costPrice;
  double get profitMargin => ((profit / costPrice) * 100).clamp(0, 100);
  
  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock == 0;
  bool get isOverstock => currentStock >= maximumStock;
  
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft <= 30 && daysLeft > 0;
  }
  
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    if (isOverstock) return 'Overstock';
    return 'In Stock';
  }

  Color get stockStatusColor {
    if (isOutOfStock) return Colors.red;
    if (isLowStock) return Colors.orange;
    if (isOverstock) return Colors.blue;
    return Colors.green;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle categoryId which can be either String or Object
    String categoryId = '';
    String categoryName = json['categoryName'] ?? '';
    
    if (json['categoryId'] is Map) {
      // If categoryId is an object
      final categoryObj = json['categoryId'] as Map<String, dynamic>;
      categoryId = categoryObj['_id']?.toString() ?? categoryObj['id']?.toString() ?? '';
      if (categoryName.isEmpty) {
        categoryName = categoryObj['name'] ?? '';
      }
    } else {
      // If categoryId is a string
      categoryId = json['categoryId']?.toString() ?? '';
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode']?.toString(),
      categoryId: categoryId,
      categoryName: categoryName,
      supplierId: json['supplierId']?.toString(),
      supplierName: json['supplierName']?.toString(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      currentStock: json['currentStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 5,
      maximumStock: json['maximumStock'] ?? 100,
      location: json['location'] ?? 'A-1-B1',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      description: json['description'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.tryParse(json['expiryDate']) 
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'location': location,
      'imageUrls': imageUrls,
      'description': description,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    String? supplierId,
    String? supplierName,
    double? sellingPrice,
    double? costPrice,
    int? currentStock,
    int? minimumStock,
    int? maximumStock,
    String? location,
    List<String>? imageUrls,
    String? description,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}