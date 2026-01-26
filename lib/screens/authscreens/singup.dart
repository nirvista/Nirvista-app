// ignore_for_file: deprecated_member_use
//import 'package:nirvista/screens/authscreens/singin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../CommonWidgets/applogo.dart';
import '../../CommonWidgets/bottombar.dart';
//import '../../CommonWidgets/comuntextfilde.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/singupcontroller.dart';
import 'signup_otp_screen.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({super.key});

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  ColorNotifire notifire = ColorNotifire();
  SingUpController singUpController = Get.put(SingUpController());
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return DefaultTabController(
      length: 1,
      initialIndex: 0,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire.getBgColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Scaffold(
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
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildui(),
                                ),
                                Expanded(
                                    child: _buildSingupUi(
                                        width: constraints.maxWidth)),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Speady, Easy and Fast".tr,
                        style: Typographyy.heading2
                            .copyWith(color: containerColor)),
                    Text(
                      'Nirvista helps you set saving goals, earn cashback rewards, and get paychecks up to two days early. Get a \$20 bonus when you receive qualifying direct deposits.'
                          .tr,
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
            const Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 24.0, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppLogo(size: 64),
                ],
              ),
            ),
            Positioned(
                right: 0,
                left: 0,
                bottom: 300,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: Image.asset(
                      "assets/images/hero-1-img 2.png",
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

  bool isChecked = false;

  Widget _buildSingupUi({required double width}) {
    return GetBuilder<SingUpController>(builder: (singUpController) {
      return Container(
        color: notifire.getBgColor,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width < 600
                        ? 0
                        : width < 1200
                            ? 30
                            : 100),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      width < 600
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: width < 600
                                      ? 0
                                      : width < 1200
                                          ? 15
                                          : 24.0),
                              child: const AppLogo(),
                            )
                          : const SizedBox(),
                      SizedBox(
                        height: width < 600 ? 40 : 148,
                      ),
                      Text("Sign up for an account".tr,
                          style: Typographyy.heading3
                              .copyWith(color: notifire.getTextColor)),
                      SizedBox(
                        height: width < 600 ? 10 : 16,
                      ),
                      Text(
                        "Send, spend and save smarter".tr,
                        style: Typographyy.bodyLargeRegular
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                      SizedBox(
                        height: width < 600 ? 20 : 40,
                      ),
                      width < 600
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 24,
                            ),
                      const SizedBox(
                        height: 24,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "name",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: singUpController.name),
                            onChanged: (value) =>
                                singUpController.name = value,
                            decoration: InputDecoration(
                              hintText: "Full name",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: notifire.getGry700_300Color)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: notifire.getGry700_300Color)),
                              hintStyle: Typographyy.bodyLargeRegular
                                  .copyWith(color: notifire.getGry600_500Color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "referral code (optional)",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: singUpController.referralCode),
                            onChanged: (value) =>
                                singUpController.referralCode = value,
                            decoration: InputDecoration(
                              hintText: "Referral code",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: notifire.getGry700_300Color)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: notifire.getGry700_300Color)),
                              hintStyle: Typographyy.bodyLargeRegular
                                  .copyWith(color: notifire.getGry600_500Color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "mobile no.",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: singUpController.mobile),
                            onChanged: (value) =>
                                singUpController.mobile = value,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "mobile no.",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color:
                                          notifire.getGry700_300Color)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color:
                                          notifire.getGry700_300Color)),
                              hintStyle: Typographyy.bodyLargeRegular
                                  .copyWith(
                                      color: notifire.getGry600_500Color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "By creating an account, you agreeing to our"
                                        .tr,
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color)),
                            TextSpan(
                                text: " Privacy Policy, ".tr,
                                style: Typographyy.bodyMediumSemiBold
                                    .copyWith(color: notifire.getWhitAndBlack)),
                            TextSpan(
                                text: "and ".tr,
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color)),
                            TextSpan(
                                text: "Electronics Communication Policy.".tr,
                                style: Typographyy.bodyMediumSemiBold
                                    .copyWith(color: notifire.getWhitAndBlack)),
                          ])),
                      const SizedBox(
                        height: 32,
                      ),
                      ElevatedButton(
                        onPressed: singUpController.isLoading
                            ? null
                          : () async {
                              final sent = await singUpController.sendOtp();
                              if (sent) {
                                Get.snackbar(
                                  'OTP Sent',
                                  'Enter the code we sent to ${singUpController.fullMobile}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                );
                                Get.to(() => const SignupOtpScreen());
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          fixedSize: const Size.fromHeight(56),
                        ),
                        child: Center(
                            child: singUpController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    "Send OTP".tr,
                                    style: Typographyy.bodyLargeSemiBold
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                  )),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (singUpController.errorMessage != null)
                        Text(
                          singUpController.errorMessage!,
                          style: Typographyy.bodyMediumMedium
                              .copyWith(color: Colors.red),
                        ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?".tr,
                              style: Typographyy.bodyLargeMedium
                                  .copyWith(color: notifire.getWhitAndBlack)),
                          InkWell(
                              onTap: () {
                                Get.offAllNamed("/signin");
                              },
                              child: Text(" Sign In".tr,
                                  style: Typographyy.bodyLargeExtraBold
                                      .copyWith(
                                          color: notifire.getWhitAndBlack)))
                        ],
                      ),
                    ]),
              ),
              SizedBox(
                height: width < 600 ? 0 : 80,
              ),
              width < 600
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Privacy Policy".tr,
                            style: Typographyy.bodyLargeSemiBold
                                .copyWith(color: notifire.getGry600_500Color)),
                        Text("Copyright 2023".tr,
                            style: Typographyy.bodyLargeSemiBold
                                .copyWith(color: notifire.getGry600_500Color)),
                      ],
                    )
            ],
          ),
        ),
        // color: Colors.deepPurple,
      );
    });
  }
}
