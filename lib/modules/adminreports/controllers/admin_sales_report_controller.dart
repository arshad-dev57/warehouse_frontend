import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SalesReportController extends GetxController {
  final isLoading = false.obs;
  
  // Date range
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;

  // Sales data
  final salesData = <Map<String, dynamic>>[].obs;

  // PDF file path
  final pdfPath = ''.obs;

  // Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    loadSalesData();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load sales data (dummy data for now)
  Future<void> loadSalesData() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Dummy data
    salesData.value = [
      {
        'name': 'ABC Corporation',
        'invoiceCount': 5,
        'sales': '15,000',
        'salesWithTax': '16,500',
      },
      {
        'name': 'XYZ Enterprises',
        'invoiceCount': 3,
        'sales': '8,500',
        'salesWithTax': '9,350',
      },
      {
        'name': 'PQR Industries',
        'invoiceCount': 4,
        'sales': '12,000',
        'salesWithTax': '13,200',
      },
      {
        'name': 'LMN Traders',
        'invoiceCount': 2,
        'sales': '5,500',
        'salesWithTax': '6,050',
      },
      {
        'name': 'RST Solutions',
        'invoiceCount': 6,
        'sales': '22,000',
        'salesWithTax': '24,200',
      },
      {
        'name': 'UVW Group',
        'invoiceCount': 3,
        'sales': '9,500',
        'salesWithTax': '10,450',
      },
    ];
    
    isLoading.value = false;
  }

  // Getters
  int get totalOrders {
    return salesData.fold(0, (sum, item) => sum + (item['invoiceCount'] as int));
  }

  int get totalCustomers {
    return salesData.length;
  }

  String get totalSales {
    final total = salesData.fold(0.0, (sum, item) {
      final sales = item['sales'] as String;
      final value = double.parse(sales.replaceAll(',', ''));
      return sum + value;
    });
    return _formatNumber(total);
  }

  String get totalSalesWithTax {
    final total = salesData.fold(0.0, (sum, item) {
      final sales = item['salesWithTax'] as String;
      final value = double.parse(sales.replaceAll(',', ''));
      return sum + value;
    });
    return _formatNumber(total);
  }

  int get totalInvoiceCount {
    return salesData.fold(0, (sum, item) => sum + (item['invoiceCount'] as int));
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(number);
  }

  // Date selection
  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate.value = picked;
      loadSalesData();
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      endDate.value = picked;
      loadSalesData();
    }
  }

  // ==================== PERMISSION HANDLING ====================

  Future<bool> _requestStoragePermission() async {
    // For Android 13+ (API 33+)
    if (await Permission.notification.isGranted == false) {
      await Permission.notification.request();
    }
    
    // For Android 11+ (API 30+)
    if (await Permission.manageExternalStorage.isGranted == false) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }
    }
    
    // For Android 10 and below
    if (await Permission.storage.isGranted == false) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    
    return true;
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'This app needs storage permission to save PDF reports to your device.\n\n'
          'Please grant permission to continue.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await generateAndDownloadPDF();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  // ==================== PDF GENERATION ====================

  Future<void> generateAndDownloadPDF() async {
    try {
      isLoading.value = true;
      
      // Check permission first
      bool hasPermission = await _requestStoragePermission();
      
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            child: Text("settings"),
            onPressed: () => openAppSettings(),
          ),
        );
        return;
      }
      
      // Generate PDF
      final pdfFile = await _generatePDF();
      
      if (pdfFile != null) {
        // Save to downloads folder
        final savedPath = await _saveToDownloads(pdfFile);
        
        if (savedPath != null) {
          pdfPath.value = savedPath;
          
          // Show success notification
          await _showNotification(
            'PDF Downloaded',
            'Sales report saved to Downloads folder',
          );
          
          Get.snackbar(
            'Success',
            'PDF downloaded successfully\nSaved to: $savedPath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      print('Error generating PDF: $e');
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<File?> _generatePDF() async {
    final pdf = pw.Document();

    // Add logo/image if available
    final logoImage = await _getLogoImage();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPDFHeader(logoImage),
        footer: (context) => _buildPDFFooter(),
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

    // Save PDF to temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(tempPath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<pw.ImageProvider?> _getLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  pw.Widget _buildPDFHeader(pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo != null)
          pw.Image(logo, width: 60, height: 60)
        else
          pw.Container(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Marketing Business Bureau',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Sales by Customer Report',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        pw.Text(
          'Page {{page}} of {{pages}}',
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
          'Sales by Customer',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
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
        'From ${DateFormat('dd MMM yyyy').format(startDate.value)} To ${DateFormat('dd MMM yyyy').format(endDate.value)}',
        style: const pw.TextStyle(fontSize: 11),
      ),
    );
  }

  pw.Widget _buildPDFSummary() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildPDFSummaryCard('Total Orders', totalOrders.toString()),
        _buildPDFSummaryCard('Total Customers', totalCustomers.toString()),
        _buildPDFSummaryCard('Total Sales', 'PKR $totalSales'),
      ],
    );
  }

  pw.Widget _buildPDFSummaryCard(String title, String value) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTable() {
    final headers = ['Name', 'Inv Count', 'Sales', 'Sales With Tax'];
    final data = salesData.map((item) => [
      item['name'],
      item['invoiceCount'].toString(),
      'PKR ${item['sales']}',
      'PKR ${item['salesWithTax']}',
    ]).toList();

    // Add total row
    data.add([
      'TOTAL',
      totalInvoiceCount.toString(),
      'PKR $totalSales',
      'PKR $totalSalesWithTax',
    ]);

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
        color: PdfColors.blueGrey900,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  Future<String?> _saveToDownloads(File pdfFile) async {
    try {
      String? downloadsPath;
      
      if (Platform.isAndroid) {
        // For Android 10 and above
        if (await Permission.manageExternalStorage.isGranted) {
          downloadsPath = '/storage/emulated/0/Download';
        } else {
          // Fallback to app's external storage
          final directory = await getExternalStorageDirectory();
          downloadsPath = directory?.path;
        }
      } else {
        // For iOS
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }
      
      if (downloadsPath == null) {
        throw Exception('Could not access storage');
      }
      
      final downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = 'Sales_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final savedFile = File('${downloadsDir.path}/$fileName');
      
      await pdfFile.copy(savedFile.path);
      
      // Make file visible in file managers (Android)
      if (Platform.isAndroid) {
        await _makeFileVisible(savedFile.path);
      }
      
      return savedFile.path;
    } catch (e) {
      print('Error saving to downloads: $e');
      return null;
    }
  }

  Future<void> _makeFileVisible(String filePath) async {
    if (Platform.isAndroid) {
      const platform = MethodChannel('com.example.warehouse_app/fileprovider');
      try {
        await platform.invokeMethod('scanFile', {'path': filePath});
      } catch (e) {
        print('Error scanning file: $e');
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

  // Share PDF
  Future<void> sharePDF() async {
    try {
      if (pdfPath.value.isEmpty) {
        await generateAndDownloadPDF();
      }
      
      if (pdfPath.value.isNotEmpty) {
        await Share.shareXFiles(
          [XFile(pdfPath.value)],
          text: 'Sales Report',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Print PDF
  Future<void> printReport() async {
    try {
      if (pdfPath.value.isEmpty) {
        final pdfFile = await _generatePDF();
        if (pdfFile != null) {
          await Printing.layoutPdf(
            onLayout: (format) async => await pdfFile.readAsBytes(),
          );
        }
      } else {
        final file = File(pdfPath.value);
        await Printing.layoutPdf(
          onLayout: (format) async => await file.readAsBytes(),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to print',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}