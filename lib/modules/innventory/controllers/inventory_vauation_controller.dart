// lib/modules/admin/inventory/controllers/inventory_valuation_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/inventory_repository.dart';

class InventoryValuationController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Data
  final items = <Map<String, dynamic>>[].obs;
  final filteredItems = <Map<String, dynamic>>[].obs;
  final summary = {}.obs;
  final categoryBreakdown = <Map<String, dynamic>>[].obs;

  // Filters
  final selectedCategory = 'all'.obs;
  final selectedZone = 'All'.obs;
  final searchQuery = ''.obs;
  final sortBy = 'Total Value'.obs;
  final sortOrder = 'desc'.obs;

  // Filter options
  final zones = <String>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final sortOptions = <String>[
    'Total Value', 
    'Qty', 
    'Unit Cost', 
    'Days in Stock', 
    'Profit Margin',
    'Name'
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    
    debounce(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 500),
    );
  }


// lib/modules/admin/inventory/controllers/inventory_valuation_controller.dart

// Add this method to ensure zone values are valid
void _ensureValidSelections() {
  // Ensure selectedZone is in zones list
  if (!zones.contains(selectedZone.value) && zones.isNotEmpty) {
    selectedZone.value = 'All';
  }
  
  // Ensure selectedCategory is valid
  if (selectedCategory.value != 'all' && 
      !categories.any((c) => c['id'] == selectedCategory.value)) {
    selectedCategory.value = 'all';
  }
  
  // Ensure sortBy is in sortOptions
  if (!sortOptions.contains(sortBy.value)) {
    sortBy.value = 'Total Value';
  }
}

