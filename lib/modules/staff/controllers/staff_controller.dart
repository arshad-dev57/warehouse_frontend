// lib/modules/admin/staff/controllers/staff_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/models/staff_model.dart';
import 'package:warehouse_management_app/data/reposotories/staff_repository.dart';

class StaffController extends GetxController {
  final StaffRepository _staffRepository;

  StaffController({required StaffRepository staffRepository})
      : _staffRepository = staffRepository;

  // State
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final isSubmitting = false.obs;
  final error = ''.obs;

  // Data
  final staffList = <StaffModel>[].obs;
  final filteredStaff = <StaffModel>[].obs;

  // Filters
  final selectedRole = 'all'.obs;
  final selectedStatus = 'all'.obs;
  final searchQuery = ''.obs;

  // Counts
  final totalCount = 0.obs;
  final adminCount = 0.obs;
  final managerCount = 0.obs;
  final staffCount = 0.obs;
  final activeCount = 0.obs;
  final inactiveCount = 0.obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;

  // Role options
  final roleOptions = [
    {'value': 'all', 'label': 'All Roles'},
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'manager', 'label': 'Manager'},
    {'value': 'staff', 'label': 'Staff'},
  ];

  // Status options
  final statusOptions = [
    {'value': 'all', 'label': 'All Status'},
    {'value': 'active', 'label': 'Active'},
    {'value': 'inactive', 'label': 'Inactive'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadStaff();
    
    debounce(
      searchQuery,
      (_) {
        currentPage.value = 1;
        staffList.clear();
        loadStaff();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> loadStaff({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      staffList.clear();
    }

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      }
      
      error.value = '';

      final result = await _staffRepository.getStaff(
        role: selectedRole.value,
        status: selectedStatus.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        page: currentPage.value,
        limit: 20,
      );

      final List<dynamic> staffJson = result['data'] ?? [];
      final newStaff = staffJson.map((json) => StaffModel.fromJson(json)).toList();

      if (currentPage.value == 1) {
        staffList.value = newStaff;
      } else {
        staffList.addAll(newStaff);
      }

      // Update counts
      final counts = result['counts'] ?? {};
      totalCount.value = counts['total'] ?? 0;
      adminCount.value = counts['admin'] ?? 0;
      managerCount.value = counts['manager'] ?? 0;
      staffCount.value = counts['staff'] ?? 0;
      activeCount.value = counts['active'] ?? 0;
      inactiveCount.value = counts['inactive'] ?? 0;

      final pagination = result['pagination'] ?? {};
      hasMoreData.value = currentPage.value < (pagination['pages'] ?? 1);
      
      filterStaff();
      
    } catch (e) {
      error.value = e.toString();
      print('Error loading staff: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshStaff() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 1;
      await loadStaff(refresh: true);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value) return;
    currentPage.value++;
    await loadStaff();
  }

  void filterStaff() {
    filteredStaff.value = staffList;
  }

  void setRoleFilter(String role) {
    selectedRole.value = role;
    currentPage.value = 1;
    staffList.clear();
    loadStaff();
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    staffList.clear();
    loadStaff();
  }

  void showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final selectedRole = 'staff'.obs;
    final countryController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Staff Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole.value,
                decoration: const InputDecoration(
                  labelText: 'Role *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) selectedRole.value = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
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
              if (nameController.text.isNotEmpty && 
                  emailController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty) {
                Get.back();
                await _createStaff(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  password: passwordController.text,
                  role: selectedRole.value,
                  country: countryController.text,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createStaff({
    required String name,
    required String email,
    String phone = '',
    required String password,
    required String role,
    String country = '',
  }) async {
    try {
      isSubmitting.value = true;

      final staffData = {
        'name': name,
        'email': email,
        'phone': phone.isNotEmpty ? phone : null,
        'password': password,
        'role': role,
        'country': country.isNotEmpty ? country : null,
      };

      final result = await _staffRepository.createStaff(staffData);
      
      // Refresh list
      currentPage.value = 1;
      await loadStaff(refresh: true);

      Get.snackbar(
        'Success',
        'Staff member added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleStaffStatus(StaffModel staff) async {
    try {
      final result = await _staffRepository.toggleStaffStatus(staff.id);
      
      // Update local list
      final index = staffList.indexWhere((s) => s.id == staff.id);
      if (index != -1) {
        staffList[index] = StaffModel(
          id: staff.id,
          name: staff.name,
          email: staff.email,
          phone: staff.phone,
          role: staff.role,
          isActive: !staff.isActive,
          country: staff.country,
          createdAt: staff.createdAt,
          createdBy: staff.createdBy,
        );
        staffList.refresh();
      }

      Get.snackbar(
        'Success',
        result['message'] ?? 'Status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteStaff(StaffModel staff) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final success = await _staffRepository.deleteStaff(staff.id);
                if (success) {
                  staffList.removeWhere((s) => s.id == staff.id);
                  Get.snackbar(
                    'Success',
                    'Staff member deleted',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}