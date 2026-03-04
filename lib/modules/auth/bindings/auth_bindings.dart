// lib/app/modules/auth/bindings/auth_binding.dart
import 'package:get/get.dart';

import 'package:warehouse_management_app/data/services/api_service.dart';
import 'package:warehouse_management_app/modules/auth/controllers/auth_controlletrs.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Pehle ApiService ko initialize karo
    Get.lazyPut<ApiService>(
      () => ApiService(),
      fenix: true, // Isse service memory mein rehti hai
    );
    
    // Phir AuthController jo ApiService par depend karta hai
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}