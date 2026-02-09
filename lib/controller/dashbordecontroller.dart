import 'dart:core';
import 'package:get/get.dart';

import '../core/storage.dart';
import '../services/auth_api_service.dart';

class _StageDateOverride {
  final RegExp match;
  final String start;
  final String end;
  final bool forceInactive;

  const _StageDateOverride(
    this.match,
    this.start,
    this.end, {
    this.forceInactive = false,
  });
}

final List<_StageDateOverride> _stageDateOverrides = [
  _StageDateOverride(
    RegExp(r'pre[- ]?ico', caseSensitive: false),
    '2026-02-01T00:00:00Z',
    '2026-04-30T23:59:59Z',
  ),
  _StageDateOverride(
    RegExp(r'\bico\b', caseSensitive: false),
    '2026-05-01T00:00:00Z',
    '2026-08-01T23:59:59Z',
    forceInactive: true,
  ),
];

class DashBordeController extends GetxController implements GetxService {
  int iteamcount = 4;
  int coinselecter = 0;
  int coinselecter1 = 2;

  bool istextishide = true;
  bool ismenuopen = false;
  bool ismenuopen1 = false;
  bool isStageLoading = false;
  String? stageError;
  List<Map<String, dynamic>> stages = [];
  String? activeStageKey;
  bool isWalletLoading = false;
  String? walletError;
  double? mainWalletBalance;
  String mainWalletCurrency = 'INR';
  double? tokenWalletBalance;
  String tokenSymbol = 'NVT';
  double? referralWalletBalance;
  List<Map<String, dynamic>> allTransactions = [];
  bool isTransactionsLoading = false;
  String? transactionsError;
  List<Map<String, dynamic>> recentTransactions = [];

  @override
  void onInit() {
    super.onInit();
    _loadCachedWalletSummary();
    fetchIcoStages();
    fetchWalletSummary();
    fetchTransactions();
  }


  setistextishide(bool value){
    istextishide = value;
    update();
  }

  ismenu(bool value){
  ismenuopen = value;
  update();
}
  ismenu1(bool value){
    ismenuopen1 = value;
    update();
  }

  selectcoin(int value){
    coinselecter = value;
    update();
  }

  selectcoin1(int value){
    coinselecter1 = value;
    update();
  }

  setiteamcount(int value){
    iteamcount = value;
    update();
  }

  Future<void> _loadCachedWalletSummary() async {
    try {
      final cached = await Storage.getWalletSummary();
      if (cached == null) {
        return;
      }
      final wallet = _mapFromDynamic(cached['wallet']);
      final referral = _mapFromDynamic(cached['referral']);
      final tokenWallet = _mapFromDynamic(cached['tokenWallet']);
      if (wallet == null && referral == null && tokenWallet == null) {
        return;
      }
      _applyWalletCache(
          wallet: wallet, referral: referral, tokenWallet: tokenWallet);
      update();
    } catch (_) {
      // Ignore caching errors and rely on live data.
    }
  }

  Future<void> fetchIcoStages({bool force = false}) async {
    isStageLoading = true;
    stageError = null;
    update();

    try {
      final response = await AuthApiService.getIcoStages();
      if (response['success'] == true) {
        Map<String, dynamic>? data;
        if (response['data'] is Map<String, dynamic>) {
          data = response['data'] as Map<String, dynamic>;
        } else if (response['stages'] != null) {
          data = response;
        }

        if (data != null) {
          final stagesList = data['stages'];
          final activeStage = data['activeStage'];
          stages = stagesList is List
              ? stagesList
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : [];
          if (stages.isNotEmpty) {
            _applyStageDateOverrides(stages);
          }
          activeStageKey = activeStage is Map<String, dynamic>
              ? activeStage['key']?.toString()
              : null;
        } else {
          stageError = 'Failed to load ICO stages.';
          stages = [];
        }
      } else {
        stageError =
            response['message']?.toString() ?? 'Failed to load ICO stages.';
        stages = [];
      }
    } catch (_) {
      stageError = 'Failed to load ICO stages.';
      stages = [];
    } finally {
      isStageLoading = false;
      update();
    }
  }

