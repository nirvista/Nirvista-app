import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../CommonWidgets/bottombar.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/singincontroller.dart';
//import 'forgotpassword.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  ColorNotifire notifire = ColorNotifire();
  final SingInController controller = Get.isRegistered<SingInController>()
      ? Get.find<SingInController>()
      : Get.put(SingInController());
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.otpController = _otpController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < 600
            ? constraints.maxWidth - 32
            : 510.0;
        return Scaffold(
          bottomNavigationBar: const BottomBarr(),
          backgroundColor: notifire.getBgColor,
          appBar: null,
          body: GetBuilder<SingInController>(
            init: controller,
            builder: (controller) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentWidth,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: notifire.getContainerColor,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              "Verify Your Mobile Number".tr,
                              style: Typographyy.heading3
                                  .copyWith(color: notifire.getWhitAndBlack),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "A code has been sent to verify your registered mobile number."
                                  .tr,
                              style: Typographyy.bodyLargeMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              controller.fullPhone,
                              style: Typographyy.bodyLargeMedium
                                  .copyWith(color: notifire.getWhitAndBlack),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _otpController,
                              focusNode: _otpFocus,
                              autofocus: true,
                              maxLength: 6,
                              obscureText: false,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              style: Typographyy.heading4
                                  .copyWith(color: notifire.getWhitAndBlack),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Enter 6-digit code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: notifire.getBorderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: notifire.getBorderColor),
                                ),
                              ),
                              onChanged: (value) async {
                                controller.otp = value;
                                if (value.length == 6 && !controller.isLoading) {
                                  final ok = await controller.verifyLoginOtp();
                                  if (ok && mounted) {
                                    Get.offAllNamed("/dashboard");
                                  }
                                }
                              },
                              onSubmitted: (_) async {
                                if (_otpController.text.length == 6 &&
                                    !controller.isLoading) {
                                  final ok = await controller.verifyLoginOtp();
                                  if (ok && mounted) {
                                    Get.offAllNamed("/dashboard");
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () async {
                                      final verified =
                                          await controller.verifyLoginOtp();
                                      if (verified) {
                                        Get.offAllNamed("/dashboard");
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: priMeryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fixedSize: const Size.fromHeight(56),
                              ),
                              child: Center(
                                child: controller.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "Verify & Continue".tr,
                                        style: Typographyy.bodyLargeSemiBold
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (controller.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  controller.errorMessage!,
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            TextButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : () async {
                                      await controller.sendLoginOtp();
                                    },
                              child: Text(
                                "Resend OTP".tr,
                                style: Typographyy.bodyMediumSemiBold
                                    .copyWith(color: priMeryColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
