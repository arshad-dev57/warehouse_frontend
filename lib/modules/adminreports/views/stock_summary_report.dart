//n
// lib/modules/admin/reports/views/stock_summary_report_view.dart
//
// FIXES:
//  1. Font  — PdfGoogleFonts.notoSans* (Unicode) — NO fallback to Times/Helvetica
//  2. Border assertion — pw.Border(top/bottom/left/right single side) ke saath
//     borderRadius BILKUL use nahi kiya. Sirf pw.Border.all() ke saath borderRadius allowed hai.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:warehouse_management_app/modules/adminreports/controllers/admin_report_controller.dart';
import '../../../widgets/loading_widget.dart';

class StockSummaryReportView extends GetView<ReportsController> {
  StockSummaryReportView({super.key});

  final FlutterLocalNotificationsPlugin _notif = FlutterLocalNotificationsPlugin();

  // ── Fonts ────────────────────────────────────
  pw.Font? _font;
  pw.Font? _fontBold;

  /// PdfGoogleFonts is already bundled in `printing` package — no extra internet needed
  /// after the first run (font is cached locally on device).
  Future<void> _loadFonts() async {
    if (_font != null) return;
    _font     = await PdfGoogleFonts.notoSansRegular();
    _fontBold = await PdfGoogleFonts.notoSansBold();
  }

