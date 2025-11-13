class EndPoints {
  // static const baseUrl = "https://ef51e314ba1b.ngrok-free.app/api/v1/";
  static const baseUrl = "http://109.106.244.200:3800/api/v1/";

  // Auth
  static const login = 'auth/login';
  static const register = 'auth/sign-up';
  static const logout = 'auth/logout';
  static const getSettings = 'app-version/check';
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

  static const userNotification = "notifications/me";
  static String readNotification(id) => "notifications/$id/read";

  static const orders = "orders";
  static const homeStatistics = "orders/dashboard";

  static const zones = "zones";
  static const users = "user";




}

