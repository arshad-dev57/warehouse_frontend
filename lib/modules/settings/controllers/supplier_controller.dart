// lib/modules/admin/settings/controllers/suppliers_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuppliersController extends GetxController {
  final suppliers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  void loadSuppliers() {
    // Mock data
    suppliers.value = [
      {
        'id': '1',
        'name': 'Mobile World',
        'contact': 'Ali Raza',
        'phone': '+92 300 1234567',
        'email': 'info@mobileworld.com',
        'products': 45,
        'status': 'active',
      },
      {
        'id': '2',
        'name': 'Medico Pharma',
        'contact': 'Dr. Khan',
        'phone': '+92 301 7654321',
        'email': 'orders@medico.com',
        'products': 128,
        'status': 'active',
      },
      {
        'id': '3',
        'name': 'Tools World',
        'contact': 'Ahmed Malik',
        'phone': '+92 302 9876543',
        'email': 'sales@toolsworld.com',
        'products': 67,
        'status': 'inactive',
      },
      {
        'id': '4',
        'name': 'Fashion Hub',
        'contact': 'Sara Khan',
        'phone': '+92 303 4567890',
        'email': 'contact@fashionhub.com',
        'products': 34,
        'status': 'active',
      },
    ];
  }

  void showAddSupplierDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
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
                addSupplier(
                  nameController.text,
                  contactController.text,
                  phoneController.text,
                  emailController.text,
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

  void addSupplier(String name, String contact, String phone, String email) {
    suppliers.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'contact': contact,
      'phone': phone,
      'email': email,
      'products': 0,
      'status': 'active',
    });

    Get.snackbar(
      'Success',
      'Supplier added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void toggleSupplierStatus(String id) {
    final index = suppliers.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      suppliers[index]['status'] = suppliers[index]['status'] == 'active' ? 'inactive' : 'active';
      suppliers.refresh();

      Get.snackbar(
        'Success',
        'Supplier status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  void deleteSupplier(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text('Are you sure you want to delete this supplier?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              suppliers.removeWhere((s) => s['id'] == id);
              Get.back();

              Get.snackbar(
                'Success',
                'Supplier deleted successfully',
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