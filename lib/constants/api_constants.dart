class ApiConstants {
  static const baseUrl = "https://nirv-ico.onrender.com";
  // Default bearer token used when no in-app session token is available.
  static const String defaultBearerToken = "<JWT>";

  // Authentication endpoints (matching your Postman collection)
  static const String signupMobileInit = '$baseUrl/api/auth/signup/mobile-init';
  static const String signupEmailInit = '$baseUrl/api/auth/signup/email-init';
  static const String signupCombinedInit =
      '$baseUrl/api/auth/signup/combined-init';
  static const String signupVerify = '$baseUrl/api/auth/signup/verify';
  static const String setupPin = '$baseUrl/api/auth/pin/setup';
  static const String loginMobileInit = '$baseUrl/api/auth/login/mobile-init';
  static const String loginMobileVerify = '$baseUrl/api/auth/login/mobile-verify';
  static const String loginOtpInit = loginMobileInit;
  static const String loginOtpVerify = loginMobileVerify;
  static const String loginPin = '$baseUrl/api/auth/login/pin';

  // Password reset endpoints
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String verifyResetPasswordOtp =
      '$baseUrl/api/auth/verify-reset-password-otp';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';

  // PIN reset endpoints
  static const String forgotPin = '$baseUrl/api/auth/forgot-pin';
  static const String verifyResetPinOtp = '$baseUrl/api/auth/verify-reset-pin-otp';
  static const String resetPin = '$baseUrl/api/auth/reset-pin';

  // KYC endpoints
  static const String kycUpload = '$baseUrl/api/kyc/upload';
  static const String kycSubmit = '$baseUrl/api/kyc/submit';
  static const String kycStatus = '$baseUrl/api/kyc/status';

  // User endpoints
  static const String onboardingStatus = '$baseUrl/api/user/onboarding-status';
  static const String profile = '$baseUrl/api/user/profile';
  static const String profileName = '$baseUrl/api/user/profile/name';
  static const String profileImage = '$baseUrl/api/user/profile/image';
  static const String profileEmail = '$baseUrl/api/user/profile/email';
  static const String userOtpInit = '$baseUrl/api/user/otp/init';
  static const String userBank = '$baseUrl/api/user/bank';
  static const String userBankRequests = '$baseUrl/api/user/bank/requests';
  static const String userOtpVerify = '$baseUrl/api/user/otp/verify';
  static const String userPinChange = '$baseUrl/api/user/pin/change';
  static const String referralDownline = '$baseUrl/api/user/referral/downline';
  static const String referralCode = '$baseUrl/api/user/referral/code';
  static const String walletSummary = '$baseUrl/api/wallet/summary';
  static const String walletTopup = '$baseUrl/api/wallet/topup';
  static const String phonePePay = '$baseUrl/api/payments/phonepe/create';
  static const String phonePeStatus =
      '$baseUrl/api/payments/phonepe/status';
  static const String razorpayOrder = '$baseUrl/api/payments/razorpay/order';
  static const String razorpayVerify = '$baseUrl/api/payments/razorpay/verify';
  static const String walletTransactions = '$baseUrl/api/wallet/transactions';
  static const String icoTransactions = '$baseUrl/api/ico/transactions';
  static const String icoSummary = '$baseUrl/api/ico/summary';
  static const String walletAnalytics = '$baseUrl/api/wallet/analytics';
  static const String icoBuy = '$baseUrl/api/ico/buy';

  // ICO
  static const String icoStages = '$baseUrl/api/ico/stages';
}
