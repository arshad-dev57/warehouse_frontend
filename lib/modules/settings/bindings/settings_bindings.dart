// lib/modules/admin/settings/bindings/settings_binding.dart

import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/supplier_repository.dart';
import 'package:warehouse_management_app/modules/settings/controllers/notification_controller.dart';
import 'package:warehouse_management_app/modules/settings/controllers/settings_controllers.dart';
import 'package:warehouse_management_app/modules/settings/controllers/supplier_controller.dart';
import 'package:warehouse_management_app/modules/settings/controllers/user_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/categories_controller.dart';

import '../controllers/backup_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Main Settings Controller
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
      fenix: true,
    );

  Get.lazyPut<SupplierRepository>(
      () => SupplierRepository(),
      fenix: true,
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );
    
    // Categories Controller
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(),
      fenix: true,
    );
    
    // Users Controller
    Get.lazyPut<UsersController>(
      () => UsersController(),
      fenix: true,
    );
    
    // Suppliers Controller
    Get.lazyPut<SuppliersController>(
      () => SuppliersController(),
      fenix: true,
    );
    
    // Notification Settings Controller
    Get.lazyPut<NotificationSettingsController>(
      () => NotificationSettingsController(),
      fenix: true,
    );
    
    // Backup Controller
    Get.lazyPut<BackupController>(
      () => BackupController(),
      fenix: true,
    );
  }
}