// lib/data/models/chart_data.dart

import 'dart:ui';

class ChartData {
  final String label;
  final double value;
  final DateTime? date;
  final Color? color;

  ChartData({
    required this.label,
    required this.value,
    this.date,
    this.color,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  // For stock movement (line chart)
  factory ChartData.stockMovement(String label, double value, DateTime date) {
    return ChartData(
      label: label,
      value: value,
      date: date,
    );
  }

  // For category distribution (pie chart)
  factory ChartData.category(String label, double value, Color color) {
    return ChartData(
      label: label,
      value: value,
      color: color,
    );
  }
}