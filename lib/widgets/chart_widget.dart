// lib/modules/admin/dashboard/widgets/chart_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/chart_data.dart';
import '../../../../data/models/category_data.dart';

class ChartWidget {
  
  // Line Chart for Stock Movement with custom colors
  static Widget line({
    required List<ChartData> data,
    Color? lineColor,
    Color? fillColor,
  }) {
    return _LineChart(
      data: data,
      lineColor: lineColor,
      fillColor: fillColor,
    );
  }

  // Pie Chart for Category Distribution with custom colors
  static Widget pie({
    required List<CategoryData> data,
    List<Color>? customColors,
  }) {
    return _PieChart(
      data: data,
      customColors: customColors,
    );
  }

  // Bar Chart for Top Products
  static Widget bar({required List<ChartData> data, String title = ''}) {
    return _BarChart(data: data, title: title);
  }
}

// Line Chart Implementation
class _LineChart extends StatelessWidget {
  final List<ChartData> data;
  final Color? lineColor;
  final Color? fillColor;

  const _LineChart({
    required this.data,
    this.lineColor,
    this.fillColor,
  });

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
          painter: _LineChartPainter(
            data: data,
            maxValue: maxValue,
            lineColor: lineColor,
            fillColor: fillColor,
          ),
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
  final Color? lineColor;
  final Color? fillColor;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    this.lineColor,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Use custom colors or defaults
    final actualLineColor = lineColor ?? Colors.blue.shade400;
    final actualFillColor = fillColor ?? (lineColor?.withOpacity(0.1) ?? Colors.blue.shade50);

    final linePaint = Paint()
      ..color = actualLineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = actualFillColor
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = actualLineColor.withOpacity(0.9)
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
      
      // Draw point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      
      // Draw label
      final textSpan = TextSpan(
        text: data[0].label,
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

    // Store points for later use
    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final x = padding + (graphWidth * i / (data.length - 1));
      final y = padding + (graphHeight * (1 - (data[i].value / maxValue)));
      
      points.add(Offset(x, y));

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

    // Draw line with gradient effect if needed
    if (data.length > 1) {
      // Smooth curve using quadratic bezier for better appearance
      final smoothPath = Path();
      smoothPath.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final controlX = (p1.dx + p2.dx) / 2;
        
        smoothPath.quadraticBezierTo(
          p1.dx, p1.dy,
          controlX, (p1.dy + p2.dy) / 2,
        );
      }
      
      canvas.drawPath(smoothPath, linePaint);
    } else {
      canvas.drawPath(path, linePaint);
    }

    // Draw fill
    if (data.length > 1) {
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

    // Draw horizontal lines for min/max indicators
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxValueActual = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    if (minValue != maxValueActual) {
      final minYPixel = padding + (graphHeight * (1 - (minValue / maxValue)));
      final maxYPixel = padding + (graphHeight * (1 - (maxValueActual / maxValue)));
      
      // Draw min indicator
      final dashPaint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      // Draw dashed line for min
      _drawDashedLine(
        canvas,
        Offset(padding, minYPixel),
        Offset(width - padding, minYPixel),
        dashPaint,
      );
      
      // Draw max indicator
      dashPaint.color = Colors.red.withOpacity(0.5);
      _drawDashedLine(
        canvas,
        Offset(padding, maxYPixel),
        Offset(width - padding, maxYPixel),
        dashPaint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 2.0;
    double distance = (p2 - p1).distance;
    int dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final start = Offset(
        p1.dx + (p2.dx - p1.dx) * i / dashCount,
        p1.dy + (p2.dy - p1.dy) * i / dashCount,
      );
      final end = Offset(
        p1.dx + (p2.dx - p1.dx) * (i + 0.5) / dashCount,
        p1.dy + (p2.dy - p1.dy) * (i + 0.5) / dashCount,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.maxValue != maxValue ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.fillColor != fillColor;
  }
}

// Pie Chart Implementation
class _PieChart extends StatelessWidget {
  final List<CategoryData> data;
  final List<Color>? customColors;

  const _PieChart({
    required this.data,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No category data'),
      );
    }

    // Update colors if custom colors provided
    List<CategoryData> displayData = data;
    if (customColors != null && customColors!.length == data.length) {
      displayData = data.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return CategoryData(
          productCount: category.productCount,
          categoryId:category.categoryId ,
          categoryName: category.categoryName,
          percentage: category.percentage,
          color: customColors![index],
        );
      }).toList();
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: const Size(150, 150),
            painter: _PieChartPainter(data: displayData),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: displayData.map((category) {
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
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
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
                        gradient: item.color == null ? LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade300,
                          ],
                        ) : null,
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