  Future<void> fetchWalletSummary() async {
    isWalletLoading = true;
    walletError = null;
    update();

    try {
      final response = await AuthApiService.getWalletSummary();
      if (response['success'] == true) {
        Map<String, dynamic>? data;
        if (response['data'] is Map<String, dynamic>) {
          data = response['data'] as Map<String, dynamic>;
        } else if (response['wallet'] != null ||
            response['tokenWallet'] != null ||
            response['referral'] != null) {
          data = response;
        }

        if (data != null) {
          final wallet = _mapFromDynamic(data['wallet']);
          final referral = _mapFromDynamic(data['referral']);
          final tokenWallet = _mapFromDynamic(data['tokenWallet']);

          _applyWalletCache(
            wallet: wallet,
            referral: referral,
            tokenWallet: tokenWallet,
          );

          final cachePayload = <String, dynamic>{};
          if (wallet != null) {
            cachePayload['wallet'] = wallet;
          }
          if (referral != null) {
            cachePayload['referral'] = referral;
          }
          if (tokenWallet != null) {
            cachePayload['tokenWallet'] = tokenWallet;
          }

          if (cachePayload.isNotEmpty) {
            try {
              await Storage.saveWalletSummary(cachePayload);
            } catch (_) {
              // ignore cache failures
            }
          }
        } else {
          walletError = 'Failed to load wallet summary.';
        }
      } else {
        walletError =
            response['message']?.toString() ?? 'Failed to load wallet summary.';
      }
    } catch (_) {
      walletError = 'Failed to load wallet summary.';
    } finally {
      isWalletLoading = false;
      update();
    }
  }

