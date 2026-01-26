import 'package:get/get.dart';
import '../services/auth_api_service.dart';

class OtpController extends GetxController implements GetxService {
  bool isLoading = false;
  String? errorMessage;
  String otp = '';
  bool isOtpVerified = false;

  // Timer
  int resendTimer = 59;
  bool canResend = false;

  // Always mobile OTP
  String mobile = '';

  /// START RESEND TIMER
  void startTimer() {
    resendTimer = 59;
    canResend = false;
    update();

    Future.delayed(const Duration(seconds: 1), () {
      if (resendTimer > 0) {
        resendTimer--;
        update();
        startTimer();
      } else {
        canResend = true;
        update();
      }
    });
  }

  /// VERIFY OTP (MOBILE ONLY)
  Future<bool> verifyOtp() async {
    if (otp.length != 6) {
      errorMessage = 'Please enter valid 6-digit OTP';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    final result = await AuthApiService.loginOtpVerify(
      mobile: mobile,
      otp: otp,
    );

    isLoading = false;

    if (result['success'] == true && result['token'] != null) {
      isOtpVerified = true;
      update();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Invalid OTP';
      update();
      return false;
    }
  }

  /// RESEND OTP
  Future<bool> resendOtp() async {
    if (!canResend) return false;

    isLoading = true;
    errorMessage = null;
    update();

    final result = await AuthApiService.loginOtpInit(
      mobile: mobile,
    );

    isLoading = false;

    if (result['success'] == true) {
      startTimer();
      update();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Failed to resend OTP';
      update();
      return false;
    }
  }

  /// SET MOBILE FROM PREVIOUS SCREEN
  void setMobile(String value) {
    mobile = value;
  }

  /// CLEAR DATA
  void clearData() {
    otp = '';
    isOtpVerified = false;
    errorMessage = null;
    resendTimer = 59;
    canResend = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    mobile = Get.arguments?['mobile'] ?? '';
    startTimer();
  }
}
