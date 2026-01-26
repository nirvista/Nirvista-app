import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../CommonWidgets/applogo.dart';
import '../../CommonWidgets/bottombar.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/singupcontroller.dart';
import 'signup_pin_screen.dart';

class SignupOtpScreen extends StatefulWidget {
  const SignupOtpScreen({super.key});

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final SingUpController controller = Get.isRegistered<SingUpController>()
      ? Get.find<SingUpController>()
      : Get.put(SingUpController());
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  ColorNotifire notifire = ColorNotifire();

  @override
  void initState() {
    super.initState();
    _otpController.text = controller.otp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.userId == null || controller.userId!.isEmpty) {
        Get.offAllNamed("/signup");
        return;
      }
      _otpFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    controller.otp = _otpController.text.trim();
    final ok = await controller.verifyOtp();
    if (ok && mounted) {
      Get.to(() => const SignupPinScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: notifire.getBgColor,
          bottomNavigationBar: const BottomBarr(),
          appBar: constraints.maxWidth < 600
              ? appBar(isphone: true)
              : PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: appBar(isphone: false),
                ),
          body: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: GetBuilder<SingUpController>(
                    init: controller,
                    builder: (state) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: notifire.getContainerColor,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Verify your mobile".tr,
                              style: Typographyy.heading3
                                  .copyWith(color: notifire.getWhitAndBlack),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Enter the OTP sent to".tr,
                              style: Typographyy.bodyLargeMedium.copyWith(
                                  color: notifire.getGry500_600Color),
                            ),
                            Text(
                              state.fullMobile,
                              style: Typographyy.bodyLargeMedium
                                  .copyWith(color: notifire.getWhitAndBlack),
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: _otpController,
                              focusNode: _otpFocus,
                              autofocus: true,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              style: Typographyy.heading4
                                  .copyWith(color: notifire.getWhitAndBlack),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '------',
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
                              onChanged: (value) {
                                controller.otp = value;
                                if (value.length == 6 && !controller.isLoading) {
                                  _verifyOtp();
                                }
                              },
                              onSubmitted: (_) => _verifyOtp(),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed:
                                  state.isLoading ? null : () async => _verifyOtp(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: priMeryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                fixedSize: const Size.fromHeight(56),
                              ),
                              child: Center(
                                child: state.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "Verify OTP".tr,
                                        style: Typographyy.bodyLargeSemiBold
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  state.errorMessage!,
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            TextButton(
                              onPressed: state.isTimerRunning || state.isLoading
                                  ? null
                                  : () async {
                                      await controller.sendOtp();
                                    },
                              child: Text(
                                state.isTimerRunning
                                    ? "Resend in ${state.otpTimer}s"
                                    : "Resend code",
                                style: Typographyy.bodyMediumSemiBold
                                    .copyWith(color: priMeryColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget appBar({required bool isphone}) {
    return AppBar(
      toolbarHeight: isphone ? 52 : 120.0,
      automaticallyImplyLeading: false,
      backgroundColor: notifire.getAppBarColor,
      centerTitle: false,
      title: isphone
          ? const AppLogo(textColor: Colors.white, size: 80)
          : const AppLogo(textColor: Colors.white),
    );
  }
}
