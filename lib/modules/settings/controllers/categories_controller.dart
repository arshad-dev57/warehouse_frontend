// lib/modules/admin/settings/controllers/categories_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    // Mock data
    categories.value = [
      {'id': '1', 'name': 'Electronics', 'count': 45},
      {'id': '2', 'name': 'Medicines', 'count': 128},
      {'id': '3', 'name': 'Hardware', 'count': 67},
      {'id': '4', 'name': 'Garments', 'count': 34},
      {'id': '5', 'name': 'Food Items', 'count': 23},
    ];
  }

  void showAddCategoryDialog() {
    final nameController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                addCategory(nameController.text);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showEditCategoryDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name']);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                updateCategory(category['id'], nameController.text);
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void addCategory(String name) {
    categories.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'count': 0,
    });
    
    Get.snackbar(
      'Success',
      'Category added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void updateCategory(String id, String name) {
    final index = categories.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      categories[index]['name'] = name;
      categories.refresh();
      
      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void deleteCategory(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              categories.removeWhere((c) => c['id'] == id);
              Get.back();
              
              Get.snackbar(
                'Success',
                'Category deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}