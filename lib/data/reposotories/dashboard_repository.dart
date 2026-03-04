// lib/data/repositories/dashboard_repository.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import '../models/dashboard_model.dart';
import '../models/activity_model.dart';
import '../models/alert_model.dart';
import '../models/chart_data.dart';
import '../models/category_data.dart';

class DashboardRepository extends GetxService {
  final ApiService _apiService;

  DashboardRepository({required ApiService apiService}) 
      : _apiService = apiService;

  // Get dashboard metrics
  Future<DashboardModel> getDashboardMetrics() async {
    try {
      final response = await _apiService.get('admin/dashboard/metrics');
      
      if (response.success && response.data != null) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to load metrics');
      }
    } catch (e) {
      print('Error loading metrics: $e');
      // Return mock data for development
      return _getMockDashboardMetrics();
    }
  }

  // Get recent activities
  Future<List<ActivityModel>> getRecentActivities() async {
    try {
      final response = await _apiService.get('admin/dashboard/activities');
      
      if (response.success && response.data != null) {
        List<dynamic> activitiesJson = response.data['activities'] ?? [];
        return activitiesJson
            .map((json) => ActivityModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to load activities');
      }
    } catch (e) {
      print('Error loading activities: $e');
      return _getMockActivities();
    }
  }

  // Get alerts
  Future<List<AlertModel>> getAlerts() async {
    try {
      final response = await _apiService.get('admin/dashboard/alerts');
      
      if (response.success && response.data != null) {
        List<dynamic> alertsJson = response.data['alerts'] ?? [];
        return alertsJson
            .map((json) => AlertModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to load alerts');
      }
    } catch (e) {
      print('Error loading alerts: $e');
      return _getMockAlerts();
    }
  }

  // Get stock movement chart data
  Future<List<ChartData>> getStockMovementChart() async {
    try {
      final response = await _apiService.get('admin/dashboard/charts/stock-movement');
      
      if (response.success && response.data != null) {
        List<dynamic> chartJson = response.data['data'] ?? [];
        return chartJson
            .map((json) => ChartData.fromJson(json))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to load chart data');
      }
    } catch (e) {
      print('Error loading stock movement: $e');
      return _getMockStockMovement();
    }
  }

  // Get category distribution
  Future<List<CategoryData>> getCategoryDistribution() async {
    try {
      final response = await _apiService.get('admin/dashboard/charts/categories');
      
      if (response.success && response.data != null) {
        List<dynamic> categoryJson = response.data['categories'] ?? [];
        return categoryJson
            .map((json) => CategoryData.fromJson(json))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to load categories');
      }
    } catch (e) {
      print('Error loading categories: $e');
      return _getMockCategories();
    }
  }

  // MARK: - Mock Data for Development

  DashboardModel _getMockDashboardMetrics() {
    return DashboardModel(
      totalProducts: 5234,
      totalStockValue: 4567890,
      lowStockCount: 12,
      expiringCount: 8,
      todayStockIn: 150,
      todayStockOut: 87,
      pendingOrders: 24,
    );
  }

  List<ActivityModel> _getMockActivities() {
    return [
      ActivityModel(
        id: '1',
        userName: 'Ali Raza',
        action: 'added new stock',
        actionType: 'stock_in',
        productName: 'iPhone 14 Case',
        quantity: 50,
        time: '2024-01-15 10:30:00',
        timeAgo: '10 min ago',
      ),
      ActivityModel(
        id: '2',
        userName: 'Sara Khan',
        action: 'removed stock for order',
        actionType: 'stock_out',
        productName: 'Paracetamol',
        quantity: 20,
        time: '2024-01-15 09:45:00',
        timeAgo: '55 min ago',
      ),
      ActivityModel(
        id: '3',
        userName: 'Ahmed Malik',
        action: 'processed order',
        actionType: 'order',
        productName: 'Multiple items',
        quantity: 5,
        time: '2024-01-15 09:15:00',
        timeAgo: '1 hour ago',
      ),
      ActivityModel(
        id: '4',
        userName: 'Fatima Ali',
        action: 'added new product',
        actionType: 'add',
        productName: 'Hammer 500g',
        quantity: 30,
        time: '2024-01-15 08:30:00',
        timeAgo: '2 hours ago',
      ),
    ];
  }

  List<AlertModel> _getMockAlerts() {
    return [
      AlertModel(
        id: '1',
        type: 'low_stock',
        severity: 'high',
        title: 'Low Stock Alert',
        message: 'Paracetamol is running low. Only 8 units left.',
        productName: 'Paracetamol 500mg',
        productId: 'P123',
        currentStock: 8,
        minStock: 20,
        time: '2024-01-15 10:00:00',
        timeAgo: '30 min ago',
      ),
      AlertModel(
        id: '2',
        type: 'expiry',
        severity: 'medium',
        title: 'Expiry Warning',
        message: '5 medicines will expire in 30 days.',
        productName: 'Various Medicines',
        currentStock: 120,
        expiryDate: DateTime.now().add(const Duration(days: 25)),
        time: '2024-01-15 09:00:00',
        timeAgo: '1 hour ago',
      ),
      AlertModel(
        id: '3',
        type: 'low_stock',
        severity: 'medium',
        title: 'Low Stock Alert',
        message: 'Hammer 500g stock is below reorder level.',
        productName: 'Hammer 500g',
        productId: 'H456',
        currentStock: 5,
        minStock: 15,
        time: '2024-01-15 08:00:00',
        timeAgo: '2 hours ago',
      ),
    ];
  }

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

  List<CategoryData> _getMockCategories() {
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
}