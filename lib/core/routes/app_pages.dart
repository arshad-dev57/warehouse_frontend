import 'package:get/get.dart';
import 'package:warehouse_management_app/data/reposotories/product_repository.dart';

import 'package:warehouse_management_app/modules/admin/bindings/admin_dashboard_bindings.dart';
import 'package:warehouse_management_app/modules/admin/bindings/admin_products_binding.dart';
import 'package:warehouse_management_app/modules/admin/bindings/stock_bindings.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_add_product_controller.dart';
import 'package:warehouse_management_app/modules/admin/controller/admin_product_details_controller.dart';

import 'package:warehouse_management_app/modules/admin/views/admin_add_product_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_dashboard_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_product_detail_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_product_list_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_stock_history_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_stock_in_view.dart';
import 'package:warehouse_management_app/modules/admin/views/admin_stock_out_view.dart';
import 'package:warehouse_management_app/modules/adminreports/bindings/reports_bindings.dart';
import 'package:warehouse_management_app/modules/adminreports/views/expiry_report_view.dart';
import 'package:warehouse_management_app/modules/adminreports/views/low_stock_reports.dart';
import 'package:warehouse_management_app/modules/adminreports/views/reports_dashboard_view.dart';
import 'package:warehouse_management_app/modules/adminreports/views/stock_summary_report.dart';
import 'package:warehouse_management_app/modules/alerts/bindings/alert_bindings.dart';
import 'package:warehouse_management_app/modules/alerts/views/alert_views.dart';

import 'package:warehouse_management_app/modules/auth/bindings/auth_bindings.dart';
import 'package:warehouse_management_app/modules/auth/views/login_view.dart';
import 'package:warehouse_management_app/modules/auth/views/signup_view.dart';

import 'package:warehouse_management_app/modules/home/views/home_view.dart';

import 'package:warehouse_management_app/modules/onboarding/bindings/onboarding_bindings.dart';
import 'package:warehouse_management_app/modules/onboarding/views/onboarding_view.dart';
import 'package:warehouse_management_app/modules/orders/bindings/order_bindings.dart';
import 'package:warehouse_management_app/modules/orders/views/create_order_view.dart';
import 'package:warehouse_management_app/modules/orders/views/order_detail_view.dart';
import 'package:warehouse_management_app/modules/orders/views/orders_view.dart';
import 'package:warehouse_management_app/modules/settings/bindings/settings_bindings.dart';
import 'package:warehouse_management_app/modules/settings/views/backup_&_restore_view.dart';
import 'package:warehouse_management_app/modules/settings/views/category_views.dart';
import 'package:warehouse_management_app/modules/settings/views/company_profile_view.dart';
import 'package:warehouse_management_app/modules/settings/views/notification_settings_view.dart';
import 'package:warehouse_management_app/modules/settings/views/settings_view.dart';
import 'package:warehouse_management_app/modules/settings/views/supplier_view.dart';
import 'package:warehouse_management_app/modules/settings/views/users_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.onboarding;

  static final routes = [

    // ================= ONBOARDING =================
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.signup,
      page: () => SignupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // ================= HOME =================
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // ================= ADMIN DASHBOARD =================
    GetPage(
      name: AppRoutes.admindashbaord,
      page: () => AdminDashboardView(),
      binding: AdminDashboardBinding(),
      transition: Transition.rightToLeft,
    ),

    // ================= PRODUCT LIST =================
    GetPage(
      name: AppRoutes.adminproducts,
      page: () => ProductListView(),
      binding: ProductsBinding(), // List + Repo binding
      transition: Transition.rightToLeft,
    ),

    // ================= ADD PRODUCT =================
    GetPage(
      name: AppRoutes.AddProduct,
      page: () => AddProductView(),
      binding: BindingsBuilder(() {
        // Ensure repository exists
        if (!Get.isRegistered<ProductRepository>()) {
          Get.lazyPut<ProductRepository>(
            () => ProductRepository(),
            fenix: true,
          );
        }

        // Only AddProductController bind here
        Get.lazyPut<AddProductController>(
          () => AddProductController(
            repository: Get.find<ProductRepository>(),
          ),
        );
      }),
      transition: Transition.rightToLeft,
    ),
   GetPage(
      name: AppRoutes.productDetail,
      page: () => ProductDetailsView(),
      binding: BindingsBuilder(() {
        // Ensure repository exists
        if (!Get.isRegistered<ProductRepository>()) {
          Get.lazyPut<ProductRepository>(
            () => ProductRepository(),
            fenix: true,
          );
        }

        // Only AddProductController bind here
        Get.lazyPut<ProductDetailsController>(
          () => ProductDetailsController(
            repository: Get.find<ProductRepository>(),
          ),
        );
      }),
      transition: Transition.rightToLeft,
    ),
GetPage(
  name: AppRoutes.stockIn,
  page: () => const StockInView(),
  binding: StockBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.stockOut,
  page: () => const StockOutView(),
  binding: StockBinding(),
),


GetPage(
  name: AppRoutes.stockHistory,
  page: () => const StockHistoryView(),
  binding: StockBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.reportsDashboard,
  page: () => const ReportsDashboardView(),
  binding: ReportsBinding(),
  transition: Transition.rightToLeft,
),


GetPage(
  name: AppRoutes.stockSummaryReport,
  page: () => const StockSummaryReportView(),
  binding: ReportsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.lowStockReport,
  page: () => const LowStockReportView(),
  binding: ReportsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.expiryReport,
  page: () => const ExpiryReportView(),
  binding: ReportsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.settings,
  page: () => const SettingsView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.categories,
  page: () => const CategoriesView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.companyProfile,
  page: () => const CompanyProfileView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),


GetPage(
  name: AppRoutes.users,
  page: () => const UsersView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.suppliers,
  page: () => const SuppliersView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.notificationSettings,
  page: () => const NotificationSettingsView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),


GetPage(
  name: AppRoutes.backupRestore,
  page: () => const BackupRestoreView(),
  binding: SettingsBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: AppRoutes.orders,
  page: () => const OrdersView(),
  binding: OrdersBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.createOrder,
  page: () => const CreateOrderView(),
  binding: OrdersBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.orderDetails,
  page: () => const OrderDetailsView(),
  binding: OrdersBinding(),
  transition: Transition.rightToLeft,
),

GetPage(
  name: AppRoutes.alerts,
  page: () => const AlertsView(),
  binding: AlertsBinding(),
  transition: Transition.rightToLeft,
),
  ];
}