import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/onboarding_repository.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';
import 'package:warehouse_management_app/modules/onboarding/controllers/onboarding_controllers.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
  Get.lazyPut<ApiService>(
      () => ApiService(),
      fenix: true, // Isse service memory mein rehti hai
    );    Get.lazyPut<OnboardingRepository>(() => OnboardingRepository());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}