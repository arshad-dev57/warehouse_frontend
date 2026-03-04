// lib/data/repositories/chart_repository.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import '../models/chart_data.dart';
import '../models/category_data.dart';
import 'product_repository.dart';

class ChartRepository extends GetxService {
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  ChartRepository({
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
  })  : _productRepository = productRepository,
        _orderRepository = orderRepository;

  // Get stock movement data for last 7 days
  Future<List<ChartData>> getStockMovementData() async {
    try {
      // In real app, this would come from API
      // For now, return mock data
      return _getMockStockMovement();
    } catch (e) {
      print('Error loading stock movement: $e');
      return _getMockStockMovement();
    }
  }

  // Get category distribution data
  Future<List<CategoryData>> getCategoryDistribution() async {
    try {
      final products = await _productRepository.getProducts();
      final categories = await _productRepository.getCategories();
      
      // Calculate category distribution
      final Map<String, int> categoryCount = {};
      for (var product in products) {
        categoryCount[product.categoryId] = (categoryCount[product.categoryId] ?? 0) + 1;
      }

      final totalProducts = products.length;
      final List<CategoryData> distribution = [];

      for (var category in categories) {
        final count = categoryCount[category.id] ?? 0;
        final percentage = totalProducts > 0 ? (count / totalProducts * 100) : 0;
        
        distribution.add(CategoryData(
          categoryId: category.id,
          categoryName: category.name,
          productCount: count,
          percentage: percentage.toDouble(),
          color: category.color,
        ));
      }

      return distribution;
    } catch (e) {
      print('Error loading category distribution: $e');
      return _getMockCategoryDistribution();
    }
  }

  // Get top products data
  Future<List<ChartData>> getTopProducts({int limit = 5}) async {
    try {
      // This would come from order history in real app
      return _getMockTopProducts(limit);
    } catch (e) {
      return _getMockTopProducts(limit);
    }
  }

  // Get revenue data for last 30 days
  Future<List<ChartData>> getRevenueData() async {
    try {
      return _getMockRevenueData();
    } catch (e) {
      return _getMockRevenueData();
    }
  }

  // MARK: - Mock Data Methods

  List<ChartData> _getMockStockMovement() {
    final now = DateTime.now();
    return [
      ChartData.stockMovement('Mon', 45, now.subtract(const Duration(days: 6))),
      ChartData.stockMovement('Tue', 52, now.subtract(const Duration(days: 5))),
      ChartData.stockMovement('Wed', 38, now.subtract(const Duration(days: 4))),
      ChartData.stockMovement('Thu', 65, now.subtract(const Duration(days: 3))),
      ChartData.stockMovement('Fri', 42, now.subtract(const Duration(days: 2))),
      ChartData.stockMovement('Sat', 58, now.subtract(const Duration(days: 1))),
      ChartData.stockMovement('Sun', 33, now),
    ];
  }

  List<CategoryData> _getMockCategoryDistribution() {
    return [
      CategoryData(
        categoryId: '1',
        categoryName: 'Electronics',
        productCount: 120,
        percentage: 25.0,
        color: Colors.blue,
      ),
      CategoryData(
        categoryId: '2',
        categoryName: 'Medicines',
        productCount: 180,
        percentage: 35.0,
        color: Colors.green,
      ),
      CategoryData(
        categoryId: '3',
        categoryName: 'Hardware',
        productCount: 90,
        percentage: 20.0,
        color: Colors.orange,
      ),
      CategoryData(
        categoryId: '4',
        categoryName: 'Garments',
        productCount: 60,
        percentage: 15.0,
        color: Colors.purple,
      ),
      CategoryData(
        categoryId: '5',
        categoryName: 'Food',
        productCount: 30,
        percentage: 5.0,
        color: Colors.red,
      ),
    ];
  }

  List<ChartData> _getMockTopProducts(int limit) {
    return [
      ChartData(label: 'Paracetamol', value: 150, color: Colors.blue),
      ChartData(label: 'iPhone Case', value: 120, color: Colors.green),
      ChartData(label: 'Hammer', value: 80, color: Colors.orange),
      ChartData(label: 'T-Shirt', value: 60, color: Colors.purple),
      ChartData(label: 'Screwdriver', value: 40, color: Colors.red),
    ].take(limit).toList();
  }

  List<ChartData> _getMockRevenueData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return ChartData.stockMovement(
        '${date.day}/${date.month}',
        5000 + (index * 300) + (index % 5 * 1000),
        date,
      );
    });
  }
}