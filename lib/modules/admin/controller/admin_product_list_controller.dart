// lib/modules/admin/products/controllers/product_list_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_model.dart';

// lib/modules/admin/products/controllers/product_list_controller.dart

class ProductListController extends GetxController {
  final ProductRepository _repository;

  ProductListController({required ProductRepository repository})
      : _repository = repository;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;

  // Data
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedStockStatus = Rxn<String>();
  final sortBy = 'name'.obs;
  final sortAscending = true.obs;
  
  // View mode
  final isGridView = true.obs;

  // Stock status options
  final stockStatusOptions = [
    {'value': '', 'label': 'All Status'},
    {'value': 'low_stock', 'label': 'Low Stock'},
    {'value': 'out_of_stock', 'label': 'Out of Stock'},
    {'value': 'expiring', 'label': 'Expiring Soon'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
    
    debounce(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final results = await Future.wait([
        _repository.getProducts(),
        _repository.getCategories(),
      ]);

      products.value = results[0] as List<ProductModel>;
      categories.value = results[1] as List<CategoryModel>;
      
      applyFilters();
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      await loadData();
    } finally {
      isRefreshing.value = false;
    }
  }

  void applyFilters() {
    List<ProductModel> filtered = List.from(products);

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        p.sku.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Apply category filter - FIXED
    if (selectedCategory.value != null) {
      filtered = filtered.where((p) => 
        p.categoryId == selectedCategory.value!.id
      ).toList();
    }

    // Apply stock status filter
    if (selectedStockStatus.value != null && selectedStockStatus.value!.isNotEmpty) {
      switch (selectedStockStatus.value) {
        case 'low_stock':
          filtered = filtered.where((p) => p.isLowStock).toList();
          break;
        case 'out_of_stock':
          filtered = filtered.where((p) => p.isOutOfStock).toList();
          break;
        case 'expiring':
          filtered = filtered.where((p) => p.isExpiringSoon).toList();
          break;
      }
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'name':
        filtered.sort((a, b) => sortAscending.value
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'price':
        filtered.sort((a, b) => sortAscending.value
            ? a.sellingPrice.compareTo(b.sellingPrice)
            : b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'stock':
        filtered.sort((a, b) => sortAscending.value
            ? a.currentStock.compareTo(b.currentStock)
            : b.currentStock.compareTo(a.currentStock));
        break;
      case 'date':
        filtered.sort((a, b) => sortAscending.value
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }

    filteredProducts.value = filtered;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void toggleSortOrder() {
    sortAscending.value = !sortAscending.value;
    applyFilters();
  }

  void setSortBy(String value) {
    sortBy.value = value;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = null;
    selectedStockStatus.value = null;
    sortBy.value = 'name';
    sortAscending.value = true;
    applyFilters();
  }

  void navigateToAddProduct() {
    Get.toNamed(AppRoutes.AddProduct);
  }

  void navigateToProductDetails(String productId) {
  // Method 1: Using named route with parameters
  Get.toNamed(
    AppRoutes.productDetail.replaceFirst(':productId', productId),
  );  }

  int get totalProducts => products.length;
  int get filteredCount => filteredProducts.length;
  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;
}