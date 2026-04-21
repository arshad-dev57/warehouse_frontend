// lib/modules/admin/staff/bindings/staff_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/staff_repository.dart';
import '../controllers/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffRepository>(
      () => StaffRepository(),
      fenix: true,
    );
    
    Get.lazyPut<StaffController>(
      () => StaffController(
        staffRepository: Get.find<StaffRepository>(),
      ),
      fenix: true,
    );
  }
}