import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';

class SingInController extends GetxController implements GetxService {

  bool istrue = true;
  bool isnumber = false;
  bool isLoading = false;
  String? errorMessage;

  int numberselecter = 0;
  List numbers = [
    "In +91",
    "Us +1",
    "Vn +3",
    "Ru +7",
    "AF +93",
    "CAN +3",
  ];

  // Login form fields
  String email = '';
  String password = '';
  String phoneNumber = '';
  String pin = '';
  String selectedCountryCode = '+91';

  // Text controllers
  TextEditingController phoneController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  // OTP related
  String otp = '';
  bool isOtpSent = false;
  bool isOtpVerified = false;
  String get fullPhone => selectedCountryCode + phoneNumber.trim();

  // Forgot password
  String resetEmail = '';
  String resetOtp = '';
  String newPassword = '';
  String confirmPassword = '';

  passwordis(bool value){
    istrue = value;
    update();
  }
  numberselecter2(int value){
    numberselecter = value;
    selectedCountryCode = numbers[value].split(' ')[1];
    update();
  }
  isnumber2(bool value){
    isnumber = value;
    update();
  }

  // Email/Phone validation
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  // Login with Phone and PIN via API
  Future<bool> loginWithPhone() async {
    if (!isValidPhone(phoneNumber) || pin.isEmpty) {
      errorMessage = 'Please enter valid phone number and PIN';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      String fullPhone = selectedCountryCode + phoneNumber;

      // Call API to login with PIN
      final response = await AuthApiService.loginWithPin(
        identifier: fullPhone,
        pin: pin,
      );

      if (response['success']) {
        isOtpVerified = true;
        isLoading = false;
        update();
        Get.offAllNamed("/dashboard");
        return true;
      } else {
        errorMessage = response['message'] ?? 'Invalid credentials';
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';
      isLoading = false;
      update();
      return false;
    }
  }

  // Send OTP for login
  Future<bool> sendLoginOtp() async {
    final trimmedPhone = phoneNumber.trim();

    if (!isValidPhone(trimmedPhone)) {
      errorMessage = 'Please enter a valid phone number';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      // Call API to send OTP for login
      final response = await AuthApiService.loginOtpInit(
        mobile: trimmedPhone,
      );

      if (response['success']) {
        // OTP sent successfully
        isOtpSent = true;
        isLoading = false;
        update();
        return true;
      } else {
        // API returned error
        errorMessage = response['message'] ?? 'Failed to send OTP. Please try again.';
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to send OTP. Please try again.';
      isLoading = false;
      update();
      return false;
    }
  }

  // Verify login OTP
  Future<bool> verifyLoginOtp() async {
    final trimmedOtp =
        otpController.text.isNotEmpty ? otpController.text.trim() : otp.trim();

    if (trimmedOtp.length != 6) {
      errorMessage = 'Please enter a valid 6-digit OTP';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final trimmedPhone = phoneNumber.trim();

      // Verify OTP via API
      final response = await AuthApiService.loginOtpVerify(
        mobile: trimmedPhone,
        otp: trimmedOtp,
      );

      if (response['success']) {
        isOtpVerified = true;
        isLoading = false;
        update();
        return true;
      } else {
        errorMessage = response['message'] ?? 'Invalid OTP';
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to verify OTP. Please try again.';
      isLoading = false;
      update();
      return false;
    }
  }

  // Clear form data
  void clearForm() {
    email = '';
    password = '';
    phoneNumber = '';
    pin = '';
    otp = '';
    resetEmail = '';
    resetOtp = '';
    newPassword = '';
    confirmPassword = '';
    isOtpSent = false;
    isOtpVerified = false;
    errorMessage = null;
    update();
  }
}
