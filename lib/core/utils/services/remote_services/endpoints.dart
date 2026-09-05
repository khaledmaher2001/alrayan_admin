class EndPoints {
  static const baseUrl = "https://api.elrayan.acwad.tech/api/v1/";

  // Realtime (Socket.IO) — same host as the REST API, without the /api/v1 prefix.
  static const socketBaseUrl = "https://api-miras.acwad.tech";
  static const adminOrdersNamespace = "/admin-orders";
  static const orderCreatedEvent = "order:created";

  // Auth
  static const login = 'auth/login';
  static const register = 'auth/sign-up';
  static const logout = 'auth/logout';
  static const getSettings = 'app-version/check';
  static const updateSettings = 'app-version/update';
  static const toggleAppStatus = 'app-version/toggle-app-status';
  static const toggleMaintenance = 'app-version/toggle-maintenance';
  static const sendOTP = "auth/resend-otp";
  static const verifyOTP = "auth/verify-otp";
  static const signUp = "auth/sign-up";
  static const resetPassword = 'auth/update-password';
  static const forgetPassword = 'auth/forget-password';
  static const profile = "auth/get-me";
  static const changePassword = "auth/update-password";

  static const categories = 'category';
  static const subCategories = 'sub-categories';
  static const products = 'product';
  static String toggleProductHidden(int id) => 'product/toggle-hidden/$id';

  static const userNotification = "notifications/me";
  static String readNotification(id) => "notifications/$id/read";

  static const orders = "orders";
  static const homeStatistics = "orders/dashboard";
  static const inventoryAnalytics = "orders/inventory-analytics";
  static const lowStockProducts = "orders/low-stock-products";
  static const lowStockConfig = "orders/low-stock-config";
  static const salesReport = "orders/sales-report";

  static const zones = "zones";
  static const users = "user";
  static String userById(int id) => 'user/$id';
  static String customerLifetimeValue(int id) =>
      'orders/customer-lifetime-value/$id';

  static const coupons = "coupons";
  static const luckyWheel = "rewards";
  static const toggleSpinWheel = "rewards/toggle-spin-wheel";
  static const getOfferBanner = 'banners';

  static const reviews = 'reviews';
  static const reviewsSummery = 'reviews/stats';

  static const topUsers = 'orders/top-customer';
  static const topProducts = 'orders/top-products';

  static const reports = 'reports';
  static String reportRequestUpdate(int id) => 'reports/$id/request-update';

  static const loyaltyConfig = 'loyalty/config';

  // Delivery Management
  static const deliveryAccounts = 'delivery/accounts';
  static String deliveryAccountProfile(int userId) =>
      'delivery/accounts/$userId/profile';
  static String deliveryAccountWallet(int userId) =>
      'delivery/accounts/$userId/wallet';
  static String deliveryAccountTransactions(int userId) =>
      'delivery/accounts/$userId/transactions';
  static const deliveryStatistics = 'delivery/statistics';
  static const deliveryReleaseLogs = 'delivery/release-logs';
  static const deliveryRemittances = 'delivery/wallet/remittances';
  static String deliveryRemittanceApprove(int id) =>
      'delivery/wallet/remittances/$id/approve';
  static String deliveryRemittanceReject(int id) =>
      'delivery/wallet/remittances/$id/reject';

  static const appSettings = 'app-settings';
}
