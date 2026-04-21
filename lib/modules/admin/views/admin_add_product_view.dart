// lib/modules/admin/views/add_product_view.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:warehouse_management_app/data/models/category_model.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_add_product_controller.dart';
import 'package:warehouse_management_app/widgets/image_picker_widget.dart';
import 'package:warehouse_management_app/widgets/location_selector_widget.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/loading_widget.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  // ── Notifications ──────────────────────────────
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();
  static bool _notifInit = false;

  static Future<void> _initNotif() async {
    if (_notifInit) return;
    await _notif.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    _notifInit = true;
  }

  // ── PDF fonts ──────────────────────────────────
  static pw.Font? _font;
  static pw.Font? _fontBold;

  static Future<void> _loadFont() async {
    if (_font != null) return;
    _font     = await PdfGoogleFonts.notoSansRegular();
    _fontBold = await PdfGoogleFonts.notoSansBold();
  }

  static pw.TextStyle _s({double sz = 10, PdfColor c = PdfColors.black}) =>
      pw.TextStyle(font: _font, fontSize: sz, color: c);
  static pw.TextStyle _b({double sz = 10, PdfColor c = PdfColors.black}) =>
      pw.TextStyle(font: _fontBold, fontSize: sz, color: c);

  // ════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    _initNotif();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading product data...');
        }
        return _buildForm(context);
      }),
    );
  }

  // ════════════════════════════════════════════
  // APP BAR
  // ════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
        onPressed: controller.cancel,
      ),
      title:  Text(
        controller.isEditing.value ? 'Edit Product' : 'Add Product',
        style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F)),
      ),
      centerTitle: true,
      actions: [
        Obx(() => TextButton(
          onPressed:
              controller.isSubmitting.value ? null : controller.saveProduct,
          child: Text(
            'Save',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: controller.isSubmitting.value
                  ? Colors.grey.shade400
                  : const Color(0xFF1E1E2F),
            ),
          ),
        )),
      ],
    );
  }

  // ════════════════════════════════════════════
  // MAIN FORM
  // ════════════════════════════════════════════
  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ══════════════════════════════════
            // PRODUCT IMAGES
            // ══════════════════════════════════
            _buildSectionTitle('Product Images'),
            const SizedBox(height: 8),

          ImagePickerWidget(
              images: controller.images,
              onPickImage: controller.pickImage,
              onRemoveImage: controller.removeImage,
            ),

            // ✅ Image error message
            Obx(() {
              if (controller.imageError.value != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    controller.imageError.value!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 20),

            // ══════════════════════════════════
            // BASIC INFORMATION
            // ══════════════════════════════════
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),

            // Product Name
            _buildLabel('Product Name *'),
            const SizedBox(height: 4),
           TextFormField(
              controller: controller.nameController,
              validator: controller.validateName,
              enabled: !controller.isSubmitting.value,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                hint: 'Enter product name',
                prefixIcon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // ── SKU + Barcode Row ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SKU
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildLabel('SKU *'),
                          const SizedBox(width: 6),
                          // ✅ Auto-generated badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Auto',
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Obx(() => TextFormField(
                        controller: controller.skuController,
                        validator: controller.validateSku,
                        enabled: !controller.isSubmitting.value,
                        decoration: _inputDecoration(
                          hint: 'SKU-001',
                          prefixIcon: Icons.qr_code_2,
                          suffixWidget: Tooltip(
                            message: 'Naya SKU generate karein',
                            child: GestureDetector(
                              onTap: controller.isSubmitting.value
                                  ? null
                                  : () {
                                      final ts = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      controller.skuController.text =
                                          'SKU-${ts.substring(ts.length - 6)}';
                                    },
                              child: Icon(Icons.refresh_rounded,
                                  size: 18,
                                  color: Colors.blue.shade400),
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Barcode
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Barcode'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => TextFormField(
                              controller: controller.barcodeController,
                              enabled: !controller.isSubmitting.value,
                              decoration: _inputDecoration(
                                hint: 'Scan or generate',
                                prefixIcon: Icons.barcode_reader,
                              ),
                            )),
                          ),
                          const SizedBox(width: 8),
                          // Barcode action menu
                          Obx(() => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              enabled: !controller.isSubmitting.value,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onSelected: (value) {
                                if (value == 'scan')
                                  controller.scanBarcode();
                                else if (value == 'generate')
                                  controller.generateBarcode();
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'scan',
                                  child: Row(children: [
                                    Icon(Icons.qr_code_scanner,
                                        size: 18, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text('Scan Barcode'),
                                  ]),
                                ),
                                const PopupMenuItem(
                                  value: 'generate',
                                  child: Row(children: [
                                    Icon(Icons.qr_code,
                                        size: 18, color: Colors.green),
                                    SizedBox(width: 10),
                                    Text('Generate Barcode'),
                                  ]),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Barcode Preview ───────────────
            Obx(() {
              if (controller.showBarcodePreview.value &&
                  controller.barcodeController.text.isNotEmpty) {
                return _buildBarcodePreview(context);
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),

            // ── Category + Supplier ───────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category *'),
                      const SizedBox(height: 4),
                      // ✅ Category with validation error UI
                      Obx(() {
                        final hasError = controller.categoryError.value != null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: hasError
                                      ? Colors.red.shade400
                                      : controller.selectedCategory.value != null
                                          ? Colors.green.shade400
                                          : Colors.grey.shade300,
                                  width: hasError ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<CategoryModel>(
                                value: controller.selectedCategory.value,
                                hint: Text('Select Category',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: hasError
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                ),
                                items: controller.categories
                                    .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat.name)))
                                    .toList(),
                                onChanged: controller.isSubmitting.value
                                    ? null
                                    : controller.selectCategory,
                              ),
                            ),
                            // ✅ Inline error text
                            if (hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  controller.categoryError.value!,
                                  style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 11),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Supplier (optional)
                if (controller.suppliers.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Supplier'),
                        const SizedBox(height: 4),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<Map<String, dynamic>>(
                            value: controller.selectedSupplier.value,
                            hint: const Text('Select Supplier'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: controller.suppliers
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s['name'])))
                                .toList(),
                            onChanged: controller.isSubmitting.value
                                ? null
                                : controller.selectSupplier,
                          ),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ══════════════════════════════════
            // PRICING
            // ══════════════════════════════════
            _buildSectionTitle('Pricing'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Cost Price *'),
                      const SizedBox(height: 4),
                      Obx(() => TextFormField(
                        controller: controller.costPriceController,
                        validator: controller.validatePrice,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        enabled: !controller.isSubmitting.value,
                        decoration: _inputDecoration(
                          hint: '0.00',
                          prefixText: '\$',
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Selling Price *'),
                      const SizedBox(height: 4),
                      Obx(() => TextFormField(
                        controller: controller.sellingPriceController,
                        validator: controller.validatePrice,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        enabled: !controller.isSubmitting.value,
                        decoration: _inputDecoration(
                          hint: '0.00',
                          prefixText: '\$',
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ══════════════════════════════════
            // STOCK
            // ══════════════════════════════════
            _buildSectionTitle('Stock Information'),
            const SizedBox(height: 12),

            _buildLabel('Current Stock *'),
            const SizedBox(height: 4),
            Obx(() => TextFormField(
              controller: controller.currentStockController,
              validator: controller.validateStock,
              keyboardType: TextInputType.number,
              enabled: !controller.isSubmitting.value,
              decoration: _inputDecoration(
                hint: '0',
                prefixIcon: Icons.inventory_outlined,
              ),
            )),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Min Stock *'),
                      const SizedBox(height: 4),
                      Obx(() => TextFormField(
                        controller: controller.minimumStockController,
                        validator: controller.validateStock,
                        keyboardType: TextInputType.number,
                        enabled: !controller.isSubmitting.value,
                        decoration: _inputDecoration(hint: '5'),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Max Stock *'),
                      const SizedBox(height: 4),
                      Obx(() => TextFormField(
                        controller: controller.maximumStockController,
                        validator: controller.validateStock,
                        keyboardType: TextInputType.number,
                        enabled: !controller.isSubmitting.value,
                        decoration: _inputDecoration(hint: '100'),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ══════════════════════════════════
            // LOCATION
            // ══════════════════════════════════
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            LocationSelector(
              aisles: controller.aisles,
              racks: controller.racks,
              bins: controller.bins,
              selectedAisle: controller.selectedAisle,
              selectedRack: controller.selectedRack,
              selectedBin: controller.selectedBin,
            ),
            const SizedBox(height: 8),
           Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${controller.locationController.text}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Expiry Date ───────────────────
            _buildLabel('Expiry Date (Optional)'),
            const SizedBox(height: 4),
            Obx(() => InkWell(
              onTap: controller.isSubmitting.value
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) controller.selectExpiryDate(date);
                    },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.expiryDate.value != null
                          ? '${controller.expiryDate.value!.day}/${controller.expiryDate.value!.month}/${controller.expiryDate.value!.year}'
                          : 'Select expiry date',
                      style: TextStyle(
                        color: controller.expiryDate.value != null
                            ? const Color(0xFF1E1E2F)
                            : Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey.shade500),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),

            // ── Description ───────────────────
            _buildLabel('Description (Optional)'),
            const SizedBox(height: 4),
            Obx(() => TextFormField(
              controller: controller.descriptionController,
              maxLines: 3,
              enabled: !controller.isSubmitting.value,
              decoration: _inputDecoration(
                hint: 'Product ke baare mein likhein...',
              ).copyWith(contentPadding: const EdgeInsets.all(12)),
            )),
            const SizedBox(height: 28),

            // ── Save / Cancel ─────────────────
            Row(
              children: [
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'Cancel',
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.cancel,
                    backgroundColor: Colors.grey.shade100,
                    textColor: const Color(0xFF1E1E2F),
                    height: 48,
                    borderRadius: 10,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => CustomButton(
                    text: controller.isEditing.value ? 'Update' : 'Save',
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.saveProduct,
                    isLoading: controller.isSubmitting.value,
                    backgroundColor: const Color(0xFF1E1E2F),
                    textColor: Colors.white,
                    height: 48,
                    borderRadius: 10,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // BARCODE PREVIEW CARD (with PDF + Print)
  // ════════════════════════════════════════════
  Widget _buildBarcodePreview(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.barcode_reader,
                          size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text('Barcode Preview',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E1E2F))),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showBarcodeDialog(context),
                        icon: const Icon(Icons.fullscreen, size: 16),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.clearBarcode,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barcode image
              Center(
                child: Screenshot(
                  controller: controller.screenshotController,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    color: Colors.white,
                    child: BarcodeWidget(
                      barcode: Barcode.ean13(),
                      data: controller.barcodeController.text,
                      width: 180,
                      height: 65,
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Barcode number + copy
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.barcodeController.text,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: controller.barcodeController.text));
                        Get.snackbar('Copied!', 'Barcode copy ho gaya',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 1),
                            margin: const EdgeInsets.all(16),
                            backgroundColor: const Color(0xFF1E1E2F),
                            colorText: Colors.white);
                      },
                      child: Icon(Icons.copy_rounded,
                          size: 15, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // PDF + Print buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadBarcodePdf(context),
                      icon: const Icon(Icons.picture_as_pdf,
                          size: 16, color: Colors.red),
                      label: Text('Save PDF',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printBarcode(context),
                      icon: const Icon(Icons.print,
                          size: 16, color: Colors.green),
                      label: Text('Print',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // PDF DOWNLOAD
  // ════════════════════════════════════════════
  Future<void> _downloadBarcodePdf(BuildContext context) async {
    try {
      if (!await _reqPerm()) return;
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      await _loadFont();
      final pdfFile = await _buildBarcodePdf();
      if (Get.isDialogOpen ?? false) Get.back();
      final savedPath = await _savePdf(pdfFile);
      if (savedPath != null) {
        await _showNotif(
            'Barcode PDF Downloaded', 'Downloads folder mein save ho gayi');
        Get.snackbar('✅ Success', 'Barcode PDF save ho gayi!\n$savedPath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16));
      } else {
        Get.snackbar('Error', 'PDF save nahi hui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', '$e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // ════════════════════════════════════════════
  // PRINT
  // ════════════════════════════════════════════
  Future<void> _printBarcode(BuildContext context) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      await _loadFont();
      final pdfFile = await _buildBarcodePdf();
      if (Get.isDialogOpen ?? false) Get.back();
      await Printing.layoutPdf(
          onLayout: (_) => pdfFile.readAsBytesSync());
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', '$e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // ════════════════════════════════════════════
  // BUILD BARCODE PDF
  // ════════════════════════════════════════════
  Future<File> _buildBarcodePdf() async {
    final barcodeValue = controller.barcodeController.text;
    final productName  = controller.nameController.text.isEmpty
        ? 'Product'
        : controller.nameController.text;
    final sku          = controller.skuController.text;

    final Uint8List? barcodeImage =
        await controller.screenshotController.capture(pixelRatio: 3.0);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                color: PdfColors.indigo900,
                borderRadius:
                    pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Barcode Label',
                      style: _b(sz: 20, c: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('Warehouse Management System',
                      style: _s(sz: 11, c: PdfColors.grey300)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Text('Product Name:  ',
                        style: _b(sz: 12, c: PdfColors.grey700)),
                    pw.Text(productName, style: _s(sz: 12)),
                  ]),
                  if (sku.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Row(children: [
                      pw.Text('SKU:           ',
                          style: _b(sz: 12, c: PdfColors.grey700)),
                      pw.Text(sku, style: _s(sz: 12)),
                    ]),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 28),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (barcodeImage != null)
                    pw.Image(
                      pw.MemoryImage(barcodeImage),
                      width: 280,
                      height: 100,
                      fit: pw.BoxFit.contain,
                    )
                  else
                    pw.Text('[Barcode Image]',
                        style: _s(sz: 12, c: PdfColors.grey600)),
                  pw.SizedBox(height: 10),
                  pw.Text(barcodeValue, style: _b(sz: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius:
                    pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'Scan this barcode to identify the product in the warehouse system.',
                style: _s(sz: 10, c: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Spacer(),
            pw.Text(
              'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  '
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: _s(sz: 9, c: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );

    final dir  = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ════════════════════════════════════════════
  // PERMISSIONS + SAVE PDF
  // ════════════════════════════════════════════
  Future<bool> _reqPerm() async {
    if (Platform.isIOS) return true;
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdk >= 33) {
      await Permission.notification.request();
      return true;
    }
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
        content: const Text(
            'PDF save karne ke liye storage permission chahiye.\nSettings mein ja kar grant karein.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
              child: const Text('Open Settings')),
        ],
      ));

  Future<String?> _savePdf(File pdf) async {
    try {
      final dir  = Platform.isAndroid
          ? '/storage/emulated/0/Download'
          : (await getApplicationDocumentsDirectory()).path;
      final dest = Directory(dir);
      if (!await dest.exists()) await dest.create(recursive: true);
      final name =
          'Barcode_${controller.barcodeController.text}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final out = await pdf.copy('$dir/$name');
      if (Platform.isAndroid) {
        try {
          await const MethodChannel(
                  'com.example.warehouse_app/fileprovider')
              .invokeMethod('scanFile', {'path': out.path});
        } catch (_) {}
      }
      return out.path;
    } catch (e) {
      try {
        final fb   = await getApplicationDocumentsDirectory();
        final name =
            'Barcode_${controller.barcodeController.text}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final out  = await pdf.copy('${fb.path}/$name');
        return out.path;
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _showNotif(String title, String body) async {
    await _notif.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('pdf_ch', 'PDF Downloads',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ════════════════════════════════════════════
  // BARCODE FULLSCREEN DIALOG
  // ════════════════════════════════════════════
  void _showBarcodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Barcode',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Screenshot(
                controller: controller.screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: BarcodeWidget(
                    barcode: Barcode.ean13(),
                    data: controller.barcodeController.text,
                    width: 280,
                    height: 100,
                    decoration:
                        const BoxDecoration(color: Colors.transparent),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(controller.barcodeController.text,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close',
                      style:
                          GoogleFonts.inter(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════
  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E2F))),
      );

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700),
      );

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    String? prefixText,
    Widget? suffixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixText: prefixText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: Colors.grey.shade500)
          : null,
      suffix: suffixWidget,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF1E1E2F), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
      errorStyle: TextStyle(color: Colors.red.shade600, fontSize: 11),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
    );
  }
}