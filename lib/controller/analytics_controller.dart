import 'package:get/get.dart';
import '../services/auth_api_service.dart';

class AnalyticsController extends GetxController implements GetxService {
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? analytics;


  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    isLoading = true;
    error = null;
    update();
    try {
      final res = await AuthApiService.getWalletAnalytics();
      if (res['success'] == true || res['wallets'] != null) {
        analytics = res['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(res['data'])
            : Map<String, dynamic>.from(res);
      } else {
        error = res['message']?.toString() ?? 'Failed to load analytics.';
        analytics = null;
      }
    } catch (_) {
      error = 'Failed to load analytics.';
      analytics = null;
    } finally {
      isLoading = false;
      update();
    }
  }
}
