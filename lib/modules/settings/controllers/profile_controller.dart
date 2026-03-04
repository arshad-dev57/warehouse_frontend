// lib/modules/admin/settings/controllers/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  // Form Controllers
  final storeNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final taxIdController = TextEditingController();
  
  // Observable
  final logo = Rxn<File>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  @override
  void onClose() {
    storeNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    taxIdController.dispose();
    super.onClose();
  }

  void loadProfileData() {
    // Mock data - replace with API call
    storeNameController.text = 'Warehouse Store';
    emailController.text = 'store@warehouse.com';
    phoneController.text = '+92 300 1234567';
    addressController.text = '123 Main Street, City';
    taxIdController.text = 'GST123456';
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        logo.value = File(pickedFile.path);
        
        Get.snackbar(
          'Success',
          'Logo updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      // Validate
      if (storeNameController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Store name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
        Get.snackbar(
          'Error',
          'Valid email is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Save logic here
      final profileData = {
        'storeName': storeNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'taxId': taxIdController.text,
        'logo': logo.value?.path,
      };

      print('Profile saved: $profileData');

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }
}