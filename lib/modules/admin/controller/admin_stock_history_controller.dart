// lib/modules/admin/stock/controllers/stock_history_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';

class StockHistoryController extends GetxController {
  final StockRepository _stockRepository;

  StockHistoryController({required StockRepository stockRepository})
      : _stockRepository = stockRepository;

  final movements = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  final error = ''.obs;
  
  // Product info
  String? productId;
  String? productName;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments
    if (Get.arguments != null) {
      productId = Get.arguments['productId'];
      productName = Get.arguments['productName'];
      print("Product ID: $productId");
      print("Product Name: $productName");
    }
    
    loadMovements();
  }

  // 🔥 MAIN LOAD MOVEMENTS METHOD
  Future<void> loadMovements() async {
    // Validate productId
    if (productId == null || productId!.isEmpty) {
      error.value = 'Product ID is required';
      isLoading.value = false;
      return;
    }

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      error.value = '';
      
      print("Loading movements for product: $productId, Page: ${currentPage.value}");
      
      final result = await _stockRepository.getStockHistory(
        productId: productId!,
        page: currentPage.value,
        limit: 20,
      );
      
      print("Result success: ${result['success']}");
      print("Data length: ${result['data']?.length}");
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        
        if (currentPage.value == 1) {
          movements.value = List<Map<String, dynamic>>.from(data);
        } else {
          movements.addAll(List<Map<String, dynamic>>.from(data));
        }
        
        final pagination = result['pagination'];
        if (pagination != null) {
          final totalPages = pagination['pages'] ?? 1;
          hasMoreData.value = currentPage.value < totalPages;
          print("Page ${currentPage.value} of $totalPages, hasMore: ${hasMoreData.value}");
        }
      } else {
        error.value = result['message'] ?? 'Failed to load history';
      }
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading movements: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  // Load more data (pagination)
  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) {
      print("Cannot load more - hasMore: ${hasMoreData.value}, isLoadingMore: ${isLoadingMore.value}");
      return;
    }
    currentPage.value++;
    print("Loading more... Page: ${currentPage.value}");
    await loadMovements();
  }

  // Refresh data (pull to refresh)
  Future<void> refreshMovements() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 1;
      movements.clear();
      await loadMovements();
    } finally {
      isRefreshing.value = false;
    }
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

  String get pageTitle {
    if (productName != null && productName!.isNotEmpty) {
      return '$productName - History';
    }
    return 'Stock History';
  }
}