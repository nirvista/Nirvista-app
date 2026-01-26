import 'package:flutter/foundation.dart';
import 'package:nirvista/services/auth_api_service.dart';
import 'package:get/get.dart';

//import 'dart:math';
class SingUpController extends GetxController implements GetxService {
  bool isTextisHide = true;
  bool isLoading = false;
  String? errorMessage;

  // Signup fields
  String name = '';
  String mobile = '';
  String referralCode = '';
  String selectedCountryCode = '+91';
  String pin = '';
  String get fullMobile => selectedCountryCode + mobile.trim();

  // OTP
  String otp = '';
  bool isOtpSent = false;
  bool isOtpVerified = false;

  Map<String, dynamic> _normalizeResponse(dynamic source) {
    if (source is Map<String, dynamic>) {
      return source;
    }
    if (source is Map) {
      return Map<String, dynamic>.from(source);
    }
    return <String, dynamic>{};
  }
  int otpTimer = 60;
  bool isTimerRunning = false;

  // VERY IMPORTANT
  String? userId; // backend se aata hai

  String? _extractUserId(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final direct = data['userId'] ?? data['id'] ?? data['_id'];
      if (direct is String && direct.isNotEmpty) return direct;
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        final nested = user['userId'] ?? user['id'] ?? user['_id'];
        if (nested is String && nested.isNotEmpty) return nested;
      }
    }
    final top = response['userId'] ?? response['id'] ?? response['_id'];
    if (top is String && top.isNotEmpty) return top;

    final message = response['message'];
    if (message is String && message.contains('userId')) {
      final parts = message.split(RegExp(r'[: ]'));
      final possible = parts.lastWhere(
        (p) => RegExp(r'^[A-Za-z0-9]+$').hasMatch(p) && p.length >= 8,
        orElse: () => '',
      );
      if (possible.isNotEmpty) return possible;
    }
    return null;
  }

  void setTextIsTrue(bool value) {
    isTextisHide = value;
    update();
  }

  // ---------------- VALIDATIONS ----------------
  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  bool isValidPin(String pin) {
    return pin.length >= 4 && pin.length <= 6;
  }

  bool isValidName(String value) {
    return value.trim().length >= 2;
  }

  // ---------------- SEND OTP ----------------
  Future<bool> sendOtp() async {
    final trimmedName = name.trim();
    final trimmedMobile = mobile.trim();

    if (!isValidName(trimmedName)) {
      errorMessage = 'Please enter your name';
      update();
      return false;
    }

    if (!isValidPhone(trimmedMobile)) {
      errorMessage = 'Please enter valid mobile number';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      mobile = trimmedMobile;
      final fullPhone = fullMobile;
      otp = '';

      final response = await AuthApiService.initMobileSignup(
        name: trimmedName,
        mobile: fullPhone,
        referralCode: referralCode.trim().isEmpty ? null : referralCode.trim(),
      );

      final responseMap = _normalizeResponse(response);
      debugPrint('SIGNUP OTP RESPONSE: $responseMap');

      // Treat response as success if explicit success flag is true OR a userId is present.
      userId = _extractUserId(responseMap);
      final isSuccess = responseMap['success'] == true ||
          (userId != null && userId!.isNotEmpty);

      if (isSuccess) {
        isOtpVerified = false;
        debugPrint('Signup userId: $userId');

        if (userId == null || userId!.isEmpty) {
          errorMessage = responseMap['message'] ??
              'UserId not received from server';
          isLoading = false;
          update();
          return false;
        }

        isOtpSent = true;
        otpTimer = 60;
        isTimerRunning = true;
        _startTimer();

        isLoading = false;
        update();
        return true;
      } else {
        errorMessage = responseMap['message'] ?? 'Failed to send OTP';
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to send OTP';
      isLoading = false;
      update();
      return false;
    }
  }

  // ---------------- VERIFY OTP ----------------

  Future<bool> verifyOtp() async {
    if (otp.length != 6) {
      errorMessage = 'Enter valid 6 digit OTP';
      update();
      return false;
    }

    if (userId == null || userId!.isEmpty) {
      errorMessage = 'Please request OTP first';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await AuthApiService.signupVerify(
        userId: userId!,
        otp: otp,
        type: 'mobile',
      );

      if (response['success'] == true) {
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
      errorMessage = 'OTP verification failed';
      isLoading = false;
      update();
      return false;
    }
  }

  // ---------------- TIMER ----------------

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (otpTimer > 0 && isTimerRunning) {
        otpTimer--;
        update();
        _startTimer();
      } else {
        isTimerRunning = false;
        update();
      }
    });
  }

  // ---------------- SET PIN ----------------

  Future<bool> setupPin() async {
    if (!isOtpVerified) {
      errorMessage = 'Please verify OTP first';
      update();
      return false;
    }

    if (!isValidPin(pin)) {
      errorMessage = 'Enter valid PIN';
      update();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await AuthApiService.setupPin(pin: pin);

      if (response['success'] == true) {
        isLoading = false;
        update();
        return true;
      } else {
        errorMessage = response['message'] ?? 'Failed to set PIN';
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to set PIN';
      isLoading = false;
      update();
      return false;
    }
  }

  // ---------------- CLEAR ----------------

  void clearForm() {
    name = '';
    mobile = '';
    referralCode = '';
    pin = '';
    otp = '';
    userId = null;
    isOtpSent = false;
    isOtpVerified = false;
    errorMessage = null;
    otpTimer = 60;
    isTimerRunning = false;
    isLoading = false;
    update();
  }
}

















