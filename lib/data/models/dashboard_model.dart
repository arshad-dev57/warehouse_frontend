// lib/data/models/dashboard_model.dart

class DashboardModel {
  final int totalProducts;
  final double totalStockValue;
  final int lowStockCount;
  final int expiringCount;
  final int todayStockIn;
  final int todayStockOut;
  final int pendingOrders;

  DashboardModel({
    required this.totalProducts,
    required this.totalStockValue,
    required this.lowStockCount,
    required this.expiringCount,
    required this.todayStockIn,
    required this.todayStockOut,
    required this.pendingOrders,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalProducts: json['totalProducts'] ?? 0,
      totalStockValue: (json['totalStockValue'] ?? 0).toDouble(),
      lowStockCount: json['lowStockCount'] ?? 0,
      expiringCount: json['expiringCount'] ?? 0,
      todayStockIn: json['todayStockIn'] ?? 0,
      todayStockOut: json['todayStockOut'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'totalStockValue': totalStockValue,
      'lowStockCount': lowStockCount,
      'expiringCount': expiringCount,
      'todayStockIn': todayStockIn,
      'todayStockOut': todayStockOut,
      'pendingOrders': pendingOrders,
    };
  }
}