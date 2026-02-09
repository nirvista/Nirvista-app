import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static const _walletSummaryKey = 'wallet_summary';

  static Future<void> saveWalletSummary(
      Map<String, dynamic> walletSummary) async {
    if (walletSummary.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(walletSummary);
    await prefs.setString(_walletSummaryKey, encoded);
  }

  static Future<Map<String, dynamic>?> getWalletSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_walletSummaryKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Ignore invalid cache contents.
    }
    return null;
  }

  static const _icoStagesCacheKey = 'ico_stages_cache';
  static const _transactionsCacheKey = 'transactions_cache';

  static Future<void> saveIcoStages({
    required List<Map<String, dynamic>> stages,
    String? activeStageKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'stages': stages,
      'activeStageKey': activeStageKey,
      'fetchedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_icoStagesCacheKey, jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> getCachedIcoStages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_icoStagesCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Ignore corrupted cache.
    }
    return null;
  }

  static Future<void> saveTransactions(
      List<Map<String, dynamic>> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    if (transactions.isEmpty) {
      await prefs.remove(_transactionsCacheKey);
      return;
    }
    final payload = <String, dynamic>{
      'transactions': transactions,
      'fetchedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_transactionsCacheKey, jsonEncode(payload));
  }

  static Future<Map<String, dynamic>?> getCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_transactionsCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Ignore invalid cache.
    }
    return null;
  }
}
