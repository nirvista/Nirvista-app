import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../core/storage.dart';

class AuthApiService {
  static String? authToken;
  static final Random _random = Random();

  static bool _isPlaceholderToken(String? token) {
    if (token == null) return true;
    final trimmed = token.trim();
    if (trimmed.isEmpty) return true;
    return trimmed == '<JWT>';
  }

  static Map<String, String> _headers({bool auth = false}) {
    final headers = {
      "Content-Type": "application/json",
    };
    if (auth && authToken != null) {
      headers["Authorization"] = "Bearer $authToken";
    }
    return headers;
  }

  static Map<String, dynamic> _decodeResponse(http.Response res) {
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      if (!decoded.containsKey('success')) {
        decoded['success'] = res.statusCode >= 200 && res.statusCode < 300;
      }
      return decoded;
    }
    return {
      'success': res.statusCode >= 200 && res.statusCode < 300,
      'data': decoded,
    };
  }

  static Future<String?> _getAuthToken() async {
    if (!_isPlaceholderToken(authToken)) {
      return authToken;
    }

    final stored = await Storage.getToken();
    if (!_isPlaceholderToken(stored)) {
      authToken = stored;
      return authToken;
    }

    if (!_isPlaceholderToken(ApiConstants.defaultBearerToken)) {
      authToken = ApiConstants.defaultBearerToken;
      return authToken;
    }

    return null;
  }

  static String _normalizeReceipt(String? receipt, {String prefix = 'w'}) {
    // Razorpay receipts must be <= 40 characters.
    const maxLength = 40;
    final candidate = receipt?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate.length <= maxLength
          ? candidate
          : candidate.substring(0, maxLength);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomSuffix = _random.nextInt(0x7fffffff).toRadixString(36);
    final generated = '${prefix}_${timestamp}_$randomSuffix';
    return generated.length <= maxLength
        ? generated
        : generated.substring(0, maxLength);
  }

  static String _normalizeDescription(String? description,
      {String fallback = 'Wallet top-up'}) {
    final candidate = description?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      // Razorpay allows up to 255 chars; keep it short.
      return candidate.length <= 100
          ? candidate
          : candidate.substring(0, 100);
    }
    return fallback;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getAuthToken();
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static String? _extractToken(Map<String, dynamic> data) {
    final token = data['token'];
    if (token is String && token.isNotEmpty) {
      return token;
    }
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final nestedToken = nested['token'];
      if (nestedToken is String && nestedToken.isNotEmpty) {
        return nestedToken;
      }
    }
    return null;
  }

  // ---------------- SIGNUP ----------------

  static Future<Map<String, dynamic>> signupMobileInit({
    required String name,
    required String mobile,
    String? referralCode,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.signupMobileInit),
      headers: _headers(),
      body: jsonEncode({
        "name": name,
        "mobile": mobile,
        if (referralCode != null) "referralCode": referralCode,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> signupEmailInit({
  required String name,
  required String email,
  required String password,
  String? referralCode,
}) async {
  final res = await http.post(
    Uri.parse(ApiConstants.baseUrl + ApiConstants.signupEmailInit),
    headers: _headers(),
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      if (referralCode != null) "referralCode": referralCode,
    }),
  );

  return jsonDecode(res.body);
}


  // static Future<Map<String, dynamic>> signupEmailInit({
  //   required String name,
  //   required String email,
  //   required String password,
  //   String? referralCode,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse(ApiConstants.baseUrl + ApiConstants.signupEmailInit),
  //     headers: _headers(),
  //     body: jsonEncode({
  //       "name": name,
  //       "email": email,
  //       "password": password,
  //       "referralCode": referralCode,
  //     }),
  //   );
  //   return jsonDecode(res.body);
  // }

  static Future<Map<String, dynamic>> signupCombinedInit({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? referralCode,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.signupCombinedInit),
      headers: _headers(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "referralCode": referralCode,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> signupVerify({
    required String userId,
    required String otp,
    required String type,
    String? pin,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.signupVerify),
      headers: _headers(),
      body: jsonEncode({
        "userId": userId,
        "otp": otp,
        "type": type,
        if (pin != null && pin.isNotEmpty) "pin": pin,
      }),
    );

    final data = _decodeResponse(res);
    final token = _extractToken(data);
    if (token != null) {
      authToken = token;
      await Storage.saveToken(token);
      data["token"] ??= token;
      data["success"] = true;
    }
    return data;
  }

  static Future<Map<String, dynamic>> setupPin({
    required String pin,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.setupPin),
      headers: headers,
      body: jsonEncode({"pin": pin}),
    );
    return _decodeResponse(res);
  }

  // ---------------- LOGIN ----------------

  static Future<Map<String, dynamic>> loginOtpInit({
    required String mobile,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.loginOtpInit),
      headers: _headers(),
      body: jsonEncode({"mobile": mobile}),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> loginOtpVerify({
    required String mobile,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.loginOtpVerify),
      headers: _headers(),
      body: jsonEncode({
        "mobile": mobile,
        "otp": otp,
      }),
    );

    final data = _decodeResponse(res);
    final token = _extractToken(data);
    if (token != null) {
      authToken = token;
      await Storage.saveToken(token);
      data["token"] ??= token;
      data["success"] = true;
    }
    return data;
  }

  static Future<Map<String, dynamic>> loginWithPin({
    required String identifier,
    required String pin,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.loginPin),
      headers: _headers(),
      body: jsonEncode({
        "identifier": identifier,
        "pin": pin,
      }),
    );

    final data = _decodeResponse(res);
    final token = _extractToken(data);
    if (token != null) {
      authToken = token;
      await Storage.saveToken(token);
      data["token"] ??= token;
      data["success"] = true;
    }
    return data;
  }

  // ---------------- USER ----------------

  static Future<Map<String, dynamic>> onboardingStatus() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.onboardingStatus),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> profile() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> initiatePinChange() async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.userPinChange),
      headers: headers,
      body: jsonEncode({}),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> confirmPinChange({
    required String otp,
    required String newPin,
    required String confirmPin,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.userPinChange),
      headers: headers,
      body: jsonEncode({
        "otp": otp,
        "newPin": newPin,
        "confirmPin": confirmPin,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getReferralDownline({
    int depth = 0,
    int page = 1,
    int limit = 50,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse(
      '${ApiConstants.referralDownline}?depth=$depth&page=$page&limit=$limit',
    );
    final res = await http.get(uri, headers: headers);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getIcoStages() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.icoStages),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> updateProfileName({
    required String name,
  }) async {
    final headers = await _authHeaders();
    final res = await http.patch(
      Uri.parse(ApiConstants.profileName),
      headers: headers,
      body: jsonEncode({"name": name}),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> requestEmailChangeOtp({
    String channel = 'mobile',
  }) async {
    return await initUserOtp(
      purpose: 'email_change',
      channel: channel,
    );
  }

  static Future<Map<String, dynamic>> changeEmail({
    required String email,
    required String otp,
  }) async {
    final headers = await _authHeaders();
    final res = await http.patch(
      Uri.parse(ApiConstants.profileEmail),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> uploadProfileImage({
    required String filename,
    List<int>? bytes,
    String? filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.profileImage),
    );
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          filePath,
          filename: filename,
        ),
      );
    } else if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'document',
          bytes,
          filename: filename,
        ),
      );
    } else {
      return {
        'success': false,
        'message': 'No file data provided for upload.',
      };
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> initUserOtp({
    required String purpose,
    required String channel,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.userOtpInit),
      headers: headers,
      body: jsonEncode({
        "purpose": purpose,
        "channel": channel,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> verifyUserOtp({
    required String purpose,
    required String otp,
    String channel = 'mobile',
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.userOtpVerify),
      headers: headers,
      body: jsonEncode({
        "purpose": purpose,
        "otp": otp,
        "code": otp,
        "channel": channel,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> addBankDetails({
    required String accountHolderName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String otp,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.userBank),
      headers: headers,
      body: jsonEncode({
        "accountHolderName": accountHolderName,
        "accountNumber": accountNumber,
        "ifsc": ifsc,
        "bankName": bankName,
        "otp": otp,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getBankRequests() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.userBankRequests),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getReferralCode() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.referralCode),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getWalletSummary() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.walletSummary),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getWalletTransactions({
    int page = 1,
    int limit = 50,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse(
        '${ApiConstants.walletTransactions}?page=$page&limit=$limit');
    final res = await http.get(uri, headers: headers);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getIcoTransactions({
    int page = 1,
    int limit = 50,
  }) async {
    final headers = await _authHeaders();
    final uri =
        Uri.parse('${ApiConstants.icoTransactions}?page=$page&limit=$limit');
    final res = await http.get(uri, headers: headers);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> initiateWalletTopup({
    required double amount,
    String? paymentMethod,
    String? redirectUrl,
    String? note,
    String? receipt,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.walletTopup),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
        if (paymentMethod != null) "paymentMethod": paymentMethod,
        if (redirectUrl != null) "redirectUrl": redirectUrl,
        if (note != null) "note": note,
        if (receipt != null) "receipt": _normalizeReceipt(receipt, prefix: 'w'),
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> createWalletPhonePePay({
    required double amount,
    required String? userId,
    required String host,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.phonePePay),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
        if (userId != null) "userId": userId,
        "host": host,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> phonePeStatus({
    required String transactionId,
  }) async {
    final headers = await _authHeaders();
    final uri =
        Uri.parse('${ApiConstants.phonePeStatus}/$transactionId');
    final res = await http.get(uri, headers: headers);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    String currency = 'INR',
    String? receipt,
    String? description,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.razorpayOrder),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
        "currency": currency,
        "receipt": _normalizeReceipt(receipt, prefix: 'wallet'),
        "description":
            _normalizeDescription(description, fallback: 'Wallet top-up'),
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String transactionId,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(Uri.parse(ApiConstants.razorpayVerify),
        headers: headers,
        body: jsonEncode({
          "orderId": orderId,
          "paymentId": paymentId,
          "signature": signature,
          "transactionId": transactionId,
        }));
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getIcoSummary() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.icoSummary),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getWalletAnalytics() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.walletAnalytics),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> createStake({
    required double tokenAmount,
    String stackType = 'fixed',
    required int durationMonths,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.walletStake),
      headers: headers,
      body: jsonEncode({
        "tokenAmount": tokenAmount,
        "stackType": stackType,
        "durationMonths": durationMonths,
      }),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> getWalletStakes({
    int limit = 100,
  }) async {
    final headers = await _authHeaders();
    final safeLimit = limit.clamp(1, 200);
    final uri = Uri.parse('${ApiConstants.walletStakes}?limit=$safeLimit');
    final res = await http.get(uri, headers: headers);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> withdrawStake({
    required String stakeId,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.walletStakeWithdraw(stakeId)),
      headers: headers,
      body: jsonEncode({}),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> claimStake({
    required String stakeId,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.walletStakeClaim(stakeId)),
      headers: headers,
      body: jsonEncode({}),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> buyIcoTokens({
    double? tokenAmount,
    double? fiatAmount,
    bool useWallet = true,
    String? paymentMethod,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{
      if (tokenAmount != null) "tokenAmount": tokenAmount,
      if (fiatAmount != null) "fiatAmount": fiatAmount,
      if (useWallet) "useWallet": true,
      if (paymentMethod != null) "paymentMethod": paymentMethod,
    };
    final res = await http.post(
      Uri.parse(ApiConstants.icoBuy),
      headers: headers,
      body: jsonEncode(body),
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> swapTokens({
    required double tokenAmount,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/wallet/swap'),
      headers: headers,
      body: jsonEncode({"tokenAmount": tokenAmount}),
    );
    return _decodeResponse(res);
  }

  // static Future<Map<String, dynamic>> logout() async {
  //   final res = await http.post(
  //     Uri.parse(ApiConstants.baseUrl + ApiConstants.logout),
  //     headers: _headers(auth: true),
  //   );
  //   authToken = null;
  //   return jsonDecode(res.body);
  // }

  // ---------------- FORGOT PASSWORD ----------------

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/forgot-password'),
      headers: _headers(),
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/verify-reset-password-otp'),
      headers: _headers(),
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/reset-password'),
      headers: _headers(),
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      }),
    );
    return jsonDecode(res.body);
  }

  // ---------------- FORGOT PIN ----------------

  // static Future<Map<String, dynamic>> forgotPin({
  //   required String email,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPin),
  //     headers: _headers(),
  //     body: jsonEncode({"email": email}),
  //   );
  //   return jsonDecode(res.body);
  // }

  // static Future<Map<String, dynamic>> verifyResetPinOtp({
  //   required String email,
  //   required String otp,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyResetPinOtp),
  //     headers: _headers(),
  //     body: jsonEncode({
  //       "email": email,
  //       "otp": otp,
  //     }),
  //   );
  //   return jsonDecode(res.body);
  // }

  // static Future<Map<String, dynamic>> resetPin({
  //   required String email,
  //   required String otp,
  //   required String newPin,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPin),
  //     headers: _headers(),
  //     body: jsonEncode({
  //       "email": email,
  //       "otp": otp,
  //       "new_pin": newPin,
  //     }),
  //   );
  //   return jsonDecode(res.body);
  // }

  // ---------------- ADDITIONAL METHODS ----------------

  static Future<Map<String, dynamic>> initMobileSignup({
    required String name,
    required String mobile,
    String? referralCode,
  }) async {
    return await signupMobileInit(
      name: name,
      mobile: mobile,
      referralCode: referralCode,
    );
  }

  static Future<Map<String, dynamic>> sendEmailVerification({
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/send-email-verification'),
      headers: _headers(),
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/auth/verify-email-otp'),
      headers: _headers(),
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getKycStatus() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConstants.kycStatus),
      headers: headers,
    );
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> uploadKycDocument({
    required String documentType,
    required String filename,
    List<int>? bytes,
    String? filePath,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.kycUpload}?documentType=$documentType');
    final request = http.MultipartRequest('POST', uri);
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          filePath,
          filename: filename,
        ),
      );
    } else if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'document',
          bytes,
          filename: filename,
        ),
      );
    } else {
      return {
        'success': false,
        'message': 'No file data provided for upload.',
      };
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _decodeResponse(res);
  }

  static Future<Map<String, dynamic>> submitKyc({
    required String panNumber,
    required String aadhaarNumber,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.kycSubmit),
      headers: headers,
      body: jsonEncode({
        "metadata": {
          "panNumber": panNumber,
          "aadhaarNumber": aadhaarNumber,
        },
      }),
    );
    return _decodeResponse(res);
  }
}














// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../constants/api_constants.dart';

// class AuthApiService {
//   // Headers for authenticated requests
//   static Map<String, String> get headers => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   // Add auth token to headers if available
//   static Map<String, String> get authHeaders {
//     final headers = Map<String, String>.from(AuthApiService.headers);
//     // Add token if available from storage
//     // headers['Authorization'] = 'Bearer $token';
//     return headers;
//   }

//   // ---------------- USER REGISTRATION ----------------

//   static Future<Map<String, dynamic>> initMobileSignup({
//     required String name,
//     required String mobile,
//     String? referralCode,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.signupMobileInit),
//         headers: headers,
//         body: jsonEncode({
//           'name': name,
//           'mobile': mobile,
//           'referralCode': referralCode,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> signupVerify({
//     required String userId,
//     required String otp,
//     required String pin,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.signupVerify),
//         headers: headers,
//         body: jsonEncode({
//           'userId': userId,
//           'otp': otp,
//           'type': 'mobile',
//           'pin': pin,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // Remove this method as it's not in your Postman collection
//   // static Future<Map<String, dynamic>> registerUser({
//   //   required String firstName,
//   //   required String lastName,
//   //   required String email,
//   //   required String phone,
//   //   required String pin,
//   // }) async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(ApiConstants.register),
//   //       headers: headers,
//   //       body: jsonEncode({
//   //         'first_name': firstName,
//   //         'last_name': lastName,
//   //         'email': email,
//   //         'phone': phone,
//   //         'pin': pin,
//   //       }),
//   //     );

//   //     return _handleResponse(response);
//   //   } catch (e) {
//   //     return {'success': false, 'message': 'Network error: $e'};
//   //   }
//   // }

//   // ---------------- EMAIL VERIFICATION ----------------

//   static Future<Map<String, dynamic>> sendEmailVerification({
//     required String email,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/send-email-verification'),
//         headers: headers,
//         body: jsonEncode({'email': email}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyEmailOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/verify-email-otp'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- LOGIN ----------------

//   static Future<Map<String, dynamic>> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/login-email'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> loginOtpInit({
//     required String identifier,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.loginOtpInit),
//         headers: headers,
//         body: jsonEncode({'identifier': identifier}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> loginOtpVerify({
//     required String identifier,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.loginOtpVerify),
//         headers: headers,
//         body: jsonEncode({
//           'identifier': identifier,
//           'otp': otp,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> loginWithPin({
//     required String identifier,
//     required String pin,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.loginPin),
//         headers: headers,
//         body: jsonEncode({
//           'identifier': identifier,
//           'pin': pin,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> loginMobileInit({
//     required String mobile,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.loginMobileInit),
//         headers: headers,
//         body: jsonEncode({'mobile': mobile}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> loginMobileVerify({
//     required String mobile,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.loginMobileVerify),
//         headers: headers,
//         body: jsonEncode({
//           'mobile': mobile,
//           'otp': otp,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> setupPin({
//     required String pin,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.setupPin),
//         headers: authHeaders,
//         body: jsonEncode({'pin': pin}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- PASSWORD RESET ----------------

//   static Future<Map<String, dynamic>> forgotPassword({
//     required String email,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
//         headers: headers,
//         body: jsonEncode({'email': email}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyResetPasswordOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/verify-reset-password-otp'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> resetPassword({
//     required String email,
//     required String otp,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//           'new_password': newPassword,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- PIN RESET ----------------

//   static Future<Map<String, dynamic>> forgotPin({
//     required String email,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/forgot-pin'),
//         headers: headers,
//         body: jsonEncode({'email': email}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyResetPinOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/verify-reset-pin-otp'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> resetPin({
//     required String email,
//     required String otp,
//     required String newPin,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/reset-pin'),
//         headers: headers,
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//           'new_pin': newPin,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }



//   // ---------------- LOGOUT ----------------

//   static Future<Map<String, dynamic>> logout() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
//         headers: authHeaders,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- UTILITY METHODS ----------------

//   static Map<String, dynamic> _handleResponse(http.Response response) {
//     try {
//       final data = jsonDecode(response.body);

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return {
//           'success': true,
//           'data': data,
//           'statusCode': response.statusCode,
//         };
//       } else {
//         return {
//           'success': false,
//           'message': data['message'] ?? 'Request failed',
//           'statusCode': response.statusCode,
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Failed to parse response',
//         'statusCode': response.statusCode,
//       };
//     }
//   }

//   // Check if user is authenticated
//   static Future<bool> isAuthenticated() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/auth/me'),
//         headers: authHeaders,
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Refresh token
//   static Future<Map<String, dynamic>> refreshToken() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
//         headers: headers,
//         // Add refresh token from storage
//         // body: jsonEncode({'refresh_token': refreshToken}),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- KYC METHODS ----------------

//   static Future<Map<String, dynamic>> uploadKycDocument({
//     required String documentType,
//     required String filePath,
//   }) async {
//     try {
//       // Note: This would typically use multipart/form-data for file upload
//       // For now, using placeholder implementation
//       final response = await http.post(
//         Uri.parse(ApiConstants.kycUpload),
//         headers: authHeaders,
//         body: jsonEncode({
//           'documentType': documentType,
//           'filePath': filePath,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> submitKyc({
//     required String panNumber,
//     required String aadhaarNumber,
//     required String documentUrls,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiConstants.kycSubmit),
//         headers: authHeaders,
//         body: jsonEncode({
//           'panNumber': panNumber,
//           'aadhaarNumber': aadhaarNumber,
//           'documentUrls': documentUrls,
//         }),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> getKycStatus() async {
//     try {
//       final response = await http.get(
//         Uri.parse(ApiConstants.kycStatus),
//         headers: authHeaders,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   // ---------------- USER METHODS ----------------

//   static Future<Map<String, dynamic>> getOnboardingStatus() async {
//     try {
//       final response = await http.get(
//         Uri.parse(ApiConstants.onboardingStatus),
//         headers: authHeaders,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse(ApiConstants.profile),
//         headers: authHeaders,
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }
// }
