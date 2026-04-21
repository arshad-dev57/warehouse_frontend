import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warehouse_management_app/data/models/product_model.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_button.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart'; // ADD THIS to pubspec.yaml

class LowStockReportView extends GetView<ReportsController> {
  LowStockReportView({super.key});

  // Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    _initNotifications();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Generating report...');
        }
        return _buildContent();
      }),
    );
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Low Stock Report',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      centerTitle: true,
      actions: [
        // PDF Download Button
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: _generateAndDownloadPDF,
          tooltip: 'Download PDF',
        ),
        // Share Button
        IconButton(
          icon: const Icon(Icons.share, color: Colors.blue),
          onPressed: _shareReport,
          tooltip: 'Share Report',
        ),
        // Print Button
        IconButton(
          icon: const Icon(Icons.print, color: Colors.green),
          onPressed: _printReport,
          tooltip: 'Print',
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report Date:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Critical Items',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        '${controller.lowStockProducts.length} products need attention',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Low Stock List
          Obx(() {
            if (controller.lowStockProducts.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.lowStockProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = controller.lowStockProducts[index];
                return _buildProductTile(product);
              },
            );
          }),
          const SizedBox(height: 20),

          // Reorder All Button
          if (controller.lowStockProducts.isNotEmpty)
            CustomButton(
              text: 'Create Purchase Orders',
              onPressed: controller.createBulkPurchaseOrders,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              height: 50,
              borderRadius: 12,
            ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    final needed = product.minimumStock - product.currentStock;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${product.currentStock}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'SKU: ${product.sku} | Min: ${product.minimumStock}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Need $needed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => controller.reorderProduct(product.id),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reorder',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Colors.green.shade300),
          const SizedBox(height: 16),
          Text(
            'No Low Stock Items',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All products are above minimum stock levels',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PERMISSION FUNCTIONS ====================

  /// Android version ke hisaab se sahi permission request karta hai
  Future<bool> _requestStoragePermission() async {
    // iOS ko koi storage permission nahi chahiye
    if (Platform.isIOS) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+ (API 33+)
      // READ/WRITE_EXTERNAL_STORAGE removed ho gayi hai
      // Downloads folder mein save karne ki permission automatically milti hai
      // Sirf notification permission maango
      await Permission.notification.request();
      return true;
    } else if (sdkInt >= 30) {
      // Android 11 - 12 (API 30 - 32)
      // MANAGE_EXTERNAL_STORAGE chahiye Downloads folder ke liye
      final status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;

      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) return true;

      // Permanently denied ho gayi to settings open karo
      if (result.isPermanentlyDenied) {
        _showPermissionDialog();
        return false;
      }
      return false;
    } else {
      // Android 10 aur below (API 29-)
      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final result = await Permission.storage.request();
      if (result.isGranted) return true;

      if (result.isPermanentlyDenied) {
        _showPermissionDialog();
        return false;
      }
      return false;
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
            'PDF save karne ke liye storage permission chahiye.\n\n'
            'Please Settings mein ja kar permission grant karein.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ==================== PDF GENERATION FUNCTIONS ====================

  Future<void> _generateAndDownloadPDF() async {
    try {
      // Permission check
      bool hasPermission = await _requestStoragePermission();

      if (!hasPermission) {
        return; // Dialog already shown in _requestStoragePermission
      }

      // Loading show karo
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // PDF generate karo
      final pdfFile = await _generatePDF();

      Get.back(); // Loading band karo

      if (pdfFile != null) {
        final savedPath = await _saveToDownloads(pdfFile);

        if (savedPath != null) {
          // Notification show karo
          await _showNotification(
            'PDF Downloaded',
            'Low stock report Downloads folder mein save ho gayi',
          );

          Get.snackbar(
            'Success',
            'PDF download ho gayi!\nPath: $savedPath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            'Error',
            'PDF save karne mein masla aaya',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      // Loading band karo agar open ho
      if (Get.isDialogOpen ?? false) Get.back();

      print('Error generating PDF: $e');
      Get.snackbar(
        'Error',
        'PDF generate karne mein masla aaya: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<File?> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPDFHeader(),
        footer: (context) => _buildPDFFooter(context),
        build: (context) => [
          _buildPDFTitle(),
          _buildPDFDateRange(),
          pw.SizedBox(height: 20),
          _buildPDFSummary(),
          pw.SizedBox(height: 20),
          _buildPDFTable(),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/low_stock_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(tempPath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<String?> _saveToDownloads(File pdfFile) async {
    try {
      String downloadsPath;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          // Android 11+ - Direct Downloads path
          downloadsPath = '/storage/emulated/0/Download';
        } else {
          // Android 10 aur below
          downloadsPath = '/storage/emulated/0/Download';
        }
      } else {
        // iOS
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      final downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'Low_Stock_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final savedFile = File('$downloadsPath/$fileName');

      await pdfFile.copy(savedFile.path);

      // Android pe file managers ko visible karo
      if (Platform.isAndroid) {
        await _makeFileVisible(savedFile.path);
      }

      return savedFile.path;
    } catch (e) {
      print('Downloads mein save karne mein error: $e');

      // Fallback: App documents directory mein save karo
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName =
            'Low_Stock_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final savedFile = File('${dir.path}/$fileName');
        await pdfFile.copy(savedFile.path);
        print('Fallback path pe save ho gayi: ${savedFile.path}');
        return savedFile.path;
      } catch (fallbackError) {
        print('Fallback save bhi fail: $fallbackError');
        return null;
      }
    }
  }

  Future<void> _makeFileVisible(String filePath) async {
    if (Platform.isAndroid) {
      const platform =
          MethodChannel('com.example.warehouse_app/fileprovider');
      try {
        await platform.invokeMethod('scanFile', {'path': filePath});
      } catch (e) {
        print('File scan error (non-critical): $e');
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pdf_download_channel',
      'PDF Downloads',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // ==================== PDF WIDGETS ====================

  pw.Widget _buildPDFHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Warehouse Management System',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Low Stock Report',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  pw.Widget _buildPDFTitle() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Low Stock Report',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.orange700,
          ),
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildPDFDateRange() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Report Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 11),
      ),
    );
  }

  pw.Widget _buildPDFSummary() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Critical Items:',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${controller.lowStockProducts.length} products need attention',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTable() {
    final headers = ['Product', 'SKU', 'Current', 'Minimum', 'Need', 'Status'];
    final data = controller.lowStockProducts.map((product) {
      final needed = product.minimumStock - product.currentStock;
      return [
        product.name,
        product.sku,
        product.currentStock.toString(),
        product.minimumStock.toString(),
        needed.toString(),
        needed > 10 ? 'Critical' : 'Low',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.orange700,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.center,
      },
    );
  }

  // ==================== SHARE & PRINT ====================

  Future<void> _shareReport() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdfFile = await _generatePDF();

      if (Get.isDialogOpen ?? false) Get.back();

      if (pdfFile != null) {
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: 'Low Stock Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Report share karne mein masla aaya',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _printReport() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdfFile = await _generatePDF();

      if (Get.isDialogOpen ?? false) Get.back();

      if (pdfFile != null) {
        await Printing.layoutPdf(
          onLayout: (format) async => await pdfFile.readAsBytes(),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Print karne mein masla aaya',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}