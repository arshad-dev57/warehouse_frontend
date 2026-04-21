// lib/modules/admin/products/controllers/product_list_controller.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_model.dart';

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

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

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
      (_) {
        currentPage.value = 1;
        products.clear();
        loadData(reset: true);
      },
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadData({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      products.clear();
    }

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      error.value = '';

      // Build query parameters
      String? categoryId = selectedCategory.value?.id;
      String? stockStatus = selectedStockStatus.value;
      String? sortByField = sortBy.value;
      bool ascending = sortAscending.value;

      // Fetch products with filters
      final fetchedProducts = await _repository.getProducts(
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        categoryId: categoryId,
        stockStatus: stockStatus,
        sortBy: sortByField,
        ascending: ascending,
        page: currentPage.value,
        limit: 20,
      );

      // Fetch categories (only once)
      if (categories.isEmpty) {
        final fetchedCategories = await _repository.getCategories();
        categories.value = fetchedCategories;
      }

      if (currentPage.value == 1) {
        products.value = fetchedProducts;
      } else {
        products.addAll(fetchedProducts);
      }

      // Check if more data available
      hasMoreData.value = fetchedProducts.length == 20;
      
      applyFilters();
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await loadData();
  }

  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 1;
      await loadData(reset: true);
    } finally {
      isRefreshing.value = false;
    }
  }

  void applyFilters() {
    // Filtering is now done on the server side
    // We just need to update the filteredProducts list
    filteredProducts.value = products;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void toggleSortOrder() {
    sortAscending.value = !sortAscending.value;
    currentPage.value = 1;
    products.clear();
    loadData(reset: true);
  }

  void setSortBy(String value) {
    sortBy.value = value;
    currentPage.value = 1;
    products.clear();
    loadData(reset: true);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = null;
    selectedStockStatus.value = null;
    sortBy.value = 'name';
    sortAscending.value = true;
    currentPage.value = 1;
    products.clear();
    loadData(reset: true);
  }

  void navigateToAddProduct() {
    Get.toNamed(AppRoutes.AddProduct);
  }

  void navigateToProductDetails(String productId) {
    Get.toNamed(
      AppRoutes.productDetail.replaceFirst(':productId', productId),
    );
  }

  int get totalProducts => products.length;
  int get filteredCount => filteredProducts.length;
  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;
}