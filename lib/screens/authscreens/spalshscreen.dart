import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage.dart';
import '../../services/auth_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await Storage.getToken();
      if (token != null && token.isNotEmpty) {
        AuthApiService.authToken = token;
        if (mounted) {
          Get.offAllNamed("/dashboard");
        }
        return;
      }
    } catch (_) {
      // ignore and fall through to signin
    }
    if (mounted) {
      Get.offAllNamed("/signin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