  Map<String, dynamic> _normalizeWalletTx(Map<String, dynamic> tx) {
    return {
      '_id': tx['_id']?.toString() ?? tx['id']?.toString(),
      'type': tx['type']?.toString(),
      'createdAt': tx['createdAt']?.toString(),
      'status': tx['status']?.toString(),
      'amount': (tx['amount'] as num?)?.toDouble(),
      'currency': tx['currency']?.toString() ?? 'INR',
      'category': tx['category']?.toString() ?? 'wallet',
      'description': tx['description']?.toString(),
      'paymentGateway': tx['paymentGateway']?.toString(),
      'metadata': tx['metadata'],
      'merchantTransactionId': tx['merchantTransactionId']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeIcoTx(Map<String, dynamic> tx) {
    final metadata = <String, dynamic>{};
    if (tx['tokenAmount'] != null) {
      metadata['tokenAmount'] = tx['tokenAmount'];
    }
    if (tx['tokenSymbol'] != null) {
      metadata['tokenSymbol'] = tx['tokenSymbol'];
    }
    return {
      '_id': tx['_id']?.toString() ?? tx['id']?.toString(),
      'type': tx['type']?.toString() ?? 'debit',
      'createdAt': tx['createdAt']?.toString(),
      'status': tx['status']?.toString(),
      'amount': (tx['fiatAmount'] ?? tx['amount']) is num
          ? (tx['fiatAmount'] ?? tx['amount'] as num).toDouble()
          : null,
      'currency': tx['currency']?.toString() ??
          tx['fiatCurrency']?.toString() ??
          'INR',
      'category': 'purchase',
      'description': tx['description']?.toString(),
      'paymentGateway': tx['paymentGateway']?.toString(),
      'metadata': metadata.isEmpty ? null : metadata,
      'merchantTransactionId': tx['merchantTransactionId']?.toString(),
    };
  }

  List<Map<String, dynamic>> _sortedCombined(
      List<Map<String, dynamic>> walletTx,
      List<Map<String, dynamic>> icoTx) {
    final combined = <Map<String, dynamic>>[
      ...walletTx.map((e) => _normalizeWalletTx(e)),
      ...icoTx.map((e) => _normalizeIcoTx(e)),
    ];
    combined.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return combined;
  }

  Future<void> fetchTransactions({bool force = false}) async {
    isTransactionsLoading = true;
    transactionsError = null;
    update();

    try {
      final walletRes = await AuthApiService.getWalletTransactions();
      final icoRes = await AuthApiService.getIcoTransactions();

      final walletList = (walletRes['data']?['transactions'] ??
              walletRes['transactions'] ??
              walletRes['data']) is List
          ? List<Map<String, dynamic>>.from(
              (walletRes['data']?['transactions'] ??
                      walletRes['transactions'] ??
                      walletRes['data'])
                  .whereType<Map>())
          : <Map<String, dynamic>>[];

      final icoList = (icoRes['data'] ?? icoRes['transactions'] ?? icoRes)
              is List
          ? List<Map<String, dynamic>>.from(
              (icoRes['data'] ?? icoRes['transactions'] ?? icoRes)
                  .whereType<Map>())
          : <Map<String, dynamic>>[];

      final walletSuccess = walletRes['success'] != false;
      final icoSuccess = icoRes['success'] != false;

      final combined = _sortedCombined(walletList, icoList);
      allTransactions = combined;
      recentTransactions = combined.take(6).toList();

      if (combined.isEmpty && (!walletSuccess || !icoSuccess)) {
        transactionsError = walletRes['message']?.toString() ??
            icoRes['message']?.toString() ??
            'Failed to load transactions.';
      }
    } catch (_) {
      transactionsError = 'Failed to load transactions.';
      allTransactions = [];
      recentTransactions = [];
    } finally {
      isTransactionsLoading = false;
      update();
    }
  }

  void _applyStageDateOverrides(List<Map<String, dynamic>> stageList) {
    final nowUtc = DateTime.now().toUtc();
    for (final stage in stageList) {
      final label =
          (stage['label'] ?? stage['key'] ?? '').toString().toLowerCase();
      final override = _matchingStageOverride(label);
      if (override != null) {
        stage['startAt'] = override.start;
        stage['endAt'] = override.end;
      }
      _recalculateStageFlags(stage, nowUtc);
      if (override?.forceInactive == true) {
        stage['isActive'] = false;
        stage['isUpcoming'] = false;
        stage['isEnded'] = false;
        stage['status'] = 'inactive';
      }
    }
  }

  _StageDateOverride? _matchingStageOverride(String label) {
    for (final override in _stageDateOverrides) {
      if (override.match.hasMatch(label)) {
        return override;
      }
    }
    return null;
  }

  void _recalculateStageFlags(Map<String, dynamic> stage, DateTime nowUtc) {
    final start = DateTime.tryParse(stage['startAt']?.toString() ?? '');
    final end = DateTime.tryParse(stage['endAt']?.toString() ?? '');
    var isActive = false;
    var isUpcoming = false;
    var isEnded = false;

    if (start != null && end != null) {
      if (nowUtc.isBefore(start)) {
        isUpcoming = true;
      } else if (nowUtc.isAfter(end)) {
        isEnded = true;
      } else {
        isActive = true;
      }
    } else if (start != null) {
      if (nowUtc.isBefore(start)) {
        isUpcoming = true;
      } else {
        isActive = true;
      }
    } else if (end != null) {
      if (nowUtc.isAfter(end)) {
        isEnded = true;
      }
    }

    stage['isActive'] = isActive;
    stage['isUpcoming'] = isUpcoming;
    stage['isEnded'] = isEnded;

    if (stage['status'] == null || stage['status'].toString().isEmpty) {
      stage['status'] = isActive
          ? 'active'
          : isUpcoming
              ? 'upcoming'
              : isEnded
                  ? 'ended'
                  : '';
    }
  }

  void _applyWalletCache({
    Map<String, dynamic>? wallet,
    Map<String, dynamic>? referral,
    Map<String, dynamic>? tokenWallet,
  }) {
    if (wallet != null) {
      final balance = wallet['balance'] as num?;
      if (balance != null) {
        mainWalletBalance = balance.toDouble();
      }
      final currency = wallet['currency']?.toString();
      if (currency != null && currency.isNotEmpty) {
        mainWalletCurrency = currency;
      }
    }

    if (referral != null) {
      final balance = referral['balance'] as num?;
      if (balance != null) {
        referralWalletBalance = balance.toDouble();
      }
    }

    if (tokenWallet != null) {
      final balance = tokenWallet['balance'] as num?;
      if (balance != null) {
        tokenWalletBalance = balance.toDouble();
      }
      final symbol = tokenWallet['tokenSymbol']?.toString();
      if (symbol != null && symbol.isNotEmpty) {
        tokenSymbol = symbol;
      }
    }
  }

  Map<String, dynamic>? _mapFromDynamic(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Provides a permanent dashboard controller so every screen shares the same data cache.
  static DashBordeController get shared {
    if (Get.isRegistered<DashBordeController>()) {
      return Get.find<DashBordeController>();
    }
    return Get.put(DashBordeController(), permanent: true);
  }

  List listOfCoin = [
    "assets/images/btc.png",
    "assets/images/eth.png",
    "assets/images/eth-1.png",
    "assets/images/trx.png",
  ];

  List coinsName = [
    "Btc",
    "Eth",
    "Pol",
    "Trx",

  ];

}
