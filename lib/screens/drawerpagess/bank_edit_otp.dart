import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';

class BankEditOtpPage extends StatefulWidget {
  const BankEditOtpPage({super.key});

  @override
  State<BankEditOtpPage> createState() => _BankEditOtpPageState();
}

class _BankEditOtpPageState extends State<BankEditOtpPage> {
  ColorNotifire notifire = ColorNotifire();
  final DrawerControllerr _drawerController = Get.put(DrawerControllerr());

  bool otpRequested = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpError;
  String? otpMessage;

  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _drawerController.colorSelecter(value: 19);
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    otpController.clear();
    setState(() {
      isOtpSending = true;
      otpError = null;
      otpMessage = null;
    });

    try {
      final response = await AuthApiService.initUserOtp(
        purpose: 'bank_add',
        channel: 'mobile',
      );
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          otpRequested = true;
          otpMessage = response['message']?.toString() ?? 'OTP sent.';
        });
      } else {
        setState(() {
          otpError = response['message']?.toString() ?? 'Failed to send OTP.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        otpError = 'Failed to send OTP.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isOtpSending = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        otpError = 'Enter a valid 6-digit OTP.';
      });
      return;
    }

    setState(() {
      isOtpVerifying = true;
      otpError = null;
      otpMessage = 'Verifying OTP...';
    });

    try {
      final response = await AuthApiService.verifyUserOtp(
        purpose: 'bank_add',
        otp: otp,
        channel: 'mobile',
      );
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          otpMessage = response['message']?.toString() ?? 'OTP verified.';
        });
        Navigator.pushNamed(context, '/bankEdit', arguments: {'otp': otp});
      } else {
        setState(() {
          otpError =
              response['message']?.toString() ?? 'OTP verification failed.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        otpError = 'Failed to verify OTP.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isOtpVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifire.getBgColor,
        appBar: AppBar(
          backgroundColor: notifire.getBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: notifire.getTextColor),
          title: Text(
            "Verify OTP",
            style: Typographyy.heading4.copyWith(color: notifire.getTextColor),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Request an OTP before editing your bank details.",
                style: Typographyy.bodyMediumMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!otpRequested) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOtpSending ? null : _requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: priMeryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            fixedSize: const Size.fromHeight(46),
                          ),
                          child: isOtpSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Request OTP",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: otpController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                        decoration: InputDecoration(
                          hintText: "Enter 6-digit OTP",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOtpVerifying ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: priMeryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            fixedSize: const Size.fromHeight(46),
                          ),
                          child: isOtpVerifying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Verify OTP",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isOtpSending ? null : _requestOtp,
                          style: TextButton.styleFrom(
                            foregroundColor: isOtpSending
                                ? notifire.getGry500_600Color
                                : priMeryColor,
                          ),
                          child: Text(
                            isOtpSending ? "Resending OTP..." : "Resend OTP",
                            style: Typographyy.bodyMediumMedium,
                          ),
                        ),
                      ),
                    ],
                    if (otpMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        otpMessage!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: priMeryColor),
                      ),
                    ],
                    if (otpError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        otpError!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
