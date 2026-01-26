import 'package:get/get.dart';
import '../services/auth_api_service.dart';

class StakingController extends GetxController implements GetxService {
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;
  String? actionMessage;
  double holdingBalance = 0;
  List<Map<String, dynamic>> stakes = [];

  @override
  void onInit() {
    super.onInit();
    fetchStakes();
  }

  Future<void> fetchStakes() async {
    isLoading = true;
    error = null;
    update();
    try {
      final res = await AuthApiService.listStakes(limit: 100);
      final data = res['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(res['data'])
          : Map<String, dynamic>.from(res);
      final holding = data['holding'];
      if (holding is Map<String, dynamic>) {
        holdingBalance = (holding['balance'] as num?)?.toDouble() ?? 0;
      }
      final list = data['stakes'] ?? data['data'] ?? data['list'] ?? [];
      if (list is List) {
        stakes = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (data['stake'] is Map<String, dynamic>) {
        stakes = [Map<String, dynamic>.from(data['stake'])];
      } else {
        stakes = [];
      }
    } catch (_) {
      error = 'Failed to load stakes.';
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> startStake(double tokenAmount) async {
    isSubmitting = true;
    actionMessage = null;
    error = null;
    update();
    try {
      final res = await AuthApiService.startStaking(tokenAmount: tokenAmount);
      if (res['success'] == true || res['stake'] != null) {
        actionMessage = res['message']?.toString() ?? 'Stake started.';
        if (res['holding'] is Map<String, dynamic>) {
          holdingBalance =
              (res['holding']['balance'] as num?)?.toDouble() ?? holdingBalance;
        }
        if (res['stake'] is Map<String, dynamic>) {
          final stakeMap = Map<String, dynamic>.from(res['stake']);
          stakes = [stakeMap];
        }
      } else {
        error = res['message']?.toString() ?? 'Failed to start stake.';
      }
      await fetchStakes();
    } catch (_) {
      error = 'Failed to start stake.';
    } finally {
      isSubmitting = false;
      update();
    }
  }

  Future<void> claim(String stakeId) async {
    isSubmitting = true;
    actionMessage = null;
    error = null;
    update();
    try {
      final res = await AuthApiService.claimStake(stakeId);
      if (res['success'] == true) {
        actionMessage = res['message']?.toString() ?? 'Stake claimed.';
      } else {
        error = res['message']?.toString() ?? 'Failed to claim.';
      }
      await fetchStakes();
    } catch (_) {
      error = 'Failed to claim.';
    } finally {
      isSubmitting = false;
      update();
    }
  }
}
