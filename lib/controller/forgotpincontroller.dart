// import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import '../constants/api_constants.dart';
// import '../services/auth_api_service.dart';

// class ForgotPinController extends GetxController implements GetxService {
//   bool isNewPinHidden = true;
//   bool isConfirmPinHidden = true;
//   bool isLoading = false;
//   String? errorMessage;

//   // Forgot PIN form fields
//   String email = '';
//   String otp = '';
//   String newPin = '';
//   String confirmPin = '';

//   // OTP related
//   bool isOtpSent = false;
//   bool isOtpVerified = false;

//   void toggleNewPinVisibility() {
//     isNewPinHidden = !isNewPinHidden;
//     update();
//   }

//   void toggleConfirmPinVisibility() {
//     isConfirmPinHidden = !isConfirmPinHidden;
//     update();
//   }

//   // Validation methods
//   bool isValidEmail(String email) {
//     return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
//   }

//   bool isValidPin(String pin) {
//     return pin.length >= 4 && pin.length <= 6;
//   }

//   // Send reset PIN email
//   Future<bool> sendResetPinEmail() async {
//     if (!isValidEmail(email)) {
//       errorMessage = 'Please enter valid email';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     final result = await AuthApiService.forgotPin(
//       email: email,
//     );

//     if (result['success']) {
//       isOtpSent = true;
//       isLoading = false;
//       update();
//       return true;
//     } else {
//       errorMessage = result['message'] ?? 'Failed to send reset email';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Verify OTP for PIN reset
//   Future<bool> verifyResetOtp() async {
//     if (otp.length != 6) {
//       errorMessage = 'Please enter valid 6-digit OTP';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     final result = await AuthApiService.verifyResetPinOtp(
//       email: email,
//       otp: otp,
//     );

//     if (result['success']) {
//       isOtpVerified = true;
//       isLoading = false;
//       update();
//       return true;
//     } else {
//       errorMessage = result['message'] ?? 'Invalid OTP';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Reset PIN
//   Future<bool> resetPin() async {
//     if (!isValidPin(newPin) || newPin != confirmPin) {
//       errorMessage = 'Please enter valid PIN and confirm it';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     final result = await AuthApiService.resetPin(
//       email: email,
//       otp: otp,
//       newPin: newPin,
//     );

//     if (result['success']) {
//       isLoading = false;
//       update();
//       return true;
//     } else {
//       errorMessage = result['message'] ?? 'Failed to reset PIN';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Resend OTP
//   Future<bool> resendOtp() async {
//     return await sendResetPinEmail();
//   }

//   // Clear form data
//   void clearForm() {
//     email = '';
//     otp = '';
//     newPin = '';
//     confirmPin = '';
//     isOtpSent = false;
//     isOtpVerified = false;
//     errorMessage = null;
//     update();
//   }

// }