import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/oredr_repository.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';

import '../../../../data/models/order_model.dart';
import '../../../../data/models/product_model.dart';

class CreateOrderController extends GetxController {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  CreateOrderController({
    required OrderRepository orderRepository,
    required ProductRepository productRepository,
  })  : _orderRepository = orderRepository,
        _productRepository = productRepository;

  // Form
  final formKey = GlobalKey<FormState>();
  
  // Controllers
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final discountController = TextEditingController();
  final notesController = TextEditingController();

  // State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isScanning = false.obs; // New: For showing scanning indicator

  // Data
  final items = <Map<String, dynamic>>[].obs;
  final products = <ProductModel>[].obs;
  final recentScans = <String>[].obs; // Store recent barcodes for quick access
  
  // Totals
  final subtotal = 0.0.obs;
  final discount = 0.0.obs;
  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    ever(discount, (_) => calculateTotal());
  }

  @override
  void onReady() {
    super.onReady();
    discountController.addListener(_onDiscountChanged);
  }

  @override
  void onClose() {
    discountController.removeListener(_onDiscountChanged);
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerAddressController.dispose();
    discountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _onDiscountChanged() {
    final value = double.tryParse(discountController.text) ?? 0.0;
    discount.value = value;
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      print("📦 Loading products for order...");
      products.value = await _productRepository.getProducts(limit: 100);
      print("✅ Loaded ${products.length} products");
    } catch (e) {
      print('❌ Error loading products: $e');
      Get.snackbar(
        'Error',
        'Failed to load products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== NEW: BARCODE SEARCH METHOD ====================
  
  /// Search product by barcode
  Future<void> searchProductByBarcode(String barcode) async {
    print("🔍 Searching for barcode: $barcode");
    
    try {
      isScanning.value = true;
      
      // Add to recent scans
      if (!recentScans.contains(barcode)) {
        recentScans.add(barcode);
      }
      
      // First check in already loaded products
      ProductModel? foundProduct = products.firstWhereOrNull(
        (p) => p.barcode == barcode
      );
      
      // If not found, search from API
      if (foundProduct == null) {
        print("🔄 Product not in cache, searching API...");
        foundProduct = await _productRepository.getProductByBarcode(barcode);
      }
      
      if (foundProduct != null) {
        print("✅ Product found: ${foundProduct.name}");
        _showQuantityDialog(foundProduct);
      } else {
        print("❌ Product not found for barcode: $barcode");
        _showProductNotFoundDialog(barcode);
      }
      
    } catch (e) {
      print('❌ Error searching barcode: $e');
      Get.snackbar(
        'Error',
        'Failed to search product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isScanning.value = false;
    }
  }

  /// Show quantity dialog for scanned product
  void _showQuantityDialog(ProductModel product) {
    final quantityController = TextEditingController(text: '1');
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add to Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product.sku}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: ₹${product.sellingPrice}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.currentStock > 0 
                              ? Colors.green.shade100 
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stock: ${product.currentStock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.currentStock > 0 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Quantity field
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_cart),
              ),
              autofocus: true,
            ),
            
            if (product.currentStock < 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Low stock! Only ${product.currentStock} left',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              
              if (quantity <= 0) {
                Get.snackbar('Error', 'Quantity must be greater than 0');
                return;
              }
              
              if (quantity > product.currentStock) {
                Get.snackbar(
                  'Error', 
                  'Insufficient stock. Available: ${product.currentStock}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              addItem(product, quantity);
              Get.back(); // Close dialog
              
              // Show success message
              Get.snackbar(
                'Success',
                '${product.name} added to order',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 1),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E2F),
            ),
            child: const Text('Add to Order'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when product not found
  void _showProductNotFoundDialog(String barcode) {
    Get.dialog(
      AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Barcode: $barcode',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No product found with this barcode',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Get.back(); // Close this dialog
              Get.toNamed('/products/add', arguments: {
                'prefillBarcode': barcode,
              });
            },
            child: const Text('Add New Product'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close this dialog
              _showManualEntryDialog(barcode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E2F),
            ),
            child: const Text('Enter Manually'),
          ),
        ],
      ),
    );
  }

  /// Manual entry for products not in system
  void _showManualEntryDialog(String barcode) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Product Manually'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Barcode: $barcode',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                Get.snackbar('Error', 'Please fill all fields');
                return;
              }
              
              final price = double.tryParse(priceController.text) ?? 0;
              if (price <= 0) {
                Get.snackbar('Error', 'Invalid price');
                return;
              }
              
              // Add as temporary item
              items.add({
                'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
                'name': nameController.text,
                'sku': 'MANUAL',
                'price': price,
                'quantity': 1,
                'barcode': barcode,
                'isManual': true,
              });
              
              calculateTotal();
              Get.back();
              
              Get.snackbar(
                'Success',
                'Product added manually',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E2F),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ==================== EXISTING METHODS (Modified) ====================

  void showAddProductDialog() {
    final quantityController = TextEditingController();
    final selectedProduct = Rxn<ProductModel>();

    if (products.isEmpty) {
      Get.snackbar(
        'Error',
        'No products available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<ProductModel>(
                hint: const Text('Select Product'),
                isExpanded: true,
                underline: const SizedBox(),
                value: selectedProduct.value,
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text('${product.name} - ₹${product.sellingPrice} (Stock: ${product.currentStock})'),
                  );
                }).toList(),
                onChanged: (value) => selectedProduct.value = value,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedProduct.value != null && quantityController.text.isNotEmpty) {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity <= 0) {
                  Get.snackbar('Error', 'Quantity must be greater than 0');
                  return;
                }
                if (quantity > selectedProduct.value!.currentStock) {
                  Get.snackbar(
                    'Error', 
                    'Insufficient stock. Available: ${selectedProduct.value!.currentStock}'
                  );
                  return;
                }
                addItem(selectedProduct.value!, quantity);
                Get.back();
              } else {
                Get.snackbar('Error', 'Please select product and enter quantity');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addItem(ProductModel product, int quantity) {
    final existingIndex = items.indexWhere((item) => item['id'] == product.id);
    
    if (existingIndex >= 0) {
      final newQuantity = items[existingIndex]['quantity'] + quantity;
      if (newQuantity > product.currentStock) {
        Get.snackbar(
          'Error',
          'Total quantity exceeds available stock. Available: ${product.currentStock}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      items[existingIndex]['quantity'] = newQuantity;
    } else {
      items.add({
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'price': product.sellingPrice,
        'quantity': quantity,
        'barcode': product.barcode,
      });
    }
    
    calculateTotal();
  }

  void removeItem(int index) {
    items.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    subtotal.value = items.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
    total.value = subtotal.value - discount.value;
  }

  // Clear form
  void _clearForm() {
    customerNameController.clear();
    customerPhoneController.clear();
    customerAddressController.clear();
    discountController.clear();
    notesController.clear();
    items.clear();
    subtotal.value = 0.0;
    discount.value = 0.0;
    total.value = 0.0;
    print("✅ Form cleared successfully");
  }

  // Create order
  Future<void> createOrder() async {
    if (!formKey.currentState!.validate()) return;

    if (items.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final orderItems = items.map((item) => OrderItem(
        productId: item['id'],
        productName: item['name'],
        productSku: item['sku'] ?? '',
        quantity: item['quantity'],
        price: item['price'].toDouble(),
      )).toList();

      final order = OrderModel(
        id: '',
        orderNumber: '',
        orderDate: DateTime.now(),
        customerName: customerNameController.text.isNotEmpty ? customerNameController.text : null,
        customerPhone: customerPhoneController.text.isNotEmpty ? customerPhoneController.text : null,
        customerAddress: customerAddressController.text.isNotEmpty ? customerAddressController.text : null,
        items: orderItems,
        status: OrderStatus.pending,
        subtotal: subtotal.value,
        discount: discount.value,
        total: total.value,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        createdBy: 'Admin',
        createdAt: DateTime.now(),
      );

      final createdOrder = await _orderRepository.createOrder(order);
      
      final orderNumber = createdOrder.orderNumber.isNotEmpty 
          ? createdOrder.orderNumber 
          : 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      Get.snackbar(
        'Success',
        'Order created successfully. Order #$orderNumber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      _clearForm();
      Get.back(result: true);
      
    } catch (e) {
      print('❌ Create order error: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Customer name is required';
    }
    return null;
  }
}