// Call this after loading data
Future<void> loadData() async {
  try {
    isLoading.value = true;
    
    print("📦 Loading inventory valuation data...");
    
    final result = await _repository.getInventoryValuation(
      category: selectedCategory.value != 'all' ? selectedCategory.value : null,
      search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      sortBy: _getApiSortField(),
      sortOrder: sortOrder.value,
    );

    print("✅ Data loaded: ${result['items']?.length} items");
    
    // Process items
    final rawItems = List<Map<String, dynamic>>.from(result['items'] ?? []);
    items.value = rawItems.map((item) => _castItemValues(item)).toList();
    
    summary.value = Map<String, dynamic>.from(result['summary'] ?? {});
    categoryBreakdown.value = List<Map<String, dynamic>>.from(result['categoryBreakdown'] ?? []);
    
    // Extract categories and zones
    _extractCategories();
    _extractZones();
    
    // 🔥 FIX: Ensure selections are valid
    _ensureValidSelections();
    
    applyFilters();
    
  } catch (e) {
    print('❌ Error loading inventory valuation: $e');
  } finally {
    isLoading.value = false;
  }
}
  // 🔥 FIXED: Safe type conversion for all values
  Map<String, dynamic> _castItemValues(Map<String, dynamic> item) {
    return {
      'id': item['id'] ?? '',
      'name': item['name'] ?? '',
      'sku': item['sku'] ?? '',
      'category': item['category'] ?? '',
      'categoryId': item['categoryId'] ?? '',
      'qty': _toInt(item['qty']),
      'unitCost': _toDouble(item['unitCost']),
      'sellingPrice': _toDouble(item['sellingPrice']),
      'totalCostValue': _toDouble(item['totalCostValue']),
      'sellingValue': _toDouble(item['sellingValue']),
      'potentialProfit': _toDouble(item['potentialProfit']),
      'profitMargin': _toDouble(item['profitMargin']), // 🔥 Now handles String
      'minStock': _toInt(item['minStock']),
      'maxStock': _toInt(item['maxStock']),
      'daysInStock': _toInt(item['daysInStock']),
      'status': item['status'] ?? 'OK',
      'location': item['location'] ?? '',
      'expiryDate': item['expiryDate'],
    };
  }

  // 🔥 NEW: Safe conversion to double (handles String, int, double)
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // 🔥 NEW: Safe conversion to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return double.parse(value).toInt();
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      await loadData();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _extractCategories() {
    final uniqueCategories = <String, String>{};
    for (var item in items) {
      if (item['category'] != null && item['categoryId'] != null) {
        uniqueCategories[item['categoryId']] = item['category'];
      }
    }
    
    final categoryList = uniqueCategories.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
    
    categories.value = [
      {'id': 'all', 'name': 'All Categories'},
      ...categoryList,
    ];
  }

  void _extractZones() {
    final uniqueZones = <String>{'All'};
    for (var item in items) {
      if (item['location'] != null && item['location'].toString().isNotEmpty) {
        final location = item['location'].toString();
        if (location.contains('-')) {
          final zone = location.split('-')[0];
          uniqueZones.add('Zone $zone');
        }
      }
    }
    zones.value = uniqueZones.toList()..sort();
  }

  String _getApiSortField() {
    switch (sortBy.value) {
      case 'Total Value': return 'totalCostValue';
      case 'Qty': return 'qty';
      case 'Unit Cost': return 'unitCost';
      case 'Days in Stock': return 'daysInStock';
      case 'Profit Margin': return 'profitMargin';
      case 'Name': return 'name';
      default: return 'name';
    }
  }

  void applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(items);

    // Apply category filter
    if (selectedCategory.value != 'all') {
      filtered = filtered.where((item) => 
        item['categoryId'] == selectedCategory.value
      ).toList();
    }

    // Apply zone filter
    if (selectedZone.value != 'All') {
      final zoneLetter = selectedZone.value.replaceAll('Zone ', '');
      filtered = filtered.where((item) {
        final location = item['location'] ?? '';
        return location.toString().startsWith(zoneLetter);
      }).toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) =>
        item['name'].toString().toLowerCase().contains(query) ||
        item['sku'].toString().toLowerCase().contains(query) ||
        item['category'].toString().toLowerCase().contains(query)
      ).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (sortBy.value) {
        case 'Total Value':
          return sortOrder.value == 'asc'
              ? (a['totalCostValue'] ?? 0).compareTo(b['totalCostValue'] ?? 0)
              : (b['totalCostValue'] ?? 0).compareTo(a['totalCostValue'] ?? 0);
        case 'Qty':
          return sortOrder.value == 'asc'
              ? (a['qty'] ?? 0).compareTo(b['qty'] ?? 0)
              : (b['qty'] ?? 0).compareTo(a['qty'] ?? 0);
        case 'Unit Cost':
          return sortOrder.value == 'asc'
              ? (a['unitCost'] ?? 0).compareTo(b['unitCost'] ?? 0)
              : (b['unitCost'] ?? 0).compareTo(a['unitCost'] ?? 0);
        case 'Days in Stock':
          return sortOrder.value == 'asc'
              ? (a['daysInStock'] ?? 0).compareTo(b['daysInStock'] ?? 0)
              : (b['daysInStock'] ?? 0).compareTo(a['daysInStock'] ?? 0);
        case 'Profit Margin':
          return sortOrder.value == 'asc'
              ? (a['profitMargin'] ?? 0).compareTo(b['profitMargin'] ?? 0)
              : (b['profitMargin'] ?? 0).compareTo(a['profitMargin'] ?? 0);
        case 'Name':
          return sortOrder.value == 'asc'
              ? a['name'].toString().compareTo(b['name'].toString())
              : b['name'].toString().compareTo(a['name'].toString());
        default:
          return 0;
      }
    });

    filteredItems.value = filtered;
  }

  void setCategoryFilter(String categoryId) {
    selectedCategory.value = categoryId;
    applyFilters();
  }

  void setZoneFilter(String zone) {
    selectedZone.value = zone;
    applyFilters();
  }

  void setSort(String field) {
    if (sortBy.value == field) {
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortOrder.value = 'desc';
    }
    applyFilters();
  }

  void clearFilters() {
    selectedCategory.value = 'all';
    selectedZone.value = 'All';
    searchQuery.value = '';
    sortBy.value = 'Total Value';
    sortOrder.value = 'desc';
    applyFilters();
  }

  // Summary getters with safe conversion
  double get totalCostValue => _toDouble(summary['totalCostValue']);
  double get totalSellingValue => _toDouble(summary['totalSellingValue']);
  double get totalPotentialProfit => _toDouble(summary['totalPotentialProfit']);
  int get lowStockCount => _toInt(summary['lowStockCount']);
  int get overStockCount => _toInt(summary['overStockCount']);
  int get totalItems => _toInt(summary['totalItems']);
  int get totalQty => _toInt(summary['totalQty']);
  
  double get deadStockValue {
    return items
        .where((item) => (item['daysInStock'] ?? 0) > 90)
        .fold<double>(0.0, (sum, item) => sum + _toDouble(item['totalCostValue']));
  }
  
  int get fastMovingCount {
    return items
        .where((item) => (item['daysInStock'] ?? 0) < 15 && (item['qty'] ?? 0) > 50)
        .length;
  }
  
  int get deadStockCount {
    return items
        .where((item) => (item['daysInStock'] ?? 0) > 90)
        .length;
  }

  // Format currency helper
  String formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  // Get status from item
  String getItemStatus(Map<String, dynamic> item) {
    final qty = _toInt(item['qty']);
    final minStock = _toInt(item['minStock']);
    final maxStock = _toInt(item['maxStock']);
    final daysInStock = _toInt(item['daysInStock']);

    if (qty <= minStock) return 'LOW';
    if (maxStock > 0 && qty >= maxStock * 1.2) return 'OVER';
    if (daysInStock > 90) return 'DEAD';
    if (daysInStock < 15 && qty > 50) return 'FAST';
    return 'OK';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'LOW': return Colors.orange;
      case 'OVER': return Colors.orange.shade700;
      case 'DEAD': return Colors.red;
      case 'FAST': return Colors.green;
      default: return Colors.blue;
    }
  }
}