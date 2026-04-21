// lib/modules/admin/controller/admin_add_product_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http_parser/http_parser.dart';
import 'package:warehouse_management_app/widgets/barcode_scanner_widget.dart';
import '../../../../data/models/category_model.dart';

class AddProductController extends GetxController {
  final ProductRepository _repository;

  AddProductController({required ProductRepository repository})
      : _repository = repository;

  final formKey      = GlobalKey<FormState>();
  final isLoading    = false.obs;
  final isSubmitting = false.obs;
  final isEditing    = false.obs;
  String? productId;

  // Text Controllers
  final nameController         = TextEditingController();
  final skuController          = TextEditingController();
  final barcodeController      = TextEditingController();
  final sellingPriceController = TextEditingController();
  final costPriceController    = TextEditingController();
  final currentStockController = TextEditingController();
  final minimumStockController = TextEditingController();
  final maximumStockController = TextEditingController();
  final locationController     = TextEditingController();
  final descriptionController  = TextEditingController();

  // Observables
  final selectedCategory  = Rxn<CategoryModel>();
  final selectedSupplier  = Rxn<Map<String, dynamic>>();
  final expiryDate        = Rxn<DateTime>();

  // ✅ FIX 1: RxList<File> — UI reactive hogi image changes pe
  final images   = RxList<File>([]);
  final categories = <CategoryModel>[].obs;
  final suppliers  = <Map<String, dynamic>>[].obs;

  final showBarcodePreview = false.obs;
  final barcodeImageFile   = Rxn<File>();
  final ScreenshotController screenshotController = ScreenshotController();

  // ✅ NEW: Custom validation error states
  final categoryError = RxnString(); // null = no error
  final imageError    = RxnString();

  // Dropdowns
  final aisles = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final racks  = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final bins   = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10'];

  final selectedAisle = 'A'.obs;
  final selectedRack  = '1'.obs;
  final selectedBin   = 'B1'.obs;

  final ApiService _apiService = Get.find<ApiService>();

