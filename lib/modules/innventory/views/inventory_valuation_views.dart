// lib/modules/admin/inventory/views/inventory_valuation_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:warehouse_management_app/modules/innventory/controllers/inventory_vauation_controller.dart';



class ShimmerSummaryCard extends StatelessWidget {
  const ShimmerSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity, // 🔴 Full width
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            
            // 🔴 FIX: Use Expanded for text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity, // Full width of Expanded
                    height: 11, 
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100, // Fixed width for second line
                    height: 15, 
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerInsightChip extends StatelessWidget {
  const ShimmerInsightChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity, // 🔴 Full width
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerTableRow extends StatelessWidget {
  const ShimmerTableRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity, // 🔴 Full width
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 🔴 FIX: Use Flexible with flex factors instead of fixed widths
            _buildShimmerCell(flex: 3), // Product Name
            const SizedBox(width: 8),
            _buildShimmerCell(flex: 1), // SKU
            const SizedBox(width: 8),
            _buildShimmerCell(flex: 1), // Stock
            const SizedBox(width: 8),
            _buildShimmerCell(flex: 1), // Price
            const SizedBox(width: 8),
            _buildShimmerCell(flex: 1), // Status
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCell({required int flex}) {
    return Flexible(
      flex: flex,
      child: Container(
        height: 20,
        color: Colors.white,
      ),
    );
  }
}

// Alternative: Simpler Table Row with equal distribution
class ShimmerTableRowSimple extends StatelessWidget {
  const ShimmerTableRowSimple({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 20,
                margin: const EdgeInsets.only(right: 8),
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Usage example in a shimmer grid
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const ShimmerInsightChip(),
    );
  }
}

// Usage example in a shimmer list
class ShimmerList extends StatelessWidget {
  const ShimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: const ShimmerTableRow(),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────
class InventoryValuationView extends GetView<InventoryValuationController> {
  const InventoryValuationView({super.key});

  // ── helpers ──────────────────────────────────
  String _fmt(double v) => controller.formatCurrency(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: const Color(0xFF1E1E2F),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildInsightsRow(),
                    const SizedBox(height: 20),
                    _buildFiltersRow(),
                    const SizedBox(height: 16),
                    _buildTable(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Shimmer Loading State ────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 150, height: 16, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: const ShimmerSummaryCard()),
                const SizedBox(width: 12),
                Expanded(child: const ShimmerSummaryCard()),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: const ShimmerSummaryCard()),
                const SizedBox(width: 12),
                Expanded(child: const ShimmerSummaryCard()),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: const ShimmerInsightChip()),
            const SizedBox(width: 10),
            Expanded(child: const ShimmerInsightChip()),
            const SizedBox(width: 10),
            Expanded(child: const ShimmerInsightChip()),
          ]),
          const SizedBox(height: 20),
          Container(width: double.infinity, height: 40, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  color: const Color(0xFFF8F8FB),
                  height: 45,
                ),
                const Divider(),
                ...List.generate(8, (index) => const ShimmerTableRow()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  color: const Color(0xFFF8F8FB),
                  height: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E1E2F)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Inventory Valuation',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E2F),
        ),
      ),
      actions: [
        // PDF Download Button
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          tooltip: 'Download PDF',
          onPressed: () => _generateAndDownloadPDF(),
        ),
        // Share Button
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.blue),
          tooltip: 'Share Report',
          onPressed: () => _shareReport(),
        ),
        // Print Button
        IconButton(
          icon: const Icon(Icons.print_outlined, color: Colors.green),
          tooltip: 'Print',
          onPressed: () => _printReport(),
        ),
      ],
    );
  }

  // ── Summary Cards ─────────────────────────────
  Widget _buildSummaryCards() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valuation Summary',
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _summaryCard(
              'Total Cost Value',
              _fmt(controller.totalCostValue),
              Icons.account_balance_wallet_outlined,
              Colors.blue,
              '${controller.totalItems} items',
            )),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard(
              'Total Sell Value',
              _fmt(controller.totalSellingValue),
              Icons.sell_outlined,
              Colors.green,
              '${controller.totalQty} units',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _summaryCard(
              'Potential Profit',
              _fmt(controller.totalPotentialProfit),
              Icons.trending_up,
              controller.totalPotentialProfit >= 0 ? Colors.purple : Colors.red,
              '${controller.totalPotentialProfit >= 0 ? '+' : ''}Profit',
            )),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard(
              'Dead Stock Value',
              _fmt(controller.deadStockValue),
              Icons.inventory_2_outlined,
              Colors.red,
              '${controller.deadStockCount} items',
            )),
          ],
        ),
      ],
    ));
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Insights Row ──────────────────────────────
  Widget _buildInsightsRow() {
    return Obx(() => Row(
      children: [
        Expanded(child: _insightChip('⚡ Fast Moving', '${controller.fastMovingCount} items', Colors.green)),
        const SizedBox(width: 10),
        Expanded(child: _insightChip('📦 Overstock', '${controller.overStockCount} items', Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _insightChip('💀 Dead Stock', '${controller.deadStockCount} items', Colors.red)),
      ],
    ));
  }

  Widget _insightChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(count, style: GoogleFonts.inter(fontSize: 13, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ── Filters Row ───────────────────────────────
  Widget _buildFiltersRow() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2F))),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _dropdownChip('Category', controller.selectedCategory,
                  controller.categories.map((c) => c['name'] as String).toList()),
              const SizedBox(width: 10),
              _dropdownChip('Zone', controller.selectedZone, controller.zones),
              const SizedBox(width: 10),
              _dropdownChip('Sort By', controller.sortBy, controller.sortOptions),
              const SizedBox(width: 10),
              if (controller.selectedCategory.value != 'all' ||
                  controller.selectedZone.value != 'All')
                _clearFilterChip(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Showing ${controller.filteredItems.length} of ${controller.totalItems} products',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ));
  }

  Widget _dropdownChip(String label, RxString selectedVal, List<String> options) {
    return Obx(() {
      final validValue = options.contains(selectedVal.value)
          ? selectedVal.value
          : (options.isNotEmpty ? options.first : '');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: validValue,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1E1E2F), fontWeight: FontWeight.w600),
            items: options.map((o) => DropdownMenuItem<String>(
              value: o,
              child: Text(o),
            )).toList(),
            onChanged: (v) {
              if (v != null) {
                if (label == 'Category') {
                  final category = controller.categories.firstWhere(
                    (c) => c['name'] == v,
                    orElse: () => {'id': 'all', 'name': 'All Categories'},
                  );
                  controller.setCategoryFilter(category['id'] as String);
                } else if (label == 'Zone') {
                  controller.setZoneFilter(v);
                } else {
                  controller.setSort(v);
                }
              }
            },
          ),
        ),
      );
    });
  }

  Widget _clearFilterChip() {
    return GestureDetector(
      onTap: controller.clearFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.close, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text('Clear', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  // ── Column widths ────────────────────────────
  static const double _colProduct  = 180;
  static const double _colQty      = 60;
  static const double _colUnitCost = 100;
  static const double _colTotal    = 110;
  static const double _colStatus   = 90;
  static const double _tableWidth  = _colProduct + _colQty + _colUnitCost + _colTotal + _colStatus + 28;

  // ── Table ─────────────────────────────────────
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 10),
            child: Row(
              children: [
                Icon(Icons.swipe, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('Scroll right to see all columns',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _tableWidth,
              child: Column(
                children: [
                  _tableHeader(),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Obx(() {
                    if (controller.filteredItems.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No items found', style: GoogleFonts.inter(color: Colors.grey.shade400)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
                      itemBuilder: (ctx, i) => _tableRow(controller.filteredItems[i], i),
                    );
                  }),
                  _tableFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          SizedBox(width: _colProduct,  child: Text('PRODUCT',   style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)))),
          SizedBox(width: _colQty,      child: Text('QTY',       style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)), textAlign: TextAlign.center)),
          SizedBox(width: _colUnitCost, child: Text('UNIT COST', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)), textAlign: TextAlign.right)),
          SizedBox(width: _colTotal,    child: Text('TOTAL VAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)), textAlign: TextAlign.right)),
          SizedBox(width: _colStatus,   child: Text('STATUS',    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF888888)), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> item, int index) {
    final status = controller.getItemStatus(item);
    final statusColor = controller.getStatusColor(status);

    return InkWell(
      onTap: () => _showProductDetail(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: _colProduct,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2F)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(item['sku'] ?? '',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(item['category'] ?? '',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _colQty,
              child: Text('${item['qty'] ?? 0}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2F))),
            ),
            SizedBox(
              width: _colUnitCost,
              child: Text(_fmt(item['unitCost'] ?? 0),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
            ),
            SizedBox(
              width: _colTotal,
              child: Text(_fmt(item['totalCostValue'] ?? 0),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
            ),
            SizedBox(
              width: _colStatus,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Text(status,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableFooter() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FB),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _colProduct,
            child: Text('TOTAL (${controller.filteredItems.length} items)',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
          ),
          SizedBox(width: _colQty),
          SizedBox(width: _colUnitCost),
          SizedBox(
            width: _colTotal,
            child: Text(_fmt(controller.totalCostValue),
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E2F))),
          ),
          SizedBox(width: _colStatus),
        ],
      ),
    ));
  }

  // ── Product Detail Bottom Sheet ───────────────
  void _showProductDetail(Map<String, dynamic> item) {
    final status = controller.getItemStatus(item);
    final statusColor = controller.getStatusColor(status);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2F))),
                      const SizedBox(height: 4),
                      Text('${item['category'] ?? ''}  •  ${item['sku'] ?? ''}',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _detailRow('Quantity in Stock',  '${item['qty'] ?? 0} units',                  Colors.blue),
            _detailRow('Unit Cost Price',    _fmt(item['unitCost'] ?? 0),                  Colors.indigo),
            _detailRow('Selling Price',      _fmt(item['sellingPrice'] ?? 0),              Colors.green),
            _detailRow('Total Cost Value',   _fmt(item['totalCostValue'] ?? 0),            Colors.blue),
            _detailRow('Total Sell Value',   _fmt(item['sellingValue'] ?? 0),              Colors.green),
            _detailRow('Potential Profit',   _fmt((item['potentialProfit'] ?? 0).toDouble()),
                (item['potentialProfit'] ?? 0) >= 0 ? Colors.purple : Colors.red),
            _detailRow('Profit Margin',      '${(item['profitMargin'] ?? 0).toStringAsFixed(1)}%', Colors.purple),
            _detailRow('Status',             status, statusColor),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Close', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          Text(value,  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // PDF / SHARE / PRINT FUNCTIONS
  // ══════════════════════════════════════════════

  // ── Permission ───────────────────────────────
  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+ – no storage permission needed for Downloads
      await Permission.notification.request();
      return true;
    } else if (sdkInt >= 30) {
      // Android 11-12
      final status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;
      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) { _showPermissionDialog(); return false; }
      return false;
    } else {
      // Android 10 and below
      final status = await Permission.storage.status;
      if (status.isGranted) return true;
      final result = await Permission.storage.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) { _showPermissionDialog(); return false; }
      return false;
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'PDF save karne ke liye storage permission chahiye.\n\n'
          'Please Settings mein ja kar permission grant karein.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async { Get.back(); await openAppSettings(); },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ── Generate & Download PDF ──────────────────
  Future<void> _generateAndDownloadPDF() async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdfFile = await _generatePDF();
      if (Get.isDialogOpen ?? false) Get.back();

      if (pdfFile != null) {
        final savedPath = await _saveToDownloads(pdfFile);
        if (savedPath != null) {
          await _showNotification('PDF Downloaded', 'Inventory Valuation report Downloads ');
          Get.snackbar(
            'Success',
            'PDF download ho gayi!\nPath: $savedPath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar('Error', 'PDF save karne mein masla aaya',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'PDF generate karne mein masla: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // ── Core PDF builder ─────────────────────────
  Future<File?> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _pdfHeader(),
        footer: (ctx) => _pdfFooter(ctx),
        build: (_) => [
          _pdfTitle(),
          pw.SizedBox(height: 6),
          _pdfDateLine(),
          pw.SizedBox(height: 16),
          _pdfSummaryGrid(),
          pw.SizedBox(height: 16),
          _pdfInsightsRow(),
          pw.SizedBox(height: 16),
          _pdfTable(),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/inventory_valuation_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _pdfHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Warehouse Management System',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text('Inventory Valuation Report',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  pw.Widget _pdfTitle() {
    return pw.Text(
      'Inventory Valuation Report',
      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
    );
  }

  pw.Widget _pdfDateLine() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Report Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _pdfSummaryGrid() {
    return pw.Row(
      children: [
        _pdfSummaryBox('Total Cost Value',     _fmt(controller.totalCostValue),       PdfColors.blue800),
        pw.SizedBox(width: 8),
        _pdfSummaryBox('Total Sell Value',     _fmt(controller.totalSellingValue),    PdfColors.green800),
        pw.SizedBox(width: 8),
        _pdfSummaryBox('Potential Profit',     _fmt(controller.totalPotentialProfit), PdfColors.purple800),
        pw.SizedBox(width: 8),
        _pdfSummaryBox('Dead Stock Value',     _fmt(controller.deadStockValue),       PdfColors.red800),
      ],
    );
  }

  pw.Widget _pdfSummaryBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfInsightsRow() {
    return pw.Row(
      children: [
        _pdfInsightBox('Fast Moving', '${controller.fastMovingCount} items', PdfColors.green700),
        pw.SizedBox(width: 8),
        _pdfInsightBox('Overstock',   '${controller.overStockCount} items',  PdfColors.orange700),
        pw.SizedBox(width: 8),
        _pdfInsightBox('Dead Stock',  '${controller.deadStockCount} items',  PdfColors.red700),
        pw.SizedBox(width: 8),
        _pdfInsightBox('Total Items', '${controller.totalItems} items',       PdfColors.indigo700),
      ],
    );
  }

  pw.Widget _pdfInsightBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            pw.Text(value, style: pw.TextStyle(fontSize: 11, color: color, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfTable() {
    final headers = ['Product', 'SKU', 'Category', 'Qty', 'Unit Cost', 'Total Value', 'Status'];
    final data = controller.filteredItems.map((item) {
      final status = controller.getItemStatus(item);
      return [
        item['name'] ?? '',
        item['sku'] ?? '',
        item['category'] ?? '',
        '${item['qty'] ?? 0}',
        _fmt(item['unitCost'] ?? 0),
        _fmt(item['totalCostValue'] ?? 0),
        status,
      ];
    }).toList();

    // Add total footer row
    data.add([
      'TOTAL (${controller.filteredItems.length} items)', '', '', '', '',
      _fmt(controller.totalCostValue), '',
    ]);

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
      cellStyle: const pw.TextStyle(fontSize: 8),
      rowDecoration: pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey50),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
      },
    );
  }

  // ── Save to Downloads ────────────────────────
  Future<String?> _saveToDownloads(File pdfFile) async {
    try {
      String downloadsPath;

      if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        downloadsPath = dir.path;
      }

      final dir = Directory(downloadsPath);
      if (!await dir.exists()) await dir.create(recursive: true);

      final fileName = 'Inventory_Valuation_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final savedFile = File('$downloadsPath/$fileName');
      await pdfFile.copy(savedFile.path);

      if (Platform.isAndroid) await _makeFileVisible(savedFile.path);

      return savedFile.path;
    } catch (e) {
      print('Downloads save error: $e');
      // Fallback
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'Inventory_Valuation_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final savedFile = File('${dir.path}/$fileName');
        await pdfFile.copy(savedFile.path);
        return savedFile.path;
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _makeFileVisible(String filePath) async {
    const platform = MethodChannel('com.example.warehouse_app/fileprovider');
    try {
      await platform.invokeMethod('scanFile', {'path': filePath});
    } catch (e) {
      print('File scan (non-critical): $e');
    }
  }

  // ── Notification ─────────────────────────────
  Future<void> _showNotification(String title, String body) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    ));

    await plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pdf_download_channel', 'PDF Downloads',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Share ────────────────────────────────────
  Future<void> _shareReport() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final pdfFile = await _generatePDF();
      if (Get.isDialogOpen ?? false) Get.back();

      if (pdfFile != null) {
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: 'Inventory Valuation Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Share karne mein masla aaya',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // ── Print ────────────────────────────────────
  Future<void> _printReport() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final pdfFile = await _generatePDF();
      if (Get.isDialogOpen ?? false) Get.back();

      if (pdfFile != null) {
        await Printing.layoutPdf(
          onLayout: (format) async => await pdfFile.readAsBytes(),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Print karne mein masla aaya',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}