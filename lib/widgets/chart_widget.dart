// lib/modules/admin/dashboard/widgets/chart_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/chart_data.dart';
import '../../../../data/models/category_data.dart';

class ChartWidget {
  // Line Chart for Stock Movement
  static Widget line({required List<ChartData> data}) {
    return _LineChart(data: data);
  }

  // Pie Chart for Category Distribution
  static Widget pie({required List<CategoryData> data}) {
    return _PieChart(data: data);
  }

  // Bar Chart for Top Products
  static Widget bar({required List<ChartData> data, String title = ''}) {
    return _BarChart(data: data, title: title);
  }
}

// Line Chart Implementation
class _LineChart extends StatelessWidget {
  final List<ChartData> data;

  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState('No data available');
    }

    // Find max value for scaling
    double maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    maxValue = maxValue == 0 ? 100 : maxValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(data: data, maxValue: maxValue),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// Line Chart Painter
class _LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;

  _LineChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 10,
      fontFamily: 'Inter',
    );

    final width = size.width;
    final height = size.height;
    final padding = 20.0;
    final graphWidth = width - (padding * 2);
    final graphHeight = height - (padding * 2);

    if (data.length == 1) {
      // Single point
      final x = width / 2;
      final y = padding + (graphHeight * (1 - (data[0].value / maxValue)));
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      return;
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (graphHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );
    }

    // Create path for line and fill
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding + (graphWidth * i / (data.length - 1));
      final y = padding + (graphHeight * (1 - (data[i].value / maxValue)));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 3, pointPaint);

      // Draw labels
      final textSpan = TextSpan(
        text: data[i].label,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, height - 15),
      );
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw fill
    fillPath.lineTo(
      padding + graphWidth,
      height - padding,
    );
    fillPath.lineTo(
      padding,
      height - padding,
    );
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pie Chart Implementation
class _PieChart extends StatelessWidget {
  final List<CategoryData> data;

  const _PieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No category data'),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: const Size(150, 150),
            painter: _PieChartPainter(data: data),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${category.percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Pie Chart Painter
class _PieChartPainter extends CustomPainter {
  final List<CategoryData> data;

  _PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    var startAngle = -90.0; // Start from top

    for (var category in data) {
      final sweepAngle = (category.percentage / 100) * 360;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle * (3.14159 / 180),
        sweepAngle * (3.14159 / 180),
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bar Chart Implementation
class _BarChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;

  const _BarChart({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    double maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    maxValue = maxValue == 0 ? 100 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final barHeight = (item.value / maxValue) * 100;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: barHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: item.color ?? Colors.blue.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}