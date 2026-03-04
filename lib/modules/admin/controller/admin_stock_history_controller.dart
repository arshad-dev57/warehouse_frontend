// lib/modules/admin/stock/controllers/stock_history_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/stock_repository.dart';

class StockHistoryController extends GetxController {
  final StockRepository _stockRepository;

  StockHistoryController({required StockRepository stockRepository})
      : _stockRepository = stockRepository;

  final movements = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final selectedType = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadMovements();
    
    ever(selectedType, (_) => loadMovements());
  }

  Future<void> loadMovements() async {
    try {
      isLoading.value = true;
      
      String? type;
      if (selectedType.value != 'all') {
        type = selectedType.value;
      }
      
      final data = await _stockRepository.getMovements(type: type);
      movements.value = data;
      
      // Debug print
      print('Loaded ${data.length} movements');
      
    } catch (e) {
      print('Error loading movements: $e');
    } finally {
      isLoading.value = false;
    }
  }
}