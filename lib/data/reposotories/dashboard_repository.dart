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
    const String functionName = 'getDashboardMetrics';
    print("\n========== 📊 $functionName ==========");
    print("📌 Function: $functionName");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      print("🌐 Calling API: admin/dashboard/metrics");
      final response = await _apiService.get('admin/dashboard/metrics');
      
      print("✅ [$functionName] Response Status: ${response.success}");
      print("📦 [$functionName] Response Data: ${response.data}");
      print("📝 [$functionName] Response Message: ${response.message}");
      
      if (response.success && response.data != null) {
        print("✅ [$functionName] Parsing DashboardModel from JSON");
        print("📊 [$functionName] Data keys: ${response.data.keys}");
        
        // Print individual values
        print("📈 [$functionName] totalProducts: ${response.data['totalProducts']}");
        print("💰 [$functionName] totalStockValue: ${response.data['totalStockValue']}");
        print("⚠️ [$functionName] lowStockCount: ${response.data['lowStockCount']}");
        print("📅 [$functionName] expiringCount: ${response.data['expiringCount']}");
        print("📥 [$functionName] todayStockIn: ${response.data['todayStockIn']}");
        print("📤 [$functionName] todayStockOut: ${response.data['todayStockOut']}");
        print("⏳ [$functionName] pendingOrders: ${response.data['pendingOrders']}");
        
        final dashboardModel = DashboardModel.fromJson(response.data);
        print("✅ [$functionName] DashboardModel created successfully");
        print("========== ✅ END $functionName ==========\n");
        
        return dashboardModel;
      } else {
        print("❌ [$functionName] Failed to load metrics: ${response.message}");
        print("========== ❌ END $functionName (ERROR) ==========\n");
        throw Exception(response.message ?? 'Failed to load metrics');
      }
    } catch (e) {
      print('❌ [$functionName] Error: $e');
      print("========== ❌ END $functionName (EXCEPTION) ==========\n");
      return DashboardModel(
        totalProducts: 0,
        totalStockValue: 0,
        lowStockCount: 0,
        expiringCount: 0,
        todayStockIn: 0,
        todayStockOut: 0,
        pendingOrders: 0,
      );
    }
  }

  // Get recent activities
  Future<List<ActivityModel>> getRecentActivities() async {
    const String functionName = 'getRecentActivities';
    print("\n========== 📋 $functionName ==========");
    print("📌 Function: $functionName");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      print("🌐 [$functionName] Calling API: admin/dashboard/activities");
      final response = await _apiService.get('admin/dashboard/activities');
      
      print("✅ [$functionName] Response Status: ${response.success}");
      print("📦 [$functionName] Response Data: ${response.data}");
      
      if (response.success && response.data != null) {
        List<dynamic> activitiesJson = [];
        
        // Handle different response formats
        if (response.data is Map) {
          print("📋 [$functionName] Response is Map type");
          if (response.data['activities'] != null) {
            activitiesJson = response.data['activities'] as List;
            print("📋 [$functionName] Found 'activities' key with ${activitiesJson.length} items");
          } else {
            print("⚠️ [$functionName] No 'activities' key found in response");
          }
        } else if (response.data is List) {
          print("📋 [$functionName] Response is direct List type with ${response.data.length} items");
          activitiesJson = response.data;
        }
        
        print("📋 [$functionName] Activities JSON length: ${activitiesJson.length}");
        
        if (activitiesJson.isNotEmpty) {
          print("📋 [$functionName] First activity sample: ${activitiesJson.first}");
        } else {
          print("📋 [$functionName] No activities found");
        }
        
        final activities = activitiesJson
            .map((json) {
              print("🔄 [$functionName] Parsing activity: ${json['id']} - ${json['action']}");
              return ActivityModel.fromJson(json);
            })
            .toList();
        
        print("✅ [$functionName] Parsed ${activities.length} activities");
        print("========== ✅ END $functionName ==========\n");
        
        return activities;
      } else {
        print("❌ [$functionName] Failed to load activities: ${response.message}");
        print("========== ❌ END $functionName (ERROR) ==========\n");
        throw Exception(response.message ?? 'Failed to load activities');
      }
    } catch (e) {
      print('❌ [$functionName] Error: $e');
      print("========== ❌ END $functionName (EXCEPTION) ==========\n");
      return [];
    }
  }

  // Get alerts
  Future<List<AlertModel>> getAlerts() async {
    const String functionName = 'getAlerts';
    print("\n========== 🔔 $functionName ==========");
    print("📌 Function: $functionName");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      print("🌐 [$functionName] Calling API: admin/dashboard/alerts");
      final response = await _apiService.get('admin/dashboard/alerts');
      
      print("✅ [$functionName] Response Status: ${response.success}");
      print("📦 [$functionName] Response Data: ${response.data}");
      
      if (response.success && response.data != null) {
        List<dynamic> alertsJson = [];
        
        // Handle different response formats
        if (response.data is Map) {
          print("📋 [$functionName] Response is Map type");
          if (response.data['alerts'] != null) {
            alertsJson = response.data['alerts'] as List;
            print("📋 [$functionName] Found 'alerts' key with ${alertsJson.length} items");
          } else {
            print("⚠️ [$functionName] No 'alerts' key found in response");
          }
        } else if (response.data is List) {
          print("📋 [$functionName] Response is direct List type with ${response.data.length} items");
          alertsJson = response.data;
        }
        
        print("📋 [$functionName] Alerts JSON length: ${alertsJson.length}");
        
        if (alertsJson.isNotEmpty) {
          print("📋 [$functionName] First alert sample: ${alertsJson.first}");
        } else {
          print("📋 [$functionName] No alerts found");
        }
        
        final alerts = alertsJson
            .map((json) {
              print("🔄 [$functionName] Parsing alert: ${json['id']} - ${json['title']}");
              return AlertModel.fromJson(json);
            })
            .toList();
        
        print("✅ [$functionName] Parsed ${alerts.length} alerts");
        print("========== ✅ END $functionName ==========\n");
        
        return alerts;
      } else {
        print("❌ [$functionName] Failed to load alerts: ${response.message}");
        print("========== ❌ END $functionName (ERROR) ==========\n");
        throw Exception(response.message ?? 'Failed to load alerts');
      }
    } catch (e) {
      print('❌ [$functionName] Error: $e');
      print("========== ❌ END $functionName (EXCEPTION) ==========\n");
      return [];
    }
  }

  // Get stock movement chart data
  Future<List<ChartData>> getStockMovementChart() async {
    const String functionName = 'getStockMovementChart';
    print("\n========== 📈 $functionName ==========");
    print("📌 Function: $functionName");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      print("🌐 [$functionName] Calling API: admin/dashboard/charts/stock-movement");
      final response = await _apiService.get('admin/dashboard/charts/stock-movement');
      
      print("✅ [$functionName] Response Status: ${response.success}");
      print("📦 [$functionName] Response Data: ${response.data}");
      
      if (response.success && response.data != null) {
        List<dynamic> chartJson = [];
        
        // Handle different response formats
        if (response.data is Map) {
          print("📋 [$functionName] Response is Map type");
          if (response.data['data'] != null) {
            chartJson = response.data['data'] as List;
            print("📋 [$functionName] Found 'data' key with ${chartJson.length} items");
          } else {
            print("⚠️ [$functionName] No 'data' key found in response");
          }
        } else if (response.data is List) {
          print("📋 [$functionName] Response is direct List type with ${response.data.length} items");
          chartJson = response.data;
        }
        
        print("📋 [$functionName] Chart JSON length: ${chartJson.length}");
        
        if (chartJson.isNotEmpty) {
          print("📋 [$functionName] First chart item sample: ${chartJson.first}");
        } else {
          print("📋 [$functionName] No chart data found");
        }
        
        final chartData = chartJson
            .map((json) {
              print("🔄 [$functionName] Parsing chart data: ${json['label']} = ${json['value']}");
              return ChartData.fromJson(json);
            })
            .toList();
        
        print("✅ [$functionName] Parsed ${chartData.length} chart items");
        print("========== ✅ END $functionName ==========\n");
        
        return chartData;
      } else {
        print("❌ [$functionName] Failed to load chart data: ${response.message}");
        print("========== ❌ END $functionName (ERROR) ==========\n");
        throw Exception(response.message ?? 'Failed to load chart data');
      }
    } catch (e) {
      print('❌ [$functionName] Error: $e');
      print("========== ❌ END $functionName (EXCEPTION) ==========\n");
      return [];
    }
  }

  // Get category distribution
  Future<List<CategoryData>> getCategoryDistribution() async {
    const String functionName = 'getCategoryDistribution';
    print("\n========== 🏷️ $functionName ==========");
    print("📌 Function: $functionName");
    print("⏰ Time: ${DateTime.now()}");
    
    try {
      print("🌐 [$functionName] Calling API: admin/dashboard/charts/categories");
      final response = await _apiService.get('admin/dashboard/charts/categories');
      
      print("✅ [$functionName] Response Status: ${response.success}");
      print("📦 [$functionName] Response Data: ${response.data}");
      
      if (response.success && response.data != null) {
        List<dynamic> categoryJson = [];
        
        // Handle different response formats
        if (response.data is Map) {
          print("📋 [$functionName] Response is Map type");
          if (response.data['categories'] != null) {
            categoryJson = response.data['categories'] as List;
            print("📋 [$functionName] Found 'categories' key with ${categoryJson.length} items");
          } else if (response.data['data'] != null && response.data['data']['categories'] != null) {
            // Handle nested structure
            categoryJson = response.data['data']['categories'] as List;
            print("📋 [$functionName] Found nested 'data.categories' with ${categoryJson.length} items");
          } else {
            print("⚠️ [$functionName] No 'categories' key found in response");
          }
        } else if (response.data is List) {
          print("📋 [$functionName] Response is direct List type with ${response.data.length} items");
          categoryJson = response.data;
        }
        
        print("📋 [$functionName] Category JSON length: ${categoryJson.length}");
        
        if (categoryJson.isNotEmpty) {
          print("📋 [$functionName] First category sample: ${categoryJson.first}");
        } else {
          print("📋 [$functionName] No category data found");
        }
        
        final categoryData = categoryJson
            .map((json) {
              print("🔄 [$functionName] Parsing category: ${json['categoryName']} - ${json['productCount']} products");
              return CategoryData.fromJson(json);
            })
            .toList();
        
        print("✅ [$functionName] Parsed ${categoryData.length} categories");
        print("========== ✅ END $functionName ==========\n");
        
        return categoryData;
      } else {
        print("❌ [$functionName] Failed to load categories: ${response.message}");
        print("========== ❌ END $functionName (ERROR) ==========\n");
        throw Exception(response.message ?? 'Failed to load categories');
      }
    } catch (e) {
      print('❌ [$functionName] Error: $e');
      print("========== ❌ END $functionName (EXCEPTION) ==========\n");
      return [];
    }
  }
}