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

class SignupPinScreen extends StatefulWidget {
  const SignupPinScreen({super.key});

  @override
  State<SignupPinScreen> createState() => _SignupPinScreenState();
}

class _SignupPinScreenState extends State<SignupPinScreen> {
  final SingUpController controller = Get.isRegistered<SingUpController>()
      ? Get.find<SingUpController>()
      : Get.put(SingUpController());
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  ColorNotifire notifire = ColorNotifire();

  @override
  void initState() {
    super.initState();
    _pinController.text = controller.pin;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!controller.isOtpVerified) {
        if (controller.userId != null && controller.userId!.isNotEmpty) {
          Get.offAllNamed("/signup/otp");
        } else {
          Get.offAllNamed("/signup");
        }
        return;
      }
      _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    controller.pin = _pinController.text.trim();
    final ok = await controller.setupPin();
    if (ok && mounted) {
      Get.snackbar(
        'PIN setup successful',
        'Finish your signup by completing KYC.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Get.offAllNamed("/ekyc");
      }
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
                              "Set your PIN".tr,
                              style: Typographyy.heading3
                                  .copyWith(color: notifire.getWhitAndBlack),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Create a 4-6 digit PIN to secure your account".tr,
                              style: Typographyy.bodyLargeMedium.copyWith(
                                  color: notifire.getGry500_600Color),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: _pinController,
                              focusNode: _pinFocus,
                              autofocus: true,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              obscureText: state.isTextisHide,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: Typographyy.heading4
                                  .copyWith(color: notifire.getWhitAndBlack),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '----',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.setTextIsTrue(
                                        !controller.isTextisHide);
                                  },
                                  icon: Icon(
                                    state.isTextisHide
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: greyscale600,
                                  ),
                                ),
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
                              onSubmitted: (_) => _savePin(),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed:
                                  state.isLoading ? null : () async => _savePin(),
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
                                        "Continue".tr,
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
