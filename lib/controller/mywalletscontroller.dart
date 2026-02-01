import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payu_session.dart';
import '../screens/drawercode.dart';
import '../screens/payments/payu_payment_webview.dart';
import '../services/auth_api_service.dart';
import '../services/razorpay_bridge.dart';
import '../constants/api_constants.dart';
import 'dashbordecontroller.dart';
import 'drawercontroller.dart';

class MyWalletsController extends GetxController implements GetxService {
  bool isMoonIn = true;
  bool isMoonOut = false;
  bool isMenuOpen = false;
  bool isMenuOpen1 = false;
  bool isMenuOpen2 = false;
  bool isCheckBox = false;
  bool isCheckBox1 = false;
  bool isCheckBox2 = false;
  bool isCheckBox3 = false;
  bool isCheckBox4 = false;
  bool isCheckBox5 = false;
  bool isCurrencyMenu = false;
  bool isLoading = false;
  bool isTopupLoading = false;
  bool isVerifyLoading = false;
  bool isSwapLoading = false;
  static const int topupMethodPhonePe = 0;
  static const int topupMethodRazorpay = 1;
  static const int topupMethodPayU = 2;
  int selectedTopupMethod = topupMethodRazorpay;
  String? topupError;
  String? topupSuccess;
  String? verifyError;
  String? verifySuccess;
  String? swapError;
  String? swapSuccess;
  String? topupTransactionId;
  String? topupStatus;
  String? phonePeRedirectUrl;
  String? phonePeTxnId;
  Timer? _phonePePoller;
  int _phonePeAttempts = 0;
  Map<String, dynamic>? phonePeSession;
  Map<String, dynamic>? razorpayOrder;
  String? userId;
  BuildContext? _topupOverlayContext;
  bool isStatusLoading = false;
  late Razorpay _razorpay;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController swapAmountController = TextEditingController();
  final TextEditingController razorpayPaymentIdController =
      TextEditingController();
  final TextEditingController razorpaySignatureController =
      TextEditingController();
  List currencyLogo = [
    "assets/images/in.svg",
    "assets/images/pt.svg",
    "assets/images/us.svg",
  ];
  List currencyName = [
    "Rupee",
    "Euro",
    "Dollar",
  ];
  int selectCurrency = 0;
  offIsLoading(context, double width) {
    isLoading = true;
    update();
    Timer(const Duration(seconds: 2), () {
      isLoading = false;
      update();
      Get.back();
      complete1(context, width: width);
    });
  }

  setSelectCurrency(value) {
    selectCurrency = value;
    update();
  }

  int selectPayment = 0;
  setIsCurrencyMenu(value) {
    isCurrencyMenu = value;
    update();
  }

  setPayment(value) {
    selectPayment = value;
    update();
  }

  setTopupMethod(int value) {
    selectedTopupMethod = value; // 0=PhonePe, 1=Razorpay, 2=PayU
    topupError = null;
    topupSuccess = null;
    verifyError = null;
    verifySuccess = null;
    phonePeSession = null;
    razorpayOrder = null;
    topupTransactionId = null;
    topupStatus = null;
    update();
  }

  List paymentList = [
    "assets/images/visa.png",
    "assets/images/mastercarde.png",
    "assets/images/payaneer.png",
  ];
  List paymentName = [
    "Visa",
    "Master Card",
    "Payaneer",
  ];
  ScrollController scrollController = ScrollController();
  List usersProfile = [
    "assets/images/add.png",
    "assets/images/05.png",
    "assets/images/01.png",
    "assets/images/02.png",
    "assets/images/03.png",
    "assets/images/04.png",
    "assets/images/02.png",
    "assets/images/05.png",
    "assets/images/01.png",
    "assets/images/02.png",
    "assets/images/03.png",
    "assets/images/04.png",
    "assets/images/05.png",
  ];
  List usersName = [
    "Add",
    "Hugo First",
    "Percy Vere",
    "Jack Aranda",
    "Olive Tree",
    "John Quil",
    "Glad I. Oli",
    "Hugo First",
    "Percy Vere",
    "Jack Aranda",
    "Olive Tree",
    "John Quil",
    "Glad I. Oli",
  ];
  List listOfMonths = [
    "This Month",
    "Last Month",
    "This Year",
  ];
  List menuIteam = ["IND", "USD", "GBP", "EUR"];
  int selectMenuIteam = 0;
  int selectMenuIteam1 = 1;
  int selectListIteam = 0;
  setListValue(value) {
    selectListIteam = value;
    update();
  }

