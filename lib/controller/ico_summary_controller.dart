import 'package:get/get.dart';
import '../services/auth_api_service.dart';

class IcoSummaryController extends GetxController implements GetxService {
  bool isLoading = false;
  bool isBuying = false;
  String? error;
  String? buyError;
  String? buyMessage;
  Map<String, dynamic>? summary;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    isLoading = true;
    error = null;
    update();
    try {
      final res = await AuthApiService.getIcoSummary();
      if (res['success'] == true || res['tokenSymbol'] != null) {
        summary = res['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(res['data'])
            : Map<String, dynamic>.from(res);
      } else {
        error = res['message']?.toString() ?? 'Failed to load ICO summary.';
        summary = null;
      }
    } catch (e) {
      error = 'Failed to load ICO summary.';
      summary = null;
    } finally {
      isLoading = false;
      update();
    }
  }

  double? tokenPrice() {
    final price = summary?['price'];
    if (price is num) {
      return price.toDouble();
    }
    return null;
  }

  Future<void> buyTokens({double? tokenAmount, double? fiatAmount}) async {
    isBuying = true;
    buyError = null;
    buyMessage = null;
    update();
    try {
      final res = await AuthApiService.buyIcoTokens(
        tokenAmount: tokenAmount,
        fiatAmount: fiatAmount,
        useWallet: true,
        paymentMethod: 'wallet',
      );
      if (res['success'] == true) {
        buyMessage = res['message']?.toString() ?? 'Purchase completed.';
        await fetchSummary();
      } else {
        buyError = res['message']?.toString() ?? 'Failed to buy tokens.';
      }
    } catch (_) {
      buyError = 'Failed to buy tokens.';
    } finally {
      isBuying = false;
      update();
    }
  }
}