  // ════════════════════════════════════════════
  // LIFECYCLE
  // ════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    if (Get.arguments != null) {
      productId = Get.arguments['productId'];
      if (productId != null) {
        isEditing.value = true;
        loadProductData(productId!);
      }
    } else {
      // ✅ FIX 2: Add mode — SKU auto generate on screen open
      _autoGenerateSku();
    }

    ever(selectedAisle, (_) => updateLocation());
    ever(selectedRack,  (_) => updateLocation());
    ever(selectedBin,   (_) => updateLocation());
    updateLocation();
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    sellingPriceController.dispose();
    costPriceController.dispose();
    currentStockController.dispose();
    minimumStockController.dispose();
    maximumStockController.dispose();
    locationController.dispose();
    descriptionController.dispose();

    if (barcodeImageFile.value != null &&
        barcodeImageFile.value!.existsSync()) {
      barcodeImageFile.value!.deleteSync();
    }
    super.onClose();
  }

  // ════════════════════════════════════════════
  // ✅ AUTO SKU — timestamp based unique SKU
  // ════════════════════════════════════════════
  void _autoGenerateSku() {
    final ts     = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = ts.substring(ts.length - 6); // last 6 digits
    skuController.text = 'SKU-$suffix';
  }

  // ════════════════════════════════════════════
  // LOAD DATA
  // ════════════════════════════════════════════
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      final cats = await _repository.getCategories();
      categories.value = cats;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProductData(String id) async {
    try {
      isLoading.value = true;
      final product = await _repository.getProductById(id);

      if (product != null) {
        nameController.text         = product.name;
        skuController.text          = product.sku;
        barcodeController.text      = product.barcode ?? '';
        sellingPriceController.text = product.sellingPrice.toString();
        costPriceController.text    = product.costPrice.toString();
        currentStockController.text = product.currentStock.toString();
        minimumStockController.text = product.minimumStock.toString();
        maximumStockController.text = product.maximumStock.toString();
        descriptionController.text  = product.description ?? '';

        selectedCategory.value =
            categories.firstWhereOrNull((c) => c.id == product.categoryId);
        expiryDate.value = product.expiryDate;

        final locParts = product.location.split('-');
        if (locParts.length == 3) {
          selectedAisle.value = locParts[0];
          selectedRack.value  = locParts[1];
          selectedBin.value   = locParts[2];
        }

        if (product.barcode != null && product.barcode!.isNotEmpty) {
          showBarcodePreview.value = true;
          await _generateBarcodeImageFromText(product.barcode!);
        }

        // ✅ FIX 3: assignAll use karo — ek baar mein puri list update
        if (product.imageUrls.isNotEmpty) {
          final loadedImages = <File>[];
          for (final url in product.imageUrls) {
            try {
              final res = await http.get(Uri.parse(url));
              if (res.statusCode == 200) {
                final tempDir  = await getTemporaryDirectory();
                final tempFile = File(
                    '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await tempFile.writeAsBytes(res.bodyBytes);
                loadedImages.add(tempFile);
              }
            } catch (_) {}
          }
          images.assignAll(loadedImages); // ✅ single rebuild
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════
  // ✅ IMAGE PICK — FIXED (images show hoti thi nahi)
  // ════════════════════════════════════════════
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source:       source,
        maxWidth:     1024,
        maxHeight:    1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        images.add(File(pickedFile.path));
        images.refresh(); // ✅ KEY FIX: force GetX to rebuild UI
        imageError.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Image pick karne mein masla: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      images.refresh(); // ✅ KEY FIX: force rebuild after remove
    }
  }

  // ════════════════════════════════════════════
  // SELECTORS
  // ════════════════════════════════════════════
  void selectCategory(CategoryModel? category) {
    selectedCategory.value = category;
    if (category != null) categoryError.value = null; // clear error on select
  }

  void selectSupplier(Map<String, dynamic>? supplier) =>
      selectedSupplier.value = supplier;

  void selectExpiryDate(DateTime? date) => expiryDate.value = date;

  void updateLocation() {
    locationController.text =
        '${selectedAisle.value}-${selectedRack.value}-${selectedBin.value}';
  }

  // ════════════════════════════════════════════
  // BARCODE
  // ════════════════════════════════════════════
  Future<void> generateBarcode() async {
    try {
      final barcode        = await _generateUniqueBarcode();
      barcodeController.text   = barcode;
      showBarcodePreview.value = true;
      await Future.delayed(const Duration(milliseconds: 150));
      await _saveBarcodeImage();
    } catch (e) {
      Get.snackbar('Error', 'Barcode generate nahi hua: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> scanBarcode() async {
    try {
      final scanned = await Get.to(
        () => const BarcodeScannerScreen(),
        fullscreenDialog: true,
      );
      if (scanned != null && scanned is String) {
        barcodeController.text   = scanned;
        showBarcodePreview.value = true;
        await _saveBarcodeImage();
        await _fetchProductDetailsFromBarcode(scanned);
      }
    } catch (e) {
      Get.snackbar('Error', 'Scan fail: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<String> _generateUniqueBarcode() async {
    final ts   = DateTime.now().millisecondsSinceEpoch.toString();
    String part = ts.length > 9 ? ts.substring(ts.length - 9) : ts.padLeft(9, '0');
    String without = '890$part';
    int    check   = _ean13Check(without);
    String barcode = '$without$check';

    if (await _checkBarcodeExists(barcode)) {
      final r    = Random();
      final rp   = (r.nextInt(900000000) + 100000000).toString();
      without    = '890$rp';
      check      = _ean13Check(without);
      barcode    = '$without$check';
    }
    return barcode;
  }

  int _ean13Check(String s12) {
    if (s12.length != 12) throw Exception('Need 12 digits');
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += (i % 2 == 0) ? int.parse(s12[i]) : int.parse(s12[i]) * 3;
    }
    return (10 - (sum % 10)) % 10;
  }

  Future<bool> _checkBarcodeExists(String barcode) async {
    try {
      final res = await _apiService.get('products/check-barcode/$barcode');
      if (res.statusCode == 200) {
        return jsonDecode(res.data)['exists'] ?? false;
      }
      return false;
    } catch (_) { return false; }
  }

  Future<void> _fetchProductDetailsFromBarcode(String barcode) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      final res = await http.get(Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json'));
      Get.back();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 1) {
          final p = data['product'];
          if (nameController.text.isEmpty && p['product_name'] != null) {
            nameController.text = p['product_name'];
          }
          Get.snackbar('Product Found', 'Details auto-fill ho gayi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      }
    } catch (_) { if (Get.isDialogOpen ?? false) Get.back(); }
  }

  Future<void> _generateBarcodeImageFromText(String text) async {
    try {
      barcodeController.text = text;
      await Future.delayed(const Duration(milliseconds: 500));
      final bytes = await screenshotController.capture();
      if (bytes != null) {
        final dir  = await getTemporaryDirectory();
        final path = '${dir.path}/barcode_${text}_${DateTime.now().millisecondsSinceEpoch}.png';
        barcodeImageFile.value = await File(path).writeAsBytes(bytes);
      }
    } catch (_) {}
  }

  Future<void> _saveBarcodeImage() async {
    if (barcodeController.text.isEmpty) return;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final bytes = await screenshotController.capture();
      if (bytes != null) {
        final dir  = await getTemporaryDirectory();
        final path = '${dir.path}/barcode_${barcodeController.text}_${DateTime.now().millisecondsSinceEpoch}.png';
        final saved = await File(path).writeAsBytes(bytes);
        if (await saved.exists()) barcodeImageFile.value = saved;
      }
    } catch (_) {}
  }

  void clearBarcode() {
    barcodeController.clear();
    showBarcodePreview.value = false;
    if (barcodeImageFile.value != null &&
        barcodeImageFile.value!.existsSync()) {
      barcodeImageFile.value!.deleteSync();
    }
    barcodeImageFile.value = null;
  }

  // ════════════════════════════════════════════
  // VALIDATORS
  // ════════════════════════════════════════════
  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Product name zaroori hai';
    if (v.trim().length < 3) return 'Kam az kam 3 characters chahiye';
    return null;
  }

  String? validateSku(String? v) {
    if (v == null || v.trim().isEmpty) return 'SKU zaroori hai';
    if (v.trim().length < 3) return 'SKU kam az kam 3 characters ka hona chahiye';
    return null;
  }

  String? validatePrice(String? v) {
    if (v == null || v.isEmpty) return 'Price zaroori hai';
    final p = double.tryParse(v);
    if (p == null) return 'Sahi number daalen';
    if (p <= 0) return 'Price 0 se zyada honi chahiye';
    return null;
  }

  String? validateStock(String? v) {
    if (v == null || v.isEmpty) return 'Stock quantity zaroori hai';
    final s = int.tryParse(v);
    if (s == null) return 'Sahi number daalen';
    if (s < 0) return 'Stock negative nahi ho sakta';
    return null;
  }

  // ════════════════════════════════════════════
  // CLEAR FORM
  // ════════════════════════════════════════════
  void _clearForm() {
    nameController.clear();
    skuController.clear();
    barcodeController.clear();
    sellingPriceController.clear();
    costPriceController.clear();
    currentStockController.clear();
    minimumStockController.clear();
    maximumStockController.clear();
    descriptionController.clear();
    locationController.text = 'A-1-B1';
    selectedAisle.value    = 'A';
    selectedRack.value     = '1';
    selectedBin.value      = 'B1';
    selectedCategory.value = null;
    selectedSupplier.value = null;
    expiryDate.value       = null;
    images.clear();
    images.refresh();
    categoryError.value    = null;
    imageError.value       = null;
    clearBarcode();
  }

  // ════════════════════════════════════════════
  // SAVE PRODUCT
  // ════════════════════════════════════════════
  Future<void> saveProduct() async {
    // Step 1: Form fields validate
    final formValid = formKey.currentState!.validate();

    // Step 2: Category validate
    if (selectedCategory.value == null) {
      categoryError.value = 'Category select karna zaroori hai';
    } else {
      categoryError.value = null;
    }

    if (!formValid || selectedCategory.value == null) return;

    // Step 3: Stock range
    final minStock = int.tryParse(minimumStockController.text) ?? 0;
    final maxStock = int.tryParse(maximumStockController.text) ?? 0;
    if (minStock >= maxStock) {
      Get.snackbar(
        'Validation Error',
        'Minimum stock, maximum stock se kam hona chahiye',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      if (barcodeController.text.isNotEmpty) {
        if (barcodeImageFile.value == null ||
            !(await barcodeImageFile.value!.exists())) {
          await _saveBarcodeImage();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (token == null) { Get.offAllNamed('/login'); return; }

      final request = http.MultipartRequest(
        isEditing.value ? 'PUT' : 'POST',
        Uri.parse(
            '${_apiService.baseUrl}/products${isEditing.value ? '/$productId' : ''}'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['name']         = nameController.text.trim();
      request.fields['sku']          = skuController.text.trim();
      request.fields['categoryId']   = selectedCategory.value!.id;
      request.fields['sellingPrice'] = sellingPriceController.text;
      request.fields['costPrice']    = costPriceController.text;
      request.fields['currentStock'] = currentStockController.text;
      request.fields['minimumStock'] = minimumStockController.text;
      request.fields['maximumStock'] = maximumStockController.text;
      request.fields['location']     = locationController.text;

      if (barcodeController.text.isNotEmpty)
        request.fields['barcodeNumber'] = barcodeController.text.trim();
      if (descriptionController.text.isNotEmpty)
        request.fields['description'] = descriptionController.text;
      if (expiryDate.value != null)
        request.fields['expiryDate'] = expiryDate.value!.toIso8601String();
      if (selectedSupplier.value != null)
        request.fields['supplierId'] =
            selectedSupplier.value!['id'].toString();

      for (final image in images) {
        if (await image.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'images', image.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      if (barcodeImageFile.value != null &&
          await barcodeImageFile.value!.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'barcodeImage', barcodeImageFile.value!.path,
          contentType: MediaType('image', 'png'),
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          '✅ Success',
          isEditing.value ? 'Product update ho gaya!' : 'Product add ho gaya!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
        if (!isEditing.value) _clearForm();
        Get.back(result: true);
      } else {
        _handleServerError(response.statusCode, response.body);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleServerError(int statusCode, String body) {
    String message;
    try {
      final err = jsonDecode(body);
      final raw = (err['message'] ?? err['error'] ?? err['msg'] ?? '').toString();
      if (raw.isNotEmpty) {
        final l = raw.toLowerCase();
        if (l.contains('barcode') &&
            (l.contains('exist') || l.contains('duplicate') || l.contains('already'))) {
          message = 'This Product is already ExistS.';
        } else if (l.contains('sku') &&
            (l.contains('exist') || l.contains('duplicate') || l.contains('already'))) {
          message = 'This product is already exist.';
        } else {
          message = raw;
        }
      } else {
        message = _msgFromCode(statusCode);
      }
    } catch (_) {
      message = _msgFromCode(statusCode);
    }

    Get.snackbar(
      statusCode == 409 || statusCode == 400 ? 'Validation Error' : 'Server Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: (statusCode == 409 || statusCode == 400)
          ? Colors.orange.shade700
          : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: Icon(
        (statusCode == 409 || statusCode == 400)
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  String _msgFromCode(int c) {
    switch (c) {
      case 400: return 'Request mein galat data hai.';
      case 409: return 'Barcode ya SKU pehle se exist karta hai.';
      case 422: return 'Validation fail hua. Sab fields sahi bharein.';
      case 500: return 'Server error. Barcode ya SKU duplicate ho sakta hai.';
      default:  return 'Kuch ghalat hua ($c). Dobara try karein.';
    }
  }

  void cancel() => Get.back();
}