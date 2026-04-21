import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_management_app/config/app_config.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/utils/validators.dart';
class AuthController extends GetxController {
  // ================= FORM KEYS =================
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // ================= TEXT CONTROLLERS =================
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ================= OBSERVABLES =================
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final acceptTerms = false.obs;
  final selectedCountry = ''.obs;
  final rememberMe = false.obs;

  final isLoggedIn = false.obs;
  final userEmail = ''.obs;
  final userName = ''.obs;
  final userToken = ''.obs;

  // ================= SERVICES =================
  late final ApiService _apiService;
  SharedPreferences? _prefs;

  // ================= COUNTRIES =================
  final List<String> countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'India',
    'Pakistan',
    'China',
    'Japan',
    'Australia',
    'Brazil',
    'South Africa',
  ];

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    // await _checkPreviousLogin();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  // ================= TOGGLES =================
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();
  void toggleTerms(bool? value) => acceptTerms.value = value ?? false;
  void setSelectedCountry(String country) => selectedCountry.value = country;

  // ================= NAVIGATION =================
  void navigateToSignUp() => Get.toNamed(AppRoutes.signup);
  void navigateToSignIn() => Get.toNamed(AppRoutes.login);
  void navigateToForgotPassword() =>
      Get.toNamed(AppRoutes.admindashbaord);


Future<void> signIn() async {
  if (!loginFormKey.currentState!.validate()) return;

  try {
    isLoading.value = true;

    final url = Uri.parse("${AppConfig.baseurl}/auth/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": emailController.text.trim().toLowerCase(),
        "password": passwordController.text,
      }),
    ).timeout(const Duration(seconds: 15));

    final Map<String, dynamic> responseBody =
        jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseBody['success'] == true) {

      final data = responseBody['data'];
      final user = data['user'];
      final String? token = data['token'];

      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Login Failed',
          'Token not received from server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final email = user['email'] ?? emailController.text;
      final name = user['name'] ?? '';

      userEmail.value = email;
      userName.value = name;
      userToken.value = token;
      isLoggedIn.value = true;

      if (_prefs != null) {
        await _prefs!.setString('auth_token', token);
        await _prefs!.setString('user_email', email);
        await _prefs!.setString('user_name', name);
      }

      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.admindashbaord);

    } else {
      Get.snackbar(
        'Login Failed',
        responseBody['message'] ?? 'Invalid credentials',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
  } finally {
    isLoading.value = false;
  }
}
  // ================= SIGNUP =================
  Future<void> signUp() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (selectedCountry.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select your country',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar(
        'Error',
        'Please accept terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        'auth/signup',
        data: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim().toLowerCase(),
          'country': selectedCountry.value,
          'password': passwordController.text,
        },
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Signup failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      isLoading.value = true;

      if (_prefs != null) {
        await _prefs!.clear();
      }

      isLoggedIn.value = false;
      userEmail.value = '';
      userName.value = '';
      userToken.value = '';

      emailController.clear();
      passwordController.clear();

      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      final response = await _apiService.post(
        'auth/forgot-password',
        data: {'email': email},
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Reset link sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to send reset link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ================= VALIDATORS =================
  String? validateName(String? value) => AppValidators.validateName(value);
  String? validateEmail(String? value) => AppValidators.validateEmail(value);
  String? validatePhone(String? value) => AppValidators.validatePhone(value);
  String? validatePassword(String? value) =>
      AppValidators.validatePassword(value);

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}