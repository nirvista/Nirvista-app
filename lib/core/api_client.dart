import 'dart:convert';
import 'package:nirvista/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'storage.dart';

class ApiClient {
  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final headers = {
      "Content-Type": "application/json",
      if (auth) "Authorization": "Bearer ${await Storage.getToken()}",
    };

    return http.post(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(
    String path, {
    bool auth = false,
  }) async {
    final headers = {
      if (auth) "Authorization": "Bearer ${await Storage.getToken()}",
    };

    return http.get(
      Uri.parse(ApiConstants.baseUrl + path),
      headers: headers,
    );
  }
}
