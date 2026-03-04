// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this
import 'package:warehouse_management_app/data/services/api_service.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/utils/validators.dart';

class AuthController extends GetxController {
  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final acceptTerms = false.obs;
  final selectedCountry = ''.obs;
  final rememberMe = false.obs;
  
  // User data observables
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;
  final userName = ''.obs;
  final userToken = ''.obs;

  // Services
  late final ApiService _apiService;
  late final SharedPreferences _prefs; // Change to SharedPreferences

  // Countries List
// lib/app/modules/auth/controllers/auth_controller.dart

final List<String> countries = [
  // North America
  'United States',
  'Canada',
  'Mexico',
  
  // United Kingdom & Ireland
  'United Kingdom',
  'Ireland',
  'Scotland',
  'Wales',
  'Northern Ireland',
  
  // Western Europe
  'France',
  'Germany',
  'Italy',
  'Spain',
  'Portugal',
  'Netherlands',
  'Belgium',
  'Switzerland',
  'Austria',
  'Luxembourg',
  'Monaco',
  'Liechtenstein',
  
  // Northern Europe
  'Sweden',
  'Norway',
  'Denmark',
  'Finland',
  'Iceland',
  'Greenland',
  
  // Central Europe
  'Poland',
  'Czech Republic',
  'Slovakia',
  'Hungary',
  'Slovenia',
  'Croatia',
  
  // Southern Europe
  'Greece',
  'Cyprus',
  'Malta',
  'Albania',
  'Bosnia and Herzegovina',
  'Montenegro',
  'North Macedonia',
  'Serbia',
  'Kosovo',
  
  // Baltic States
  'Estonia',
  'Latvia',
  'Lithuania',
  
  // Eastern Europe
  'Russia',
  'Ukraine',
  'Belarus',
  'Moldova',
  'Romania',
  'Bulgaria',
  
  // Middle East (Western Asia)
  'Turkey',
  'Israel',
  'United Arab Emirates',
  'Saudi Arabia',
  'Qatar',
  'Kuwait',
  'Bahrain',
  'Oman',
  'Jordan',
  'Lebanon',
  'Cyprus',
  
  // South Asia
  'India',
  'Pakistan',
  'Bangladesh',
  'Sri Lanka',
  'Nepal',
  'Afghanistan',
  'Maldives',
  'Bhutan',
  
  // East Asia
  'China',
  'Japan',
  'South Korea',
  'North Korea',
  'Mongolia',
  'Taiwan',
  'Hong Kong',
  'Macau',
  
  // Southeast Asia
  'Singapore',
  'Malaysia',
  'Indonesia',
  'Philippines',
  'Thailand',
  'Vietnam',
  'Myanmar',
  'Cambodia',
  'Laos',
  'Brunei',
  
  // Australia & Oceania
  'Australia',
  'New Zealand',
  'Fiji',
  'Papua New Guinea',
  
  // South America
  'Brazil',
  'Argentina',
  'Chile',
  'Colombia',
  'Peru',
  'Venezuela',
  'Ecuador',
  'Bolivia',
  'Paraguay',
  'Uruguay',
  'Guyana',
  'Suriname',
  'French Guiana',
  
  // Central America & Caribbean
  'Costa Rica',
  'Panama',
  'Nicaragua',
  'Honduras',
  'El Salvador',
  'Guatemala',
  'Belize',
  'Cuba',
  'Jamaica',
  'Haiti',
  'Dominican Republic',
  'Puerto Rico',
  'Bahamas',
  'Trinidad and Tobago',
  
  // Africa
  'South Africa',
  'Nigeria',
  'Kenya',
  'Egypt',
  'Morocco',
  'Algeria',
  'Tunisia',
  'Libya',
  'Sudan',
  'Ethiopia',
  'Tanzania',
  'Uganda',
  'Ghana',
  'Senegal',
  'Angola',
  'Mozambique',
  'Zimbabwe',
  'Zambia',
  'Botswana',
  'Namibia',
  
  // Sorted alphabetically for better UX
];
  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    _initSharedPrefs(); // Initialize SharedPreferences
  }

  // Initialize SharedPreferences
  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _checkPreviousLogin();
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

  // Check if user was previously logged in using SharedPreferences
  Future<void> _checkPreviousLogin() async {
    try {
      final token = _prefs.getString('auth_token');
      final email = _prefs.getString('user_email');
      final name = _prefs.getString('user_name');
      
      if (token != null && email != null) {
        userToken.value = token;
        userEmail.value = email;
        userName.value = name ?? '';
        isLoggedIn.value = true;
        
        // Auto navigate to home if token exists
        Get.offAllNamed(AppRoutes.admindashbaord);
      }
    } catch (e) {
      print('Error checking previous login: $e');
    }
  }

  // Toggle Methods
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();
  void toggleTerms(bool? value) => acceptTerms.value = value ?? false;
  void setSelectedCountry(String country) => selectedCountry.value = country;

  // Navigation
  void navigateToSignUp() => Get.toNamed(AppRoutes.signup);
  void navigateToSignIn() => Get.toNamed(AppRoutes.login);
  void navigateToForgotPassword() => Get.toNamed(AppRoutes.admindashbaord);

  // LOGIN FUNCTION
  Future<void> signIn() async {
    print("login attempt");
    if (!loginFormKey.currentState!.validate()) {
      return;
    }
print("key is correct");
    if (!await _apiService.hasInternet()) {
      Get.snackbar(
        'No Internet',
        'Please check your internet connection and try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.wifi_off, color: Colors.white),
        duration: Duration(seconds: 3),
      );
      return;
    }
print("internet is live");
    try {
      isLoading.value = true;
      
      final loginData = {
        'email': emailController.text.trim().toLowerCase(),
        'password': passwordController.text,
      };
      
      print('Attempting login with email: ${emailController.text}');
      
      final response = await _apiService.post(
        'auth/login',
        data: loginData,
      );
      
      print('Login response: ${response.success} - ${response.message}');
      
      if (response.success) {
        final userData = response.data;
        
        String? token;
        if (userData is Map<String, dynamic>) {
          token = userData['token'] ?? userData['accessToken'] ?? userData['access_token'];
          final email = userData['email'] ?? emailController.text;
          final name = userData['name'] ?? userData['username'] ?? '';
          
          userEmail.value = email;
          userName.value = name;
          userToken.value = token ?? '';
          isLoggedIn.value = true;
          
          // Save to SharedPreferences if remember me is checked
          if (rememberMe.value && token != null) {
            await _prefs.setString('auth_token', token);
            await _prefs.setString('user_email', email);
            await _prefs.setString('user_name', name);
            await _prefs.setBool('is_logged_in', true);
          }
          
          Get.snackbar(
            'Success! 🎉',
            response.message ?? 'Logged in successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: Icon(Icons.check_circle, color: Colors.white),
            duration: Duration(seconds: 2),
          );
          
          Get.offAllNamed(AppRoutes.admindashbaord);
        } else {
          isLoggedIn.value = true;
          Get.offAllNamed(AppRoutes.admindashbaord);
        }
      } else {
        String errorMessage = response.message ?? 'Login failed';
        
        if (response.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (response.statusCode == 403) {
          errorMessage = 'Account is disabled. Please contact support';
        } else if (response.statusCode == 404) {
          errorMessage = 'User not found';
        } else if (response.statusCode == 429) {
          errorMessage = 'Too many attempts. Please try later';
        }
        
        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
          duration: Duration(seconds: 3),
        );
      }
      
    } catch (e) {
      print('Login error: $e');
      
      String errorMessage = 'An error occurred during login';
      
      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please try again';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response from server';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Up Method
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
          'acceptedTerms': acceptTerms.value.toString(),
        },
      );
      
      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'Account created successfully!',
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

  // Updated Logout function with SharedPreferences
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Optional: Call logout API
      // await _apiService.post('auth/logout');
      
      // Clear SharedPreferences
      await _prefs.remove('auth_token');
      await _prefs.remove('user_email');
      await _prefs.remove('user_name');
      await _prefs.remove('is_logged_in');
      
      // Reset observables
      isLoggedIn.value = false;
      userEmail.value = '';
      userName.value = '';
      userToken.value = '';
      
      // Clear text controllers
      emailController.clear();
      passwordController.clear();
      
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      
      Get.offAllNamed(AppRoutes.login);
      
    } catch (e) {
      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password
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
          'Password reset link sent to your email',
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
      
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Check Internet Connection
  Future<bool> checkInternet() async {
    return await _apiService.hasInternet();
  }

  // Validators
  String? validateName(String? value) => AppValidators.validateName(value);
  String? validateEmail(String? value) => AppValidators.validateEmail(value);
  String? validatePhone(String? value) => AppValidators.validatePhone(value);
  String? validatePassword(String? value) => AppValidators.validatePassword(value);
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? validateLoginEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}