  pw.TextStyle _s({double sz = 10, PdfColor c = PdfColors.black}) =>
      pw.TextStyle(font: _font,     fontSize: sz, color: c);
  pw.TextStyle _b({double sz = 10, PdfColor c = PdfColors.black}) =>
      pw.TextStyle(font: _fontBold, fontSize: sz, color: c);

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _initNotif();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _appBar(),
      body: Obx(() => controller.isLoading.value
          ? const LoadingWidget(message: 'Generating report...')
          : _body()),
    );
  }

  void _initNotif() async {
    await _notif.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
  }

  // ══════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════
  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
          onPressed: () => Get.back(),
        ),
        title: Text('Stock Summary Report',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red),  onPressed: _download, tooltip: 'Download PDF'),
          IconButton(icon: const Icon(Icons.share,          color: Colors.blue),  onPressed: _share,    tooltip: 'Share'),
          IconButton(icon: const Icon(Icons.print,          color: Colors.green), onPressed: _print,    tooltip: 'Print'),
        ],
      );

  // ══════════════════════════════════════════════
  // UI BODY
  // ══════════════════════════════════════════════
  Widget _body() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _uiHeader(),            const SizedBox(height: 20),
          _uiKpiRow(),            const SizedBox(height: 20),
          _uiAlertBanner(),       const SizedBox(height: 20),
          _uiSectionTitle('Overall Summary',       Icons.summarize_outlined),   const SizedBox(height: 12),
          _uiSummaryTable(),      const SizedBox(height: 24),
          _uiSectionTitle('Category-wise Breakdown', Icons.category_outlined),  const SizedBox(height: 12),
          _uiCategoryTable(),     const SizedBox(height: 24),
          _uiActionButtons(),     const SizedBox(height: 24),
        ]),
      );

  Widget _uiHeader() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E1E2F), Color(0xFF3A3A5C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Stock Summary Report', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Generated on ${controller.getCurrentDate()}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white38)),
            child: Column(children: [
              Text('${controller.totalProducts}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Products', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
            ]),
          ),
        ]),
      );

  Widget _uiKpiRow() => Row(children: [
        Expanded(child: _kpiCard('Stock Value', '\$${controller.totalStockValue}', Icons.account_balance_wallet_outlined, Colors.blue, 'Total worth')),
        const SizedBox(width: 12),
        Expanded(child: _kpiCard('Avg Price', '\$${controller.averagePrice}', Icons.price_change_outlined, Colors.purple, 'Per item')),
      ]);

  Widget _kpiCard(String title, String value, IconData icon, Color color, String sub) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 3),
            Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E2F))),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade400)),
          ])),
        ]),
      );

  Widget _uiAlertBanner() {
    final ok = controller.lowStockCount == 0 && controller.outOfStockCount == 0;
    if (ok) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
        child: Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20), const SizedBox(width: 10),
          Text('All products are at healthy stock levels!', style: GoogleFonts.inter(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stock Alerts', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.orange.shade800)),
          const SizedBox(height: 4),
          Row(children: [
            if (controller.lowStockCount   > 0) _chip('${controller.lowStockCount} Low Stock',   Colors.orange),
            if (controller.lowStockCount   > 0 && controller.outOfStockCount > 0) const SizedBox(width: 8),
            if (controller.outOfStockCount > 0) _chip('${controller.outOfStockCount} Out of Stock', Colors.red),
          ]),
        ])),
      ]),
    );
  }

  Widget _chip(String label, MaterialColor col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: col.shade700)),
      );

  Widget _uiSectionTitle(String title, IconData icon) => Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF1E1E2F).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: const Color(0xFF1E1E2F))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
      ]);

  Widget _uiSummaryTable() => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          _sRow(icon: Icons.inventory_2_outlined,            c: Colors.blue,   label: 'Total Products',         value: '${controller.totalProducts}',      first: true),
          _div(),
          _sRow(icon: Icons.account_balance_wallet_outlined, c: Colors.green,  label: 'Total Stock Value',      value: '\$${controller.totalStockValue}'),
          _div(),
          _sRow(icon: Icons.price_change_outlined,           c: Colors.purple, label: 'Average Price per Item', value: '\$${controller.averagePrice}'),
          _div(),
          _sRow(icon: Icons.warning_amber_rounded,           c: Colors.orange, label: 'Low Stock Items',         value: '${controller.lowStockCount}',      warn: controller.lowStockCount > 0),
          _div(),
          _sRow(icon: Icons.remove_shopping_cart_outlined,   c: Colors.red,    label: 'Out of Stock',           value: '${controller.outOfStockCount}',    warn: controller.outOfStockCount > 0, last: true),
        ]),
      );

  Widget _div() => const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0F0F0));

  Widget _sRow({required IconData icon, required Color c, required String label, required String value, bool warn = false, bool first = false, bool last = false}) =>
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: first ? const Radius.circular(14) : Radius.zero, bottom: last ? const Radius.circular(14) : Radius.zero)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: c)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: warn ? Colors.orange.shade50 : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(8),
              border: warn ? Border.all(color: Colors.orange.shade200) : null,
            ),
            child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: warn ? Colors.orange.shade700 : const Color(0xFF1E1E2F))),
          ),
        ]),
      );

  Widget _uiCategoryTable() => Obx(() {
        if (controller.categorySummary.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text('No category data available', style: GoogleFonts.inter(color: Colors.grey.shade400))),
          );
        }
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFFF8F8FB), borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
              child: Row(children: [
                const SizedBox(width: 24),
                Expanded(flex: 2, child: Text('CATEGORY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)))),
                Expanded(child: Text('ITEMS', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)))),
                Expanded(child: Text('VALUE', textAlign: TextAlign.right,  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)))),
              ]),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.categorySummary.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
              itemBuilder: (_, i) => _catRow(controller.categorySummary[i]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFFF8F8FB), borderRadius: BorderRadius.vertical(bottom: Radius.circular(14))),
              child: Row(children: [
                const SizedBox(width: 24),
                Expanded(flex: 2, child: Text('TOTAL', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F)))),
                Expanded(child: Text('${controller.totalProducts}', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F)))),
                Expanded(child: Text('\$${controller.totalStockValue}', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E2F)))),
              ]),
            ),
          ]),
        );
      });

  Widget _catRow(Map<String, dynamic> cat) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: cat['color'], shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: Text(cat['name'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1E1E2F)))),
          Expanded(child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(6)),
            child: Text('${cat['count']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2F))),
          ))),
          Expanded(child: Text('\$${cat['value']}', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F)))),
        ]),
      );

  Widget _uiActionButtons() => Column(children: [
        Row(children: [
          Expanded(child: _btn(icon: Icons.share, label: 'Share Report', color: Colors.blue,  onTap: _share)),
          const SizedBox(width: 12),
          Expanded(child: _btn(icon: Icons.print, label: 'Print Report', color: Colors.green, onTap: _print)),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: _download,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text('Download PDF Report', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            )),
      ]);

  Widget _btn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: color), const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );

  // ══════════════════════════════════════════════
  // PERMISSION — same as LowStockReportView
  // ══════════════════════════════════════════════
  Future<bool> _reqPerm() async {
    if (Platform.isIOS) return true;
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdk >= 33) { await Permission.notification.request(); return true; }
    if (sdk >= 30) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      final r = await Permission.manageExternalStorage.request();
      if (r.isGranted) return true;
      if (r.isPermanentlyDenied) _permDialog();
      return false;
    }
    if (await Permission.storage.isGranted) return true;
    final r = await Permission.storage.request();
    if (r.isGranted) return true;
    if (r.isPermanentlyDenied) _permDialog();
    return false;
  }

  void _permDialog() => Get.dialog(AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text('PDF save karne ke liye storage permission chahiye.\nSettings mein ja kar grant karein.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(onPressed: () async { Get.back(); await openAppSettings(); }, child: const Text('Open Settings')),
        ],
      ));

  // ══════════════════════════════════════════════
  // PDF — build
  // ══════════════════════════════════════════════
  Future<File?> _buildPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData(
        defaultTextStyle: _s(sz: 10),
        paragraphStyle:   _s(sz: 10),
        tableHeader:      _b(sz: 10),
        tableCell:        _s(sz: 9),
      ),
      header: (_) => _pdfHeader(),
      footer: (ctx) => _pdfFooter(ctx),
      build: (_) => [
        _pdfTitleBlock(),
        pw.SizedBox(height: 10),
        _pdfDateRow(),
        pw.SizedBox(height: 16),
        _pdfBanner(),
        pw.SizedBox(height: 12),
        _pdfKpis(),
        pw.SizedBox(height: 20),
        _pdfHeading('Overall Summary'),
        pw.SizedBox(height: 8),
        _pdfSummaryTable(),
        pw.SizedBox(height: 20),
        _pdfHeading('Category-wise Breakdown'),
        pw.SizedBox(height: 8),
        _pdfCategoryTable(),
      ],
    ));
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/stock_summary_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── PDF widgets ───────────────────────────────

  // Header & Footer — use only single-side border, NO borderRadius (pdf package rule)
  pw.Widget _pdfHeader() => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 6),
        // ✅ single-side border → NO borderRadius
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
        ),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Warehouse Management System', style: _b(sz: 11, c: PdfColors.indigo900)),
          pw.Text('Stock Summary Report',        style: _s(sz: 10, c: PdfColors.grey600)),
        ]),
      );

  pw.Widget _pdfFooter(pw.Context ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.only(top: 6),
        // ✅ single-side border → NO borderRadius
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
        ),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}', style: _s(sz: 8, c: PdfColors.grey600)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',                         style: _s(sz: 8, c: PdfColors.grey600)),
        ]),
      );

  // Title block — pw.Border.all() → borderRadius is ALLOWED
  pw.Widget _pdfTitleBlock() => pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: const pw.BoxDecoration(
          color: PdfColors.indigo900,
          // ✅ uniform border (Border.all) → borderRadius OK
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Stock Summary Report',       style: _b(sz: 20, c: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text('Complete inventory overview', style: _s(sz: 10, c: PdfColors.grey300)),
          ]),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(children: [
              pw.Text('${controller.totalProducts}', style: _b(sz: 22, c: PdfColors.indigo900)),
              pw.Text('Products',                    style: _s(sz: 9,  c: PdfColors.grey600)),
            ]),
          ),
        ]),
      );

  pw.Widget _pdfDateRow() => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text('Report Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}', style: _s(sz: 10)),
      );

  pw.Widget _pdfBanner() => pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: const pw.BoxDecoration(
          color: PdfColors.indigo50,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Total Products:',                                           style: _b(sz: 13)),
          pw.Text('${controller.totalProducts} products in inventory',         style: _b(sz: 13, c: PdfColors.indigo900)),
        ]),
      );

  pw.Widget _pdfKpis() => pw.Row(children: [
        _kpi('Total Stock Value',  '\$${controller.totalStockValue}', PdfColors.blue800),
        pw.SizedBox(width: 6),
        _kpi('Average Price',      '\$${controller.averagePrice}',   PdfColors.purple800),
        pw.SizedBox(width: 6),
        _kpi('Low Stock',          '${controller.lowStockCount}',    controller.lowStockCount   > 0 ? PdfColors.orange800 : PdfColors.green800),
        pw.SizedBox(width: 6),
        _kpi('Out of Stock',       '${controller.outOfStockCount}',  controller.outOfStockCount > 0 ? PdfColors.red800    : PdfColors.green800),
      ]);

  pw.Widget _kpi(String label, String value, PdfColor color) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          // ✅ Border.all → borderRadius allowed
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(label, style: _s(sz: 8, c: PdfColors.grey600)),
            pw.SizedBox(height: 3),
            pw.Text(value, style: _b(sz: 12, c: color)),
          ]),
        ),
      );

  // Section heading — left accent bar without using pw.Border(left:) + borderRadius together
  // Instead: Row with a colored box as left bar — zero assertion risk
  pw.Widget _pdfHeading(String title) => pw.Container(
        color: PdfColors.grey200,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Row(children: [
          // ✅ left accent: plain colored Container, no Border involved
          pw.Container(width: 3, height: 16, color: PdfColors.indigo900),
          pw.SizedBox(width: 8),
          pw.Text(title, style: _b(sz: 12, c: PdfColors.indigo900)),
        ]),
      );

  pw.Widget _pdfSummaryTable() => pw.TableHelper.fromTextArray(
        headers: ['Metric', 'Value'],
        data: [
          ['Total Products',     '${controller.totalProducts}'],
          ['Total Stock Value',  '\$${controller.totalStockValue}'],
          ['Average Price/Item', '\$${controller.averagePrice}'],
          ['Low Stock Items',    '${controller.lowStockCount}'],
          ['Out of Stock',       '${controller.outOfStockCount}'],
        ],
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        headerStyle:      _b(sz: 10, c: PdfColors.white),
        cellStyle:        _s(sz: 10),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
        rowDecoration:    const pw.BoxDecoration(color: PdfColors.white),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
        cellAlignments:   {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
      );

  pw.Widget _pdfCategoryTable() {
    if (controller.categorySummary.isEmpty) {
      return pw.Text('No category data available.', style: _s(sz: 10, c: PdfColors.grey600));
    }
    final rows = controller.categorySummary
        .map((c) => [c['name'] ?? '', '${c['count'] ?? 0}', '\$${c['value'] ?? 0}'])
        .toList()
      ..add(['TOTAL', '${controller.totalProducts}', '\$${controller.totalStockValue}']);

    return pw.TableHelper.fromTextArray(
      headers: ['Category', 'Items', 'Value'],
      data: rows,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle:      _b(sz: 10, c: PdfColors.white),
      cellStyle:        _s(sz: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
      rowDecoration:    const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
      cellAlignments:   {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight},
    );
  }

  // ══════════════════════════════════════════════
  // DOWNLOAD / SHARE / PRINT — same as LowStockReportView
  // ══════════════════════════════════════════════
  Future<void> _download() async {
    try {
      if (!await _reqPerm()) return;
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _loadFonts();
      final pdf = await _buildPdf();
      if (Get.isDialogOpen ?? false) Get.back();
      if (pdf == null) return;
      final path = await _savePdf(pdf);
      if (path != null) {
        await _notify('PDF Downloaded', 'Stock Summary report Downloads mein save ho gayi');
        Get.snackbar('Success', 'PDF save ho gayi!\n$path',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 4));
      } else {
        Get.snackbar('Error', 'PDF save nahi hui', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print('Download error: $e');
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _share() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _loadFonts();
      final pdf = await _buildPdf();
      if (Get.isDialogOpen ?? false) Get.back();
      if (pdf != null) {
        await Share.shareXFiles([XFile(pdf.path)],
            text: 'Stock Summary Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print('Share error: $e');
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _print() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _loadFonts();
      final pdf = await _buildPdf();
      if (Get.isDialogOpen ?? false) Get.back();
      if (pdf != null) {
        await Printing.layoutPdf(onLayout: (_) async => pdf.readAsBytesSync());
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print('Print error: $e');
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ── helpers ───────────────────────────────────
  Future<String?> _savePdf(File pdf) async {
    try {
      final dir  = Platform.isAndroid ? '/storage/emulated/0/Download' : (await getApplicationDocumentsDirectory()).path;
      final dest = Directory(dir);
      if (!await dest.exists()) await dest.create(recursive: true);
      final name = 'Stock_Summary_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final out  = await pdf.copy('$dir/$name');
      if (Platform.isAndroid) await _scan(out.path);
      return out.path;
    } catch (e) {
      print('Save error: $e');
      try {
        final fb   = await getApplicationDocumentsDirectory();
        final name = 'Stock_Summary_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final out  = await pdf.copy('${fb.path}/$name');
        return out.path;
      } catch (_) { return null; }
    }
  }

  Future<void> _scan(String path) async {
    try { await const MethodChannel('com.example.warehouse_app/fileprovider').invokeMethod('scanFile', {'path': path}); }
    catch (e) { print('Scan (non-critical): $e'); }
  }

  Future<void> _notify(String title, String body) async {
    await _notif.show(DateTime.now().millisecond, title, body,
        const NotificationDetails(
          android: AndroidNotificationDetails('pdf_ch', 'PDF Downloads', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ));
  }
}