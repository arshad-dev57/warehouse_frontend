// lib/modules/admin/alerts/controllers/alerts_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/alert_repository.dart';
import '../../../../data/models/alert_model.dart';


class AlertsController extends GetxController {
  final AlertRepository _alertRepository;

  AlertsController({required AlertRepository alertRepository})
      : _alertRepository = alertRepository;

  final alerts = <AlertModel>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final filterType = 'all'.obs; // all, unread, low_stock, expiry, damage

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
    
    ever(filterType, (_) => loadAlerts());
  }

  Future<void> loadAlerts() async {
    try {
      isLoading.value = true;
      
      final allAlerts = await _alertRepository.getAlerts();
      
      // Apply filter
      switch(filterType.value) {
        case 'unread':
          alerts.value = allAlerts.where((a) => !a.isRead).toList();
          break;
        case 'low_stock':
          alerts.value = allAlerts.where((a) => a.type == 'low_stock').toList();
          break;
        case 'expiry':
          alerts.value = allAlerts.where((a) => a.type == 'expiry').toList();
          break;
        case 'damage':
          alerts.value = allAlerts.where((a) => a.type == 'damage').toList();
          break;
        default:
          alerts.value = allAlerts;
      }
      
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAlerts() async {
    try {
      isRefreshing.value = true;
      await loadAlerts();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    await _alertRepository.markAsRead(id);
    
    // Update local list
    final index = alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alert = alerts[index];
      alerts[index] = AlertModel(
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
      alerts.refresh();
    }
  }

  Future<void> markAllAsRead() async {
    await _alertRepository.markAllAsRead();
    
    for (var i = 0; i < alerts.length; i++) {
      final alert = alerts[i];
      alerts[i] = AlertModel(
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
    alerts.refresh();
    
    Get.snackbar(
      'Success',
      'All alerts marked as read',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> dismissAlert(String id) async {
    await _alertRepository.dismissAlert(id);
    alerts.removeWhere((a) => a.id == id);
    
    Get.snackbar(
      'Success',
      'Alert dismissed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void onAlertTap(AlertModel alert) async {
    // Mark as read
    if (!alert.isRead) {
      await markAsRead(alert.id);
    }
    
    // Navigate based on type
    switch(alert.type) {
      case 'low_stock':
        if (alert.productId != null) {
          Get.toNamed(
            '${AppRoutes.stockIn}',
            arguments: {'productId': alert.productId},
          );
        } else {
          Get.toNamed('${AppRoutes.adminproducts}?filter=low_stock');
        }
        break;
      case 'expiry':
        Get.toNamed('${AppRoutes.adminproducts}?filter=expiring');
        break;
      case 'damage':
        Get.toNamed('/admin/reports/damage');
        break;
      default:
        if (alert.productId != null) {
          Get.toNamed('${AppRoutes.productDetail}'.replaceFirst(':productId', alert.productId!));
        }
    }
  }

  void setFilter(String type) {
    filterType.value = type;
  }

  int get unreadCount => alerts.where((a) => !a.isRead).length;
}