// lib/modules/onboarding/controllers/onboarding_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/data/models/onboarding_models.dart';
import 'package:warehouse_management_app/data/reposotories/onboarding_repository.dart';

class OnboardingController extends GetxController {
  final OnboardingRepository _repository = Get.find<OnboardingRepository>();
  
  // Observables
  final currentPage = 0.obs;
  final pageController = PageController();
  
  // Data
  late List<OnboardingItem> onboardingItems;

  @override
  void onInit() {
    super.onInit();
    checkAuth(); // 👈 Check token first
    onboardingItems = _repository.getOnboardingData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Methods
  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < onboardingItems.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 🔥 FIXED: Check authentication
  Future<void> checkAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token != null && token.isNotEmpty) {
      // Token hai to seedha dashboard par jao
      navigateToDashboard();
    }
    // Token nahi to onboarding dikhega
  }

  void skipOnboarding() {
    Get.offAllNamed(AppRoutes.login);
  }

  void navigateToSignUp() {
    Get.toNamed(AppRoutes.signup);
  }

  // 🔥 FIXED: Navigate to dashboard with proper route
  void navigateToDashboard() {
    // Clear all previous routes and go to dashboard
    Get.offAllNamed(AppRoutes.admindashbaord);
  }

  void navigateToSignIn() {
    Get.toNamed(AppRoutes.login);
  }

  bool isLastPage() {
    return currentPage.value == onboardingItems.length - 1;
  }

  Color getDotColor(int index) {
    return index == currentPage.value 
        ? Colors.grey.shade800 
        : Colors.grey.shade300; 
  }

  double getDotWidth(int index) {
    return index == currentPage.value ? 10.0 : 6.0;
  }

  double getDotHeight(int index) {
    return index == currentPage.value ? 10.0 : 6.0;
  }
}