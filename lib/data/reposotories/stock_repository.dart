// lib/data/repositories/stock_repository.dart

import 'package:get/get.dart';

class StockRepository extends GetxService {
  
  // Mock stock movements - pehle se kuch data daal do
  final List<Map<String, dynamic>> _movements = [
    {
      'id': 'mov1',
      'productId': 'p1',
      'productName': 'iPhone 14 Case',
      'type': 'stock_in',
      'quantity': 50,
      'reason': 'Purchase',
      'reference': 'PO-001',
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'notes': 'New stock received',
      'userId': 'user1',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'mov2',
      'productId': 'p2',
      'productName': 'Paracetamol',
      'type': 'stock_out',
      'quantity': 20,
      'reason': 'Sale',
      'reference': 'ORD-123',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'notes': 'Customer order',
      'userId': 'user1',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'mov3',
      'productId': 'p1',
      'productName': 'iPhone 14 Case',
      'type': 'stock_out',
      'quantity': 5,
      'reason': 'Sale',
      'reference': 'ORD-124',
      'date': DateTime.now().toIso8601String(),
      'notes': '',
      'userId': 'user2',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  Future<void> addMovement(Map<String, dynamic> movement) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _movements.add({
      ...movement,
      'id': 'mov${_movements.length + 1}',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMovements({
    String? productId,
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var filtered = List<Map<String, dynamic>>.from(_movements);
    
    if (productId != null) {
      filtered = filtered.where((m) => m['productId'] == productId).toList();
    }
    
    if (type != null && type != 'all') {
      filtered = filtered.where((m) => m['type'] == type).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['date'] ?? a['createdAt']);
      final dateB = DateTime.parse(b['date'] ?? b['createdAt']);
      return dateB.compareTo(dateA);
    });
    
    return filtered;
  }

  Future<Map<String, dynamic>> getMovementById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _movements.firstWhere((m) => m['id'] == id);
    } catch (e) {
      throw Exception('Movement not found');
    }
  }
}