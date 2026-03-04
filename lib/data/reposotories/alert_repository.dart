// lib/data/repositories/alert_repository.dart

import 'package:get/get.dart';
import '../models/alert_model.dart';

class AlertRepository extends GetxService {
  
  final List<AlertModel> _alerts = [];

  AlertRepository() {
    _initMockData();
  }

  void _initMockData() {
    _alerts.addAll([
      AlertModel(
        id: '1',
        type: 'low_stock',
        severity: 'high',
        title: 'Low Stock Alert',
        message: 'Paracetamol is running low. Only 8 units left.',
        productName: 'Paracetamol 500mg',
        productId: 'p2',
        currentStock: 8,
        minStock: 20,
        time: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        timeAgo: '30 min ago',
        isRead: false,
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
        time: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        timeAgo: '1 hour ago',
        isRead: false,
      ),
      AlertModel(
        id: '3',
        type: 'low_stock',
        severity: 'medium',
        title: 'Low Stock Alert',
        message: 'Hammer 500g stock is below reorder level.',
        productName: 'Hammer 500g',
        productId: 'p3',
        currentStock: 5,
        minStock: 15,
        time: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        timeAgo: '2 hours ago',
        isRead: true,
      ),
      AlertModel(
        id: '4',
        type: 'damage',
        severity: 'high',
        title: 'Damaged Items',
        message: '3 items reported damaged in Aisle B.',
        productName: 'Multiple Items',
        currentStock: 3,
        time: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        timeAgo: '3 hours ago',
        isRead: false,
      ),
    ]);
  }

  // Get all alerts
  Future<List<AlertModel>> getAlerts({bool? unreadOnly}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var filtered = List<AlertModel>.from(_alerts);
    
    if (unreadOnly == true) {
      filtered = filtered.where((a) => !a.isRead).toList();
    }
    
    // Sort by time (newest first)
    filtered.sort((a, b) => b.time.compareTo(a.time));
    
    return filtered;
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _alerts.where((a) => !a.isRead).length;
  }

  // Mark alert as read
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alert = _alerts[index];
      _alerts[index] = AlertModel(
        id: alert.id,
        type: alert.type,
        severity: alert.severity,
        title: alert.title,
        message: alert.message,
        productName: alert.productName,
        productId: alert.productId,
        currentStock: alert.currentStock,
        minStock: alert.minStock,
        expiryDate: alert.expiryDate,
        time: alert.time,
        timeAgo: alert.timeAgo,
        isRead: true,
      );
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _alerts.length; i++) {
      final alert = _alerts[i];
      _alerts[i] = AlertModel(
        id: alert.id,
        type: alert.type,
        severity: alert.severity,
        title: alert.title,
        message: alert.message,
        productName: alert.productName,
        productId: alert.productId,
        currentStock: alert.currentStock,
        minStock: alert.minStock,
        expiryDate: alert.expiryDate,
        time: alert.time,
        timeAgo: alert.timeAgo,
        isRead: true,
      );
    }
  }

  // Dismiss alert
  Future<void> dismissAlert(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _alerts.removeWhere((a) => a.id == id);
  }

  // Add new alert (for testing)
  void addAlert(AlertModel alert) {
    _alerts.add(alert);
  }
}