  void registerTopupOverlayContext(BuildContext context) {
    _topupOverlayContext = context;
  }

  void clearTopupOverlayContext() {
    _topupOverlayContext = null;
  }

  setSelectMenuIteam(value) {
    selectMenuIteam = value;
    update();
  }

  setSelectMenuIteam1(value) {
    selectMenuIteam1 = value;
    update();
  }

  setIsMoonIn(value) {
    isMoonIn = value;
    update();
  }

  setIsCheckBox(value) {
    isCheckBox = value;
    update();
  }

  setIsCheckBox1(value) {
    isCheckBox1 = value;
    update();
  }

  setIsCheckBox2(value) {
    isCheckBox2 = value;
    update();
  }

  setIsCheckBox3(value) {
    isCheckBox3 = value;
    update();
  }

  setIsCheckBox4(value) {
    isCheckBox4 = value;
    update();
  }

  setIsCheckBox5(value) {
    isCheckBox5 = value;
    update();
  }

  setMenuOpen(value) {
    isMenuOpen = value;
    update();
  }

  setMenuOpen1(value) {
    isMenuOpen1 = value;
    update();
  }

  setMenuOpen2(value) {
    isMenuOpen2 = value;
    update();
  }

  setIsMoonOut(value) {
    isMoonOut = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
      _razorpay.on(
          Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);
    }
  }

  double? _parseAmount() {
    final raw = amountController.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final cleaned = raw.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  void resetTopupState({bool keepAmount = true}) {
    topupError = null;
    topupSuccess = null;
    verifyError = null;
    verifySuccess = null;
    swapError = null;
    swapSuccess = null;
    isSwapLoading = false;
    isStatusLoading = false;
    phonePeSession = null;
    phonePeTxnId = null;
    razorpayOrder = null;
    phonePeRedirectUrl = null;
    topupTransactionId = null;
    topupStatus = null;
    if (!keepAmount) {
      amountController.clear();
      swapAmountController.clear();
    }
    razorpayPaymentIdController.clear();
    razorpaySignatureController.clear();
    update();
  }

  Future<void> initiateTopup() async {
    topupError = null;
    topupSuccess = null;
    verifyError = null;
    verifySuccess = null;
    phonePeSession = null;
    razorpayOrder = null;
    phonePeRedirectUrl = null;
    topupTransactionId = null;
    topupStatus = null;
    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      topupError = 'Enter a valid amount.';
      update();
      return;
    }
    isTopupLoading = true;
    update();
    try {
      if (selectedTopupMethod == topupMethodPhonePe) {
        // PhonePe
        final uid = await _ensureUserId();
        if (uid == null || uid.isEmpty) {
          topupError = 'Session expired. Please sign in again to add money.';
          update();
          return;
        }
        final res = await AuthApiService.createWalletPhonePePay(
          amount: amount,
          userId: uid,
          host: ApiConstants.baseUrl,
        );
        await _handleWalletTopupResponse(res, gateway: 'phonepe');
      } else if (selectedTopupMethod == topupMethodRazorpay) {
        // Razorpay receipts must be <= 40 chars.
        final receiptId =
            'rzp_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

        final res = await AuthApiService.createRazorpayOrder(
          amount: amount,
          currency: 'INR',
          description: 'Wallet top-up via Razorpay',
          receipt: receiptId,
        );
        await _handleWalletTopupResponse(res, gateway: 'razorpay');
      } else if (selectedTopupMethod == topupMethodPayU) {
        final res = await AuthApiService.initiateWalletTopup(
          amount: amount,
          paymentMethod: 'payu',
        );
        await _handleWalletTopupResponse(res, gateway: 'payu');
      } else {
        topupError = 'Invalid payment method selected.';
      }
    } catch (e) {
      topupError = 'Failed to initiate top-up. ${e.toString()}';
    } finally {
      isTopupLoading = false;
      update();
    }
  }

  Future<void> _handleWalletTopupResponse(Map<String, dynamic> response,
      {required String gateway}) async {
    try {
      Map<String, dynamic> asMap(dynamic source) {
        if (source is Map<String, dynamic>) {
          return Map<String, dynamic>.from(source);
        }
        if (source is Map) {
          return Map<String, dynamic>.from(source);
        }
        return <String, dynamic>{};
      }

      final payload = asMap(response['data']).isNotEmpty
          ? asMap(response['data'])
          : asMap(response);

      final transaction = asMap(payload['transaction']).isNotEmpty
          ? asMap(payload['transaction'])
          : null;
      final hasRazorpayPayload = payload['razorpay'] is Map;
      final inferredGateway = hasRazorpayPayload
          ? 'razorpay'
          : transaction?['paymentGateway']?.toString() ??
              payload['paymentGateway']?.toString() ??
              gateway;
      topupTransactionId = transaction?['_id']?.toString() ??
          transaction?['id']?.toString() ??
          transaction?['transactionId']?.toString() ??
          payload['transactionId']?.toString();
      topupStatus =
          transaction?['status']?.toString() ?? payload['status']?.toString();

      if (inferredGateway == 'phonepe') {
        String? instrumentRedirect;
        final instrumentResponse = payload['instrumentResponse'];
        if (instrumentResponse is Map<String, dynamic>) {
          final redirectInfo = instrumentResponse['redirectInfo'];
          if (redirectInfo is Map<String, dynamic>) {
            instrumentRedirect = redirectInfo['url']?.toString();
          } else {
            instrumentRedirect =
                instrumentResponse['redirect_info']?['url']?.toString();
          }
        } else if (payload['instrument_response'] is Map<String, dynamic>) {
          instrumentRedirect = (payload['instrument_response']
                  as Map<String, dynamic>)['redirect_info']?['url']
              ?.toString();
        }

        final intentUrl = payload['intentUrl'] ?? payload['intent_url'];
        final redirect = payload['redirectUrl'] ??
            payload['redirect_url'] ??
            payload['paymentPageUrl'] ??
            instrumentRedirect ??
            intentUrl ??
            transaction?['redirectUrl'] ??
            transaction?['redirect_url'];
        phonePeRedirectUrl = redirect?.toString();
        phonePeTxnId = payload['merchantTransactionId']?.toString() ??
            payload['merchantTxnId']?.toString() ??
            payload['txnId']?.toString() ??
            transaction?['transactionId']?.toString() ??
            transaction?['_id']?.toString();
        topupTransactionId ??= phonePeTxnId;
        if (topupTransactionId == null || topupTransactionId!.isEmpty) {
          topupError =
              payload['message']?.toString() ?? 'PhonePe transaction missing.';
          update();
          return;
        }
        final hasRedirect =
            phonePeRedirectUrl != null && phonePeRedirectUrl!.isNotEmpty;
        if (hasRedirect) {
          topupSuccess = 'Opening PhonePe payment page...';
          await _launchExternal(phonePeRedirectUrl!);
        } else {
          topupSuccess = 'PhonePe payment created. Awaiting confirmation...';
        }
        _startPhonePeAutoCheck();
      } else if (inferredGateway == 'razorpay') {
        final order = hasRazorpayPayload
            ? asMap(payload['razorpay'])
            : payload['order'] is Map<String, dynamic>
                ? asMap(payload['order'])
                : asMap(payload);
        final orderId = order['orderId']?.toString() ??
            order['order_id']?.toString() ??
            order['id']?.toString();
        final keyId = order['keyId']?.toString() ??
            order['key_id']?.toString() ??
            order['key']?.toString();
        final amount = order['amount'] ??
            order['amountInPaise'] ??
            order['amount_in_paise'];
        final currency = order['currency']?.toString() ?? 'INR';
        final orderTransactionId = order['transactionId']?.toString() ??
            order['transaction_id']?.toString() ??
            order['txnId']?.toString() ??
            order['txId']?.toString() ??
            order['receipt']?.toString();

        if ((topupTransactionId == null || topupTransactionId!.isEmpty) &&
            orderTransactionId != null &&
            orderTransactionId.isNotEmpty) {
          topupTransactionId = orderTransactionId;
        }

        if (orderId != null &&
            orderId.isNotEmpty &&
            keyId != null &&
            keyId.isNotEmpty) {
          razorpayOrder = {
            'orderId': orderId,
            'keyId': keyId,
            'amount': amount,
            'currency': currency,
            if (orderTransactionId != null && orderTransactionId.isNotEmpty)
              'transactionId': orderTransactionId,
          };
          topupSuccess =
              'Opening Razorpay checkout. Complete the payment to verify automatically.';
          _openRazorpayCheckout();
        } else {
          topupError = payload['message']?.toString() ??
              response['message']?.toString() ??
              'Razorpay order details are missing.';
        }
      } else if (inferredGateway == 'payu') {
        final Map<String, dynamic>? sessionMap =
            _findPayUSessionMap(payload, asMap);
        if (sessionMap == null) {
          topupError = 'PayU session data is missing.';
          update();
          return;
        }
        PayUSession session;
        try {
          session = PayUSession.fromMap(sessionMap);
        } catch (e) {
          topupError = 'PayU session is invalid: ${e.toString()}';
          update();
          return;
        }
        topupSuccess = 'Opening PayU payment window...';
        update();
        final result = await _openPayUPaymentWindow(session);
        final success = result == true;
        final message = success
            ? 'PayU payment completed. Thank you!'
            : 'PayU payment was not completed.';
        await _handlePaymentResult(success: success, message: message);
        return;
      } else {
        topupSuccess = payload['message']?.toString() ??
            response['message']?.toString() ??
            'Top-up initiated. Status: ${topupStatus ?? 'pending'}';
      }
    } catch (e) {
      topupError = 'Failed to start payment. ${e.toString()}';
    }
  }

  int? _normalizePaise(dynamic amount) {
    if (amount == null) return null;
    if (amount is int) return amount;
    if (amount is double) return amount.round();
    if (amount is String) return int.tryParse(amount);
    return null;
  }

  Future<void> openPhonePeRedirect() async {
    if (phonePeRedirectUrl == null || phonePeRedirectUrl!.isEmpty) {
      topupError = 'PhonePe redirect link is missing.';
      update();
      return;
    }
    await _launchExternal(phonePeRedirectUrl!);
    _startPhonePeAutoCheck();
  }

  Future<void> checkPhonePeStatus({bool auto = false}) async {
    if (topupTransactionId == null || topupTransactionId!.isEmpty) {
      topupError = 'Transaction ID missing. Initiate PhonePe again.';
      update();
      return;
    }
    isStatusLoading = true;
    update();
    try {
      final response = await AuthApiService.phonePeStatus(
        transactionId: topupTransactionId!,
      );
      _handlePhonePeStatusResponse(response, auto: auto);
    } catch (_) {
      topupError = 'Failed to fetch status.';
    } finally {
      isStatusLoading = false;
      update();
    }
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      topupError = 'Invalid redirect URL.';
      update();
      return;
    }
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }
    if (!launched) {
      topupError = 'Could not open payment page.';
      update();
    }
  }

  void _startPhonePeAutoCheck() {
    _phonePePoller?.cancel();
    _phonePeAttempts = 0;
    _phonePePoller = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _phonePeAttempts++;
      await checkPhonePeStatus(auto: true);
      if (_phonePeAttempts >= 8) {
        timer.cancel();
      }
      if (topupStatus != null &&
          topupStatus!.toLowerCase().contains('success')) {
        timer.cancel();
      }
    });
  }

  void _handlePhonePeStatusResponse(Map<String, dynamic> response,
      {bool auto = false}) {
    if (response['success'] == true) {
      final payload = response['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(response['data'])
          : Map<String, dynamic>.from(response);
      topupStatus =
          payload['status']?.toString() ?? payload['state']?.toString();
      final normalized = topupStatus?.toLowerCase() ?? '';
      final isSuccess = normalized.contains('success') ||
          normalized.contains('completed') ||
          normalized.contains('captured') ||
          normalized.contains('paid');
      if (isSuccess) {
        _phonePePoller?.cancel();
        _handlePhonePeVerificationSuccess(auto: auto);
      } else if (normalized.contains('failed') ||
          normalized.contains('declined') ||
          normalized.contains('cancel') ||
          normalized.contains('error')) {
        topupError =
            'Payment failed: ${topupStatus ?? 'Unable to complete payment.'}';
        _navigateToTransactionsAfterFailure();
      } else {
        topupSuccess =
            'Payment status: ${topupStatus ?? 'Processing, please refresh shortly.'}';
      }
    } else {
      topupError = response['message']?.toString() ?? 'Failed to fetch status.';
    }
  }

  Future<void> _handlePhonePeVerificationSuccess({bool auto = false}) async {
    topupSuccess =
        auto ? 'PhonePe payment verified automatically.' : 'Payment verified.';
    update();
    await _navigateToTransactionsAfterVerification();
  }

  Future<String?> _ensureUserId() async {
    if (userId != null && userId!.isNotEmpty) return userId;
    try {
      final res = await AuthApiService.profile();
      if (res['success'] == true) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : res;
        final user = data['user'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['user'] as Map)
            : null;
        final id = data['_id']?.toString() ??
            data['id']?.toString() ??
            data['userId']?.toString() ??
            user?['_id']?.toString() ??
            user?['id']?.toString() ??
            user?['userId']?.toString();
        if (id != null && id.isNotEmpty) {
          userId = id;
          return userId;
        }
      }
    } catch (_) {}
    return null;
  }

  void _openRazorpayCheckout() {
    if (razorpayOrder == null) {
      topupError = 'Razorpay order not created.';
      update();
      return;
    }

    final orderId = razorpayOrder!['orderId']?.toString();
    final keyId = razorpayOrder!['keyId']?.toString();
    final amount = _normalizePaise(razorpayOrder!['amount']);
    final currency = razorpayOrder!['currency']?.toString() ?? 'INR';

    if (orderId == null || keyId == null || amount == null) {
      topupError = 'Razorpay order details are incomplete.';
      update();
      return;
    }

    var options = {
      'key': keyId,
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'name': 'Nirvista ICO',
      'description': 'Add Money to Wallet',
      'prefill': {
        'contact': '', // Can be filled from user profile if available
        'email': '', // Can be filled from user profile if available
      },
      'theme': {
        'color': '#4CAF50',
      },
    };

    try {
      if (kIsWeb) {
        if (!RazorpayBridge.isSupported) {
          topupError = 'Razorpay SDK not available on the page.';
          update();
          return;
        }
        RazorpayBridge.openCheckout(
          options: options,
          onSuccess: _handleRazorpayWebSuccess,
          onDismiss: () {
            topupError = 'Payment cancelled.';
            update();
            _navigateToTransactionsAfterFailure();
          },
          onError: (error) {
            final message = error['description'] ??
                error['message'] ??
                'Payment failed. Please try again.';
            topupError = message.toString();
            update();
            _navigateToTransactionsAfterFailure();
          },
        );
        return;
      }
      _razorpay.open(options);
    } catch (e) {
      topupError = 'Error opening Razorpay: ${e.toString()}';
      update();
    }
  }

  Future<bool?> _openPayUPaymentWindow(PayUSession session) async {
    try {
      return await Get.to<bool>(
        () => PayUPaymentWebView(session: session),
        fullscreenDialog: true,
      );
    } catch (e) {
      topupError = 'Could not open PayU payment window. ${e.toString()}';
      update();
      return null;
    }
  }

  Map<String, dynamic>? _findPayUSessionMap(
      dynamic source, Map<String, dynamic> Function(dynamic) asMap) {
    final candidate = asMap(source);
    if (candidate.isNotEmpty && candidate.containsKey('endpoint')) {
      return candidate;
    }

    for (final value in candidate.values) {
      final found = _findPayUSessionMap(value, asMap);
      if (found != null) {
        return found;
      }
    }

    if (source is Iterable) {
      for (final item in source) {
        final found = _findPayUSessionMap(item, asMap);
        if (found != null) {
          return found;
        }
      }
    }

    return null;
  }

  void _handleRazorpayWebSuccess(Map<String, dynamic> response) async {
    final paymentId = response['razorpay_payment_id']?.toString();
    final orderId = response['razorpay_order_id']?.toString() ??
        razorpayOrder?['orderId']?.toString();
    final signature = response['razorpay_signature']?.toString();
    final transactionId = topupTransactionId;

    if (paymentId == null ||
        paymentId.isEmpty ||
        signature == null ||
        signature.isEmpty ||
        orderId == null ||
        orderId.isEmpty) {
      topupError =
          'Payment verification data missing. Please try the payment again.';
      update();
      return;
    }

    if (transactionId == null || transactionId.isEmpty) {
      topupError =
          'Payment session expired. Please initiate Razorpay top-up again.';
      update();
      return;
    }

    isVerifyLoading = true;
    topupSuccess = 'Verifying payment...';
    update();

    try {
      final verifyResponse = await AuthApiService.verifyRazorpayPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        transactionId: transactionId,
      );

      if (verifyResponse['success'] == true) {
        await _handleRazorpayVerificationSuccess(auto: true);
      } else {
        topupError = verifyResponse['message']?.toString() ??
            'Payment verification failed';
        _navigateToTransactionsAfterFailure();
      }
    } catch (e) {
      topupError = 'Verification error: ${e.toString()}';
      _navigateToTransactionsAfterFailure();
    } finally {
      isVerifyLoading = false;
      update();
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Payment Success: ${response.paymentId}');

    final orderId = razorpayOrder?['orderId']?.toString();
    final transactionId = topupTransactionId;

    if (orderId == null || transactionId == null) {
      topupError = 'Payment session expired. Please contact support.';
      update();
      return;
    }

    // Show loading
    isVerifyLoading = true;
    topupSuccess = 'Verifying payment...';
    update();

    try {
      final verifyResponse = await AuthApiService.verifyRazorpayPayment(
        orderId: orderId,
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        transactionId: transactionId,
      );

      if (verifyResponse['success'] == true) {
        await _handleRazorpayVerificationSuccess(auto: true);
      } else {
        topupError = verifyResponse['message']?.toString() ??
            'Payment verification failed';
        _navigateToTransactionsAfterFailure();
      }
    } catch (e) {
      topupError = 'Verification error: ${e.toString()}';
      _navigateToTransactionsAfterFailure();
    } finally {
      isVerifyLoading = false;
      update();
    }
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    debugPrint(
        'Razorpay Payment Error: ${response.code} - ${response.message}');
    topupError = 'Payment failed: ${response.message ?? 'Unknown error'}';
    update();
    _navigateToTransactionsAfterFailure();
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay External Wallet: ${response.walletName}');
    topupError =
        'External wallet selected: ${response.walletName}. Please complete payment.';
    update();
  }

  Future<void> verifyRazorpayPayment({bool auto = false}) async {
    verifyError = null;
    verifySuccess = null;
    final orderId = razorpayOrder?['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) {
      verifyError =
          'Payment session expired. Please initiate Razorpay top-up again.';
      update();
      return;
    }
    final transactionId = topupTransactionId;
    if (transactionId == null || transactionId.isEmpty) {
      verifyError = 'Transaction ID missing. Initiate Razorpay top-up again.';
      update();
      return;
    }
    final paymentId = razorpayPaymentIdController.text.trim();
    final signature = razorpaySignatureController.text.trim();
    if (paymentId.isEmpty || signature.isEmpty) {
      verifyError =
          'We could not read the Razorpay confirmation. Please retry the payment.';
      update();
      return;
    }
    isVerifyLoading = true;
    update();
    try {
      final response = await AuthApiService.verifyRazorpayPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        transactionId: transactionId,
      );
      if (response['success'] == true) {
        await _handleRazorpayVerificationSuccess(auto: auto);
      } else {
        verifyError = response['message']?.toString() ?? 'Verification failed.';
      }
    } catch (_) {
      verifyError = 'Verification failed.';
    } finally {
      isVerifyLoading = false;
      update();
    }
  }

  Future<void> _handleRazorpayVerificationSuccess({required bool auto}) async {
    verifySuccess =
        auto ? 'Payment verified automatically.' : 'Payment verified.';
    topupSuccess = 'Payment verified. Redirecting to transactions...';
    update();
    await _navigateToTransactionsAfterVerification();
  }

  Future<void> _navigateToTransactionsAfterVerification() async {
    final message = verifySuccess ??
        topupSuccess ??
        'Payment completed. Redirecting to dashboard...';
    await _handlePaymentResult(success: true, message: message);
  }

  Future<void> _navigateToTransactionsAfterFailure({String? message}) async {
    final failureMessage = message ??
        topupError ??
        'Payment failed. Please try again from the Add Money page.';
    await _handlePaymentResult(success: false, message: failureMessage);
  }

  Future<void> _handlePaymentResult({
    required bool success,
    required String message,
  }) async {
    await _closeActiveDialog();
    if (success) {
      await _refreshWalletSummary();
      resetTopupState(keepAmount: false);
      await _navigateToDashboardAfterPayment();
    } else {
      resetTopupState(keepAmount: true);
      await _navigateToAddMoneyAfterFailure();
    }
    await _showPaymentResultDialog(success: success, message: message);
  }

  Future<void> _closeActiveDialog() async {
    void safeClose() {
      try {
        Get.back();
      } catch (_) {}
    }

    if (_topupOverlayContext != null) {
      try {
        Navigator.of(_topupOverlayContext!).pop();
      } catch (_) {}
      _topupOverlayContext = null;
    }

    if (Get.isDialogOpen == true) {
      safeClose();
    }
    if (Get.isBottomSheetOpen == true) {
      safeClose();
    }
  }

  Future<void> _showPaymentResultDialog({
    required bool success,
    required String message,
  }) async {
    final color = success ? Colors.green : Colors.red;
    final icon = success ? Icons.check_circle_outline : Icons.error_outline;
    final title = success ? 'Payment successful' : 'Payment failed';
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: color),
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: success,
    );
  }

  Future<void> _navigateToDashboardAfterPayment() async {
    try {
      if (Get.isRegistered<DrawerControllerr>()) {
        final drawer = Get.find<DrawerControllerr>();
        drawer.function(value: -1);
        drawer.colorSelecter(value: 0);
      }
    } catch (_) {}
    if (Get.currentRoute != '/dashboard') {
      await Get.offAllNamed('/dashboard');
    }
  }

  Future<void> _navigateToAddMoneyAfterFailure() async {
    try {
      if (Get.isRegistered<DrawerControllerr>()) {
        final drawer = Get.find<DrawerControllerr>();
        drawer.function(value: -1);
        drawer.colorSelecter(value: 3);
      }
    } catch (_) {}
    if (Get.currentRoute != '/myWallets') {
      await Get.offAllNamed('/myWallets');
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    swapAmountController.dispose();
    razorpayPaymentIdController.dispose();
    razorpaySignatureController.dispose();
    _phonePePoller?.cancel();
    if (!kIsWeb) {
      _razorpay.clear();
    }
    super.onClose();
  }

  Future<void> _refreshWalletSummary() async {
    try {
      if (Get.isRegistered<DashBordeController>()) {
        final dashboard = Get.find<DashBordeController>();
        await dashboard.fetchWalletSummary();
        await dashboard.fetchTransactions();
      } else {
        await AuthApiService.getWalletSummary();
      }
    } catch (_) {}
  }

  double? _parseSwapAmount() {
    final raw = swapAmountController.text.trim();
    if (raw.isEmpty) return null;
    final cleaned = raw.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  Future<void> swapTokens() async {
    swapError = null;
    swapSuccess = null;
    final amount = _parseSwapAmount();
    if (amount == null || amount <= 0) {
      swapError = 'Enter a valid token amount.';
      update();
      return;
    }
    isSwapLoading = true;
    update();
    try {
      final res = await AuthApiService.swapTokens(tokenAmount: amount);
      if (res['success'] == true) {
        swapSuccess = res['message']?.toString() ?? 'Swap completed.';
      } else {
        swapError = res['message']?.toString() ?? 'Swap failed.';
      }
    } catch (_) {
      swapError = 'Swap failed.';
    } finally {
      isSwapLoading = false;
      update();
    }
  }
}
