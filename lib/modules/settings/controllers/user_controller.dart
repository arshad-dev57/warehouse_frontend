// lib/modules/admin/settings/controllers/users_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  final users = <Map<String, dynamic>>[].obs;
  final roles = ['Admin', 'Manager', 'Inventory Staff', 'Picker', 'Viewer'].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  void loadUsers() {
    // Mock data
    users.value = [
      {
        'id': '1',
        'name': 'Ali Raza',
        'email': 'ali@warehouse.com',
        'role': 'Admin',
        'status': 'active',
        'avatar': 'A',
        'color': Colors.blue,
      },
      {
        'id': '2',
        'name': 'Sara Khan',
        'email': 'sara@warehouse.com',
        'role': 'Manager',
        'status': 'active',
        'avatar': 'S',
        'color': Colors.green,
      },
      {
        'id': '3',
        'name': 'Ahmed Malik',
        'email': 'ahmed@warehouse.com',
        'role': 'Inventory Staff',
        'status': 'active',
        'avatar': 'A',
        'color': Colors.orange,
      },
      {
        'id': '4',
        'name': 'Fatima Ali',
        'email': 'fatima@warehouse.com',
        'role': 'Picker',
        'status': 'inactive',
        'avatar': 'F',
        'color': Colors.purple,
      },
    ];
  }

  void showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final selectedRole = 'Staff'.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
              value: selectedRole.value,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedRole.value = value;
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                addUser(
                  nameController.text,
                  emailController.text,
                  selectedRole.value,
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

  void addUser(String name, String email, String role) {
    users.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'role': role,
      'status': 'active',
      'avatar': name[0].toUpperCase(),
      'color': Colors.primaries[users.length % Colors.primaries.length],
    });

    Get.snackbar(
      'Success',
      'User added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void toggleUserStatus(String id) {
    final index = users.indexWhere((u) => u['id'] == id);
    if (index != -1) {
      users[index]['status'] = users[index]['status'] == 'active' ? 'inactive' : 'active';
      users.refresh();

      Get.snackbar(
        'Success',
        'User status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  void deleteUser(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              users.removeWhere((u) => u['id'] == id);
              Get.back();

              Get.snackbar(
                'Success',
                'User deleted successfully',
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