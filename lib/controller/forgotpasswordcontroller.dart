import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../constants/api_constants.dart';
import '../services/auth_api_service.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  bool isLoading = false;
  String? errorMessage;

  // Forgot password form fields
  String email = '';
  String otp = '';
  String newPassword = '';
  String confirmPassword = '';

  // OTP related
  bool isOtpSent = false;
  bool isOtpVerified = false;

  // Validation methods
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Send reset password email
  Future<bool> sendResetPasswordEmail() async {
    if (!isValidEmail(email)) {
      errorMessage = 'Please enter valid email';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    final result = await AuthApiService.forgotPassword(
      email: email,
    );

    if (result['success']) {
      isOtpSent = true;
      isLoading = false;
      update();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Failed to send reset email';
      isLoading = false;
      update();
      return false;
    }
  }

  // Verify OTP for password reset
  Future<bool> verifyResetPasswordOtp() async {
    if (otp.length != 6) {
      errorMessage = 'Please enter valid 6-digit OTP';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    final result = await AuthApiService.verifyResetPasswordOtp(
      email: email,
      otp: otp,
    );

    if (result['success']) {
      isOtpVerified = true;
      isLoading = false;
      update();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Invalid OTP';
      isLoading = false;
      update();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword() async {
    if (!isValidPassword(newPassword) || newPassword != confirmPassword) {
      errorMessage = 'Please enter valid password and confirm it';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    final result = await AuthApiService.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    if (result['success']) {
      isLoading = false;
      update();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Failed to reset password';
      isLoading = false;
      update();
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    return await sendResetPasswordEmail();
  }

  // Clear form data
  void clearForm() {
    email = '';
    otp = '';
    newPassword = '';
    confirmPassword = '';
    isOtpSent = false;
    isOtpVerified = false;
    errorMessage = null;
    update();
  }

}
