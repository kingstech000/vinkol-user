class ApiRoute {
  /// Base Url
  static const String baseUrl = "https://vinkol-server.onrender.com/api/v1";
  // static const String baseUrl =
  //     "https://vinkol-server-staging.vercel.app/api/v1";
//   "";
  // "https://vinkol-web.vercel.app/api/v1";


  // Auth Url
  static const String login = "$baseUrl/users/login";
  static const String forgotPassword = "$baseUrl/users/forgot-password";
  static const String resetPassword =
      "$baseUrl/users/reset-password"; // Base for PATCH reset password with token

  // Signup & Verification
  static const String signUp =
      "$baseUrl/users/register"; // Or a general user signup endpoint
  static const String verifyEmail =
      "$baseUrl/users/verify-email"; // For email OTP verification
  static const String resendOtp =
      "$baseUrl/users/resend-otp"; // To resend OTP for verification
  static const String forgetPassword = '$baseUrl/users/forgot-password';
  static const String requestPasswordReset = '$baseUrl/users/reset-password';
  // User & Profile Management
  static const String userProfile =
      "$baseUrl/users/profile"; // GET user's own profile
  static const String updateProfile = "$baseUrl/users/update-profile";

  // Orders/Bookings Routes
  static const String createOrder = "$baseUrl/orders/create";
  static const String getSingleOrder = "$baseUrl/orders";
  static const String getQuote = "$baseUrl/orders/get-quote";

  static const String createOrderNew = "$baseUrl/orders/create-new";

  // STORE
  static const String stores = '$baseUrl/stores';
  static const String storeTags = '$baseUrl/stores/tags';
  static const String products = '$baseUrl/products';
  static const String shoppingDeliveryFee =
      '$baseUrl/orders/shopping-delivery-fee';
  static const String storeOrders = '$baseUrl/orders/store-order';
  static const String storeOrderNew = '$baseUrl/orders/store-order-new';
  // PAYSTACK
  static const String paystackBaseUrl = 'https://api.paystack.co';
  static const String paystackGenerateLink =
      '$paystackBaseUrl/transaction/initialize';
  static const String paystackVerifyPayment =
      '$paystackBaseUrl/transaction/verify';

  // DELIVERY
  static const String delivery = '$baseUrl/orders/user-orders';
  static const String singleDelivery = '$baseUrl/orders';
  static const String updateToken = '$baseUrl/users/fcm-token';
  static const String reauthenticateToken = '$baseUrl/users/refresh-token';

  // WALLET
  static const String wallet = '$baseUrl/users/payments';

  // RATINGS
  static const String riderAverageRating = '$baseUrl/ratings/rider-average';
  static const String submitRiderRating = '$baseUrl/ratings/rider';

  // APP DETAILS
  static const String appDetails = '$baseUrl/others/app-details';
}
