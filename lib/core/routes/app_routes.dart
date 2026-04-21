// lib/core/routes/app_routes.dart

part of 'app_pages.dart';

abstract class AppRoutes {
  static const String initial = '/';
  static const String productDetail = '/productdetail/:productId';
  static const String AddProduct = "/addproduct";
  static const String admindashbaord = "/admindashboard";
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String adminproducts = '/adminproducts';
  
  // 👇 Stock Routes Add Karo
  static const String stockIn = '/stockin';
  static const String stockOut = '/stockout';
  static const String stockHistory = '/stockhistory';
    static const String reportsDashboard = '/reports';
  static const String stockSummaryReport = '/reports/stock-summary';
  static const String lowStockReport = '/reports/low-stock';
  static const String expiryReport = '/reports/expiry';
  
static const String settings = '/settings';
static const String companyProfile = '/settings/company';
static const String categories = '/settings/categories';
static const String users = '/settings/users';
static const String suppliers = '/settings/suppliers';
static const String notificationSettings = '/settings/notifications';
static const String backupRestore = '/settings/backup';
static const String orders = '/orders';
static const String createOrder = '/orders/create';
static const String orderDetails = '/orders/:orderId';
static const String alerts = '/alerts';
static const String staff = '/staff';
static const String alertDetails = '/alerts/:id';
static const String inventoryValuation = '/inventory/valuation';
// lib/core/routes/app_routes.dart

static const String todayStockHistory = '/today-stock-history';

}