// import 'package:nirvista/services/auth_api_service.dart';
// import 'package:get/get.dart';
// import 'dart:math';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class SingUpController extends GetxController implements GetxService {
//   bool isTextisHide = true;
//   bool isLoading = false;
//   String? errorMessage;
//   String generatedPin = ''; // PIN generated for the user

//   // Signup form fields
//   String firstName = '';
//   String lastName = '';
//   String email = '';
//   String phoneNumber = '';
//   String pin = '';
//   String selectedCountryCode = '+91';

//   // OTP related
//   String otp = '';
//   bool isOtpSent = false;
//   bool isOtpVerified = false;
//   int otpTimer = 60; // 1 minute
//   bool isTimerRunning = false;
//   String? userId; // User ID from signup init response

//   setTextIsTrue(bool value){
//     isTextisHide = value;
//     update();
//   }

//   // Validation methods
//   bool isValidEmail(String email) {
//     return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
//   }

//   bool isValidPhone(String phone) {
//     return RegExp(r'^\d{10}$').hasMatch(phone);
//   }

//   bool isValidPin(String pin) {
//     return pin.length >= 4 && pin.length <= 6;
//   }

//   bool isValidName(String name) {
//     return name.length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
//   }

//   // Generate a random PIN
//   String _generatePin() {
//     Random random = Random();
//     return (1000 + random.nextInt(9000)).toString(); // 4-digit PIN
//   }

//   // Send OTP to phone
//   Future<bool> sendOtp() async {
//     late String signupUserId;
//     signupUserId = response['data']['userId']; // ✅ REQUIRED
// isOtpSent = true;


//     if (response['success']) {
//       signupUserId = response['data']['userId']; // ✅ REQUIRED
//       isOtpSent = true;
//     }


//     if (!isValidPhone(phoneNumber)) {
//       errorMessage = 'Please enter a valid phone number';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       String fullPhone = selectedCountryCode + phoneNumber;

//       // Call API to send OTP to mobile
//       final response = await AuthApiService.initMobileSignup(
//         name: '$firstName $lastName',
//         mobile: fullPhone,
//         referralCode: null, // Add referral code if available
//       );

//       if (response['success']) {
//         // Store userId from response
//         userId = response['data']['userId'] ?? response['data']['id'];
//         // OTP sent successfully
//         isOtpSent = true;
//         otpTimer = 60;
//         isTimerRunning = true;
//         _startTimer();

//         isLoading = false;
//         update();
//         return true;
//       } else {
//         // API returned error
//         errorMessage = response['message'] ?? 'Failed to send OTP. Please try again.';
//         isLoading = false;
//         update();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = 'Failed to send OTP. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Send OTP to email (for email signup)
//   Future<bool> sendEmailOtp() async {
//     if (!isValidEmail(email)) {
//       errorMessage = 'Please enter a valid email';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       // Call API to send OTP to email
//       final response = await AuthApiService.sendEmailVerification(
//         email: email,
//       );

//       if (response['success']) {
//         // OTP sent successfully
//         isOtpSent = true;
//         otpTimer = 60;
//         isTimerRunning = true;
//         _startTimer();

