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
}
