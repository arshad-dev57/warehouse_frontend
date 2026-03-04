// lib/data/repositories/product_repository.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepository extends GetxService {
  
  // Mock data - ye baad mein API se replace hoga
  final List<ProductModel> _mockProducts = [];
  final List<CategoryModel> _mockCategories = [];

  ProductRepository() {
    _initMockData();
  }

  void _initMockData() {
    // Categories
    _mockCategories.addAll([
      CategoryModel(
        id: 'cat1',
        name: 'Electronics',
        description: 'Mobile, accessories, gadgets',
        color: Colors.blue,
        icon: Icons.devices,
        productCount: 45,
      ),
      CategoryModel(
        id: 'cat2',
        name: 'Medicines',
        description: 'Pharmaceutical products',
        color: Colors.green,
        icon: Icons.medical_services,
        productCount: 128,
      ),
      CategoryModel(
        id: 'cat3',
        name: 'Hardware',
        description: 'Tools, hardware items',
        color: Colors.orange,
        icon: Icons.hardware,
        productCount: 67,
      ),
      CategoryModel(
        id: 'cat4',
        name: 'Garments',
        description: 'Clothing, fabric',
        color: Colors.purple,
        icon: Icons.checkroom,
        productCount: 34,
      ),
    ]);

    // Products
    _mockProducts.addAll([
      ProductModel(
        id: 'p1',
        name: 'iPhone 14 Case',
        sku: 'MB001',
        barcode: '123456789',
        categoryId: 'cat1',
        categoryName: 'Electronics',
        supplierId: 'sup1',
        supplierName: 'Mobile World',
        sellingPrice: 999,
        costPrice: 700,
        currentStock: 45,
        minimumStock: 10,
        maximumStock: 100,
        location: 'A-3-B2',
        imageUrls: ['assets/images/product_placeholder.png'],
        description: 'Premium silicone case for iPhone 14',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p2',
        name: 'Paracetamol 500mg',
        sku: 'MED001',
        barcode: '987654321',
        categoryId: 'cat2',
        categoryName: 'Medicines',
        supplierId: 'sup2',
        supplierName: 'Medico Pharma',
        sellingPrice: 50,
        costPrice: 30,
        currentStock: 8,
        minimumStock: 20,
        maximumStock: 200,
        location: 'B-1-A5',
        imageUrls: ['assets/images/product_placeholder.png'],
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p3',
        name: 'Hammer 500g',
        sku: 'HR001',
        barcode: '456789123',
        categoryId: 'cat3',
        categoryName: 'Hardware',
        supplierId: 'sup3',
        supplierName: 'Tools World',
        sellingPrice: 350,
        costPrice: 250,
        currentStock: 23,
        minimumStock: 5,
        maximumStock: 50,
        location: 'C-2-D4',
        imageUrls: ['assets/images/product_placeholder.png'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p4',
        name: 'T-Shirt Cotton',
        sku: 'GR001',
        barcode: '789123456',
        categoryId: 'cat4',
        categoryName: 'Garments',
        supplierId: 'sup4',
        supplierName: 'Fashion Hub',
        sellingPrice: 799,
        costPrice: 500,
        currentStock: 56,
        minimumStock: 10,
        maximumStock: 100,
        location: 'D-1-E3',
        imageUrls: ['assets/images/product_placeholder.png'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  // Get all products
  Future<List<ProductModel>> getProducts({
    String? searchQuery,
    String? categoryId,
    String? stockStatus,
    String? sortBy,
    bool ascending = true,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<ProductModel> filtered = List.from(_mockProducts);
    
    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (p.barcode?.contains(searchQuery) ?? false)
      ).toList();
    }
    
    // Apply category filter
    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((p) => p.categoryId == categoryId).toList();
    }
    
    // Apply stock status filter
    if (stockStatus != null && stockStatus.isNotEmpty) {
      switch (stockStatus) {
        case 'low_stock':
          filtered = filtered.where((p) => p.isLowStock).toList();
          break;
        case 'out_of_stock':
          filtered = filtered.where((p) => p.isOutOfStock).toList();
          break;
        case 'expiring':
          filtered = filtered.where((p) => p.isExpiringSoon).toList();
          break;
      }
    }
    
    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          filtered.sort((a, b) => ascending 
              ? a.name.compareTo(b.name) 
              : b.name.compareTo(a.name));
          break;
        case 'price':
          filtered.sort((a, b) => ascending 
              ? a.sellingPrice.compareTo(b.sellingPrice) 
              : b.sellingPrice.compareTo(a.sellingPrice));
          break;
        case 'stock':
          filtered.sort((a, b) => ascending 
              ? a.currentStock.compareTo(b.currentStock) 
              : b.currentStock.compareTo(a.currentStock));
          break;
        case 'date':
          filtered.sort((a, b) => ascending 
              ? a.createdAt.compareTo(b.createdAt) 
              : b.createdAt.compareTo(a.createdAt));
          break;
      }
    }
    
    return filtered;
  }

  // Get single product
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add product
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newProduct = ProductModel(
      id: 'p${_mockProducts.length + 1}',
      name: product.name,
      sku: product.sku,
      barcode: product.barcode,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      sellingPrice: product.sellingPrice,
      costPrice: product.costPrice,
      currentStock: product.currentStock,
      minimumStock: product.minimumStock,
      maximumStock: product.maximumStock,
      location: product.location,
      imageUrls: product.imageUrls,
      description: product.description,
      expiryDate: product.expiryDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockProducts.add(newProduct);
    return newProduct;
  }

  // Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final updated = ProductModel(
        id: product.id,
        name: product.name,
        sku: product.sku,
        barcode: product.barcode,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
        supplierId: product.supplierId,
        supplierName: product.supplierName,
        sellingPrice: product.sellingPrice,
        costPrice: product.costPrice,
        currentStock: product.currentStock,
        minimumStock: product.minimumStock,
        maximumStock: product.maximumStock,
        location: product.location,
        imageUrls: product.imageUrls,
        description: product.description,
        expiryDate: product.expiryDate,
        isActive: product.isActive,
        createdAt: _mockProducts[index].createdAt,
        updatedAt: DateTime.now(),
      );
      _mockProducts[index] = updated;
      return updated;
    }
    throw Exception('Product not found');
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _mockProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _mockProducts.removeAt(index);
      return true;
    }
    return false;
  }

  // Get categories
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories;
  }

  // Add category
  Future<CategoryModel> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newCategory = CategoryModel(
      id: 'cat${_mockCategories.length + 1}',
      name: category.name,
      description: category.description,
      color: category.color,
      icon: category.icon,
      productCount: 0,
    );
    _mockCategories.add(newCategory);
    return newCategory;
  }

  // Update category
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _mockCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _mockCategories[index] = category;
      return category;
    }
    throw Exception('Category not found');
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _mockCategories.indexWhere((c) => c.id == id);
    if (index != -1) {
      // Check if category has products
      final hasProducts = _mockProducts.any((p) => p.categoryId == id);
      if (hasProducts) {
        throw Exception('Cannot delete category with products');
      }
      _mockCategories.removeAt(index);
      return true;
    }
    return false;
  }
}