//         isLoading = false;
//         update();
//         return true;
//       } else {
//         // API returned error
//         errorMessage = response['message'] ?? 'Failed to send OTP. Please try again.';
//         isLoading = false;
//         update();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = 'Failed to send OTP. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Verify email OTP
//   Future<bool> verifyEmailOtp() async {
//     if (otp.length != 6) {
//       errorMessage = 'Please enter a valid 6-digit OTP';
//       update();
//       return false;
//     }

//     if (!isTimerRunning && otpTimer == 0) {
//       errorMessage = 'OTP expired. Please request a new one.';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       // Verify email OTP via API
//       final response = await AuthApiService.verifyEmailOtp(
//         email: email,
//         otp: otp,
//       );

//       if (response['success']) {
//         isOtpVerified = true;
//         isLoading = false;
//         update();
//         return true;
//       } else {
//         errorMessage = response['message'] ?? 'Invalid OTP';
//         isLoading = false;
//         update();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = 'Failed to verify OTP. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Start OTP timer
//   void _startTimer() {
//     Future.delayed(const Duration(seconds: 1), () {
//       if (otpTimer > 0 && isTimerRunning) {
//         otpTimer--;
//         update();
//         _startTimer();
//       } else {
//         isTimerRunning = false;
//         update();
//       }
//     });
//   }

//   // Verify OTP
//   Future<bool> verifyOtp() async {
//     if (otp.length != 6) {
//       errorMessage = 'Please enter a valid 6-digit OTP';
//       update();
//       return false;
//     }

//     if (!isTimerRunning && otpTimer == 0) {
//       errorMessage = 'OTP expired. Please request a new one.';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       // Verify OTP via API
//       final response = await AuthApiService.signupVerify(
//         userId: userId ?? '',
//         otp: otp,
//         type: 'mobile',
//         pin: pin,
//       );

//       if (response['success']) {
//         isOtpVerified = true;
//         isLoading = false;
//         update();
//         return true;
//       } else {
//         errorMessage = response['message'] ?? 'Invalid OTP';
//         isLoading = false;
//         update();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = 'Failed to verify OTP. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Check if user already exists
//   Future<bool> _userExists(String phone) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey('user_$phone');
//   }

//   // Register user locally
//   Future<bool> registerUser() async {
//     if (!isValidName(firstName) || !isValidName(lastName) || !isValidEmail(email) ||
//         !isValidPhone(phoneNumber)) {
//       errorMessage = 'Please fill all fields correctly';
//       update();
//       return false;
//     }

//     String fullPhone = selectedCountryCode + phoneNumber;

//     // Check if user already exists
//     if (await _userExists(fullPhone)) {
//       errorMessage = 'User with this phone number already exists';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       // Generate PIN for the user
//       generatedPin = _generatePin();

//       // Store user data
//       Map<String, String> userData = {
//         'firstName': firstName,
//         'lastName': lastName,
//         'email': email,
//         'phone': fullPhone,
//         'pin': generatedPin,
//       };

//       // Store as JSON string
//       String userDataJson = jsonEncode(userData);
//       await prefs.setString('user_$fullPhone', userDataJson);

//       isLoading = false;
//       update();
//       return true;
//     } catch (e) {
//       errorMessage = 'Registration failed. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Setup PIN after signup verification
//   Future<bool> setupPin() async {
//     if (!isValidPin(pin)) {
//       errorMessage = 'Please enter a valid PIN';
//       update();
//       return false;
//     }

//     isLoading = true;
//     errorMessage = null;
//     update();

//     try {
//       // Call API to setup PIN
//       final response = await AuthApiService.setupPin(
//         pin: pin,
//       );

//       if (response['success']) {
//         isLoading = false;
//         update();
//         return true;
//       } else {
//         errorMessage = response['message'] ?? 'Failed to setup PIN';
//         isLoading = false;
//         update();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = 'Failed to setup PIN. Please try again.';
//       isLoading = false;
//       update();
//       return false;
//     }
//   }

//   // Verify mobile OTP via API (removed - using verifyOtp() instead)

//   // Clear form data
//   void clearForm() {
//     firstName = '';
//     lastName = '';
//     email = '';
//     phoneNumber = '';
//     pin = '';
//     otp = '';
//     generatedPin = '';
//     isOtpSent = false;
//     isOtpVerified = false;
//     errorMessage = null;
//     update();
//   }

// }
