// lib/modules/admin/stock/controllers/today_stock_history_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';

class TodayStockHistoryController extends GetxController {
  final StockRepository _stockRepository;

  TodayStockHistoryController({required StockRepository stockRepository})
      : _stockRepository = stockRepository;

  final movements = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  final error = ''.obs;
  
  // Filter type
  final filterType = 'all'.obs; // 'all', 'in', 'out'

  @override
  void onInit() {
    super.onInit();
    loadTodayMovements();
    
    ever(filterType, (_) {
      currentPage.value = 1;
      movements.clear();
      loadTodayMovements();
    });
  }

  Future<void> loadTodayMovements() async {
    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      error.value = '';
      
      // Get today's date range
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Fetch all stock movements
      final allMovements = await _stockRepository.getAllStockHistory(
        page: currentPage.value,
        limit: 50,
      );
      
      // Filter for today's movements
      var todayMovements = allMovements.where((m) {
        final moveDate = DateTime.parse(m['createdAt'] ?? m['date'] ?? '');
        return moveDate.isAfter(startOfDay);
      }).toList();
      
      // Apply type filter
      if (filterType.value == 'in') {
        todayMovements = todayMovements.where((m) => m['type'] == 'stock_in').toList();
      } else if (filterType.value == 'out') {
        todayMovements = todayMovements.where((m) => m['type'] == 'stock_out').toList();
      }
      
      // Sort by time (newest first)
      todayMovements.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt'] ?? a['date'] ?? '');
        final dateB = DateTime.parse(b['createdAt'] ?? b['date'] ?? '');
        return dateB.compareTo(dateA);
      });
      
      if (currentPage.value == 1) {
        movements.value = todayMovements;
      } else {
        movements.addAll(todayMovements);
      }
      
      hasMoreData.value = todayMovements.length == 50;
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading today movements: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await loadTodayMovements();
  }

  Future<void> refreshMovements() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 1;
      movements.clear();
      await loadTodayMovements();
    } finally {
      isRefreshing.value = false;
    }
  }

  void setFilter(String type) {
    filterType.value = type;
  }

  // Getters for stats
  int get totalStockIn {
    return movements
        .where((m) => m['type'] == 'stock_in')
        .fold(0, (sum, m) => sum + (m['quantity'] as int? ?? 0));
  }

  int get totalStockOut {
    return movements
        .where((m) => m['type'] == 'stock_out')
        .fold(0, (sum, m) => sum + (m['quantity'] as int? ?? 0));
  }

  String get pageTitle => 'Today\'s Stock Movements';
}