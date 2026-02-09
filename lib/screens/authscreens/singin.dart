// ignore_for_file: deprecated_member_use

import 'package:nirvista/screens/authscreens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../CommonWidgets/applogo.dart';
import '../../CommonWidgets/bottombar.dart';
// import '../../CommonWidgets/comuntextfilde.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/singincontroller.dart';

class SingInScreen extends StatefulWidget {
  const SingInScreen({super.key});

  @override
  State<SingInScreen> createState() => _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen> {
  SingInController singInController = Get.put(SingInController());
  ColorNotifire notifire = ColorNotifire();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return DefaultTabController(
      length: 1,
      initialIndex: 0,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire.getBgColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: notifire.getBgColor,
                    bottomNavigationBar: const BottomBarr(),
                    body: SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSingupUi(
                                        width: constraints.maxWidth),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (constraints.maxWidth < 980) {
                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSingupUi(
                                      width: constraints.maxWidth),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSingupUi(
                                      width: constraints.maxWidth),
                                ),
                                Expanded(child: _buildui()),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildui() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              color: priMeryColor,
              height: 935,
              // color: Colors.deepPurple,

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Get better with money",
                        style: Typographyy.heading2
                            .copyWith(color: containerColor)),
                    Text(
                      'Nirvista helps you set saving goals, earn cashback rewards, and get paychecks up to two days early. Get a \$20 bonus when you receive qualifying direct deposits.',
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: colorWithOpacity(containerColor, 0.7)),
                      textAlign: TextAlign.center,
                    ),
                    const Flexible(
                        child: SizedBox(
                      height: 140,
                    )),
                  ],
                ),
              ),
            ),
            Positioned(
                right: 0,
                left: 0,
                bottom: 300,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: Image.asset(
                      "assets/images/hero-15-img 2.png",
                      height: 500,
                      width: 500,
                    ))),
            Positioned(
                right: 0,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/Group.svg",
                      height: 142,
                      width: 26,
                    ))),
            Positioned(
                bottom: 0,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/Vector.svg",
                      height: 81,
                      width: 81,
                    ))),
          ],
        ),
      ],
    );
  }

  Widget _buildSingupUi({required double width}) {
    return GetBuilder<SingInController>(builder: (controller) {
      return Container(
        color: notifire.getBgColor,
        height: width < 600 ? 820 : 945,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: width < 600
                        ? 0
                        : width < 1200
                            ? 15
                            : 24.0),
                child: const AppLogo(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width < 600
                        ? 10
                        : width < 1200
                            ? 30
                            : 100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: width < 600 ? 40 : 148,
                      ),
                      Text("Login into Nirvista ICO".tr,
                          style: Typographyy.heading3
                              .copyWith(color: notifire.getTextColor)),
                      const SizedBox(
                        height: 16,
                      ),
                       Text(
                         "Access Pre-ICO & ICO".tr,
                         style: Typographyy.bodyLargeRegular
                             .copyWith(color: notifire.getGry500_600Color),
                       ),
                      SizedBox(
                        height: width < 600 ? 20 : 40,
                      ),
                      width < 600
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                            )
                          : const SizedBox(
                              height: 24,
                            ),
                      // Phone Number Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                             "Make M Capital".tr,
                             style: Typographyy.bodyMediumMedium
                                 .copyWith(color: notifire.getGry500_600Color),
                           ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller.phoneController,
                            focusNode: _phoneFocus,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) => controller.phoneNumber = value,
                            onSubmitted: (_) async {
                              controller.phoneNumber =
                                  controller.phoneController.text.trim();
                              if (!controller.isLoading) {
                                final sent = await controller.sendLoginOtp();
                                if (sent && mounted) {
                                  Get.to(() => const OtpScreen());
                                }
                              }
                            },
                             decoration: InputDecoration(
                               // Using mobile number hint to keep the purpose clear.
                               hintText: "Enter mobile number".tr,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: notifire.getGry700_300Color)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: notifire.getGry700_300Color)),
                              hintStyle: Typographyy.bodyLargeRegular
                                  .copyWith(color: notifire.getGry600_500Color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: width < 600 ? 18 : 32,
                      ),
                          ElevatedButton(
                          onPressed: controller.isLoading ? null : () async {
                            controller.phoneNumber =
                                controller.phoneController.text.trim();
                            bool sent = await controller.sendLoginOtp();
                            if (sent) {
                              Get.to(() => const OtpScreen());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: priMeryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            fixedSize: const Size.fromHeight(56),
                          ),
                          child: Center(
                              child: controller.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      "Send OTP".tr,
                                      style: Typographyy.bodyLargeSemiBold.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    )),
                        ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (controller.errorMessage != null)
                        Text(
                          controller.errorMessage!,
                          style: Typographyy.bodyMediumMedium
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(
                        height: 32,
                      ),
                    ]),
              ),
            ],
          ),
        ),
        // color: Colors.deepPurple,
      );
    });
  }
}

Widget buildTextFilde(
    {required String hinttext, String? icon, required bool suffixIconisture}) {
  return SizedBox(
    height: 56,
    // width: 427,
    child: TextField(
      style:
          Typographyy.bodyLargeMedium.copyWith(color: notifire.getWhitAndBlack),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifire.getGry700_300Color)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifire.getGry700_300Color)),
        hintText: hinttext,
        hintStyle: Typographyy.bodyLargeRegular
            .copyWith(color: notifire.getGry600_500Color),
        suffixIcon: suffixIconisture
            ? SizedBox(
                width: 24,
                height: 24,
                child: Center(
                    child: SvgPicture.asset(
                  icon!,
                  height: 24,
                  width: 24,
                  color: greyscale600,
                )))
            : const SizedBox(),
      ),
    ),
  );
}
