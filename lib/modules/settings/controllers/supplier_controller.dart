// lib/modules/admin/settings/controllers/suppliers_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/supplier_repository.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';

class SuppliersController extends GetxController {
  final SupplierRepository _repository = Get.find<SupplierRepository>();
  
  final suppliers = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final isRefreshing = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      suppliers.clear();
    }

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      error.value = '';

      final fetchedSuppliers = await _repository.getSuppliers(
        page: currentPage.value,
        limit: 20,
      );

      if (currentPage.value == 1) {
        suppliers.value = fetchedSuppliers;
      } else {
        suppliers.addAll(fetchedSuppliers);
      }

      hasMoreData.value = fetchedSuppliers.length == 20;
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading suppliers: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshSuppliers() async {
    try {
      isRefreshing.value = true;
      await loadSuppliers(refresh: true);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await loadSuppliers();
  }

  void showAddSupplierDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final gstController = TextEditingController();
    final paymentTerms = 'immediate'.obs;

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
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paymentTerms.value,
                decoration: const InputDecoration(
                  labelText: 'Payment Terms',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'immediate', child: Text('Immediate')),
                  DropdownMenuItem(value: '7_days', child: Text('7 Days')),
                  DropdownMenuItem(value: '15_days', child: Text('15 Days')),
                  DropdownMenuItem(value: '30_days', child: Text('30 Days')),
                ],
                onChanged: (value) {
                  if (value != null) paymentTerms.value = value;
                },
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                Get.back();
                await _addSupplier(
                  name: nameController.text,
                  contact: contactController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  address: addressController.text,
                  gst: gstController.text,
                  paymentTerms: paymentTerms.value,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSupplier({
    required String name,
    String contact = '',
    String phone = '',
    String email = '',
    String address = '',
    String gst = '',
    String paymentTerms = 'immediate',
  }) async {
    try {
      isLoading.value = true;

      final supplierData = {
        'name': name,
        'contactPerson': contact,
        'phone': phone,
        'email': email,
        'address': address,
        'gstNumber': gst,
        'paymentTerms': paymentTerms,
      };

      final newSupplier = await _repository.createSupplier(supplierData);
      
      suppliers.insert(0, newSupplier);

      Get.snackbar(
        'Success',
        'Supplier added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add supplier: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSupplierStatus(String id) async {
    try {
      final index = suppliers.indexWhere((s) => s['id'] == id);
      if (index != -1) {
        final currentStatus = suppliers[index]['status'];
        final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
        
        // Call API to update status
        await _repository.updateSupplier(id, {'status': newStatus});
        
        suppliers[index]['status'] = newStatus;
        suppliers.refresh();

        Get.snackbar(
          'Success',
          'Supplier status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
            onPressed: () async {
              Get.back();
              try {
                isLoading.value = true;
                final success = await _repository.deleteSupplier(id);
                
                if (success) {
                  suppliers.removeWhere((s) => s['id'] == id);
                  
                  Get.snackbar(
                    'Success',
                    'Supplier deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete supplier: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isLoading.value = false;
              }
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