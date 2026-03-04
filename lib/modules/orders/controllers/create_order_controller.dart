// lib/modules/admin/orders/controllers/create_order_controller.dart (Fixed)

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

  // Data
  final items = <Map<String, dynamic>>[].obs;
  final products = <ProductModel>[].obs;
  
  // Totals
  final subtotal = 0.0.obs;
  final discount = 0.0.obs;      // 👈 Observable for discount
  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    
    // 👈 Discount observable ko listen karo
    ever(discount, (_) => calculateTotal());
  }

  @override
  void onReady() {
    super.onReady();
    // 👈 TextEditingController ko listen karo
    discountController.addListener(_onDiscountChanged);
  }

  @override
  void onClose() {
    // 👈 Listener remove karo
    discountController.removeListener(_onDiscountChanged);
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerAddressController.dispose();
    discountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // 👈 Discount change listener
  void _onDiscountChanged() {
    final value = double.tryParse(discountController.text) ?? 0.0;
    discount.value = value;
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      products.value = await _productRepository.getProducts();
    } finally {
      isLoading.value = false;
    }
  }

  void showAddProductDialog() {
    final quantityController = TextEditingController();
    final selectedProduct = Rxn<ProductModel>();

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
                    child: Text('${product.name} (₹${product.sellingPrice})'),
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
                addItem(
                  selectedProduct.value!,
                  int.parse(quantityController.text),
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addItem(ProductModel product, int quantity) {
    items.add({
      'id': product.id,
      'name': product.name,
      'price': product.sellingPrice,
      'quantity': quantity,
    });
    calculateTotal();
    
    Get.snackbar(
      'Success',
      'Product added to order',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void removeItem(int index) {
    items.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    // Calculate subtotal
    subtotal.value = items.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });

    // Calculate total
    total.value = subtotal.value - discount.value;
  }

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
        productSku: '', // Will be fetched from product
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

      await _orderRepository.createOrder(order);

      Get.snackbar(
        'Success',
        'Order created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}