// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import '../../CommonWidgets/applogo.dart';
// import '../../CommonWidgets/bottombar.dart';
// import '../../ConstData/colorfile.dart';
// import '../../ConstData/colorprovider.dart';
// import '../../ConstData/typography.dart';
// import '../../controller/forgotpincontroller.dart';

// class ForgotPinScreen extends StatefulWidget {
//   const ForgotPinScreen({super.key});

//   @override
//   State<ForgotPinScreen> createState() => _ForgotPinScreenState();
// }

// class _ForgotPinScreenState extends State<ForgotPinScreen> {
//   ColorNotifire notifire = ColorNotifire();
//   ForgotPinController forgotPinController = Get.put(ForgotPinController());
//   int currentStep = 0; // 0: Enter Mobile, 1: OTP, 2: New PIN

//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController newPinController = TextEditingController();
//   final TextEditingController confirmPinController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return DefaultTabController(
//       length: 1,
//       initialIndex: 0,
//       child: SafeArea(
//         child: Scaffold(
//           body: Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             color: notifire.getBgColor,
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth < 600) {
//                   return Scaffold(
//                     backgroundColor: notifire.getBgColor,
//                     bottomNavigationBar: const BottomBarr(),
//                     body: SizedBox(
//                       height: Get.height,
//                       width: Get.width,
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildForgotPinUi(
//                                         width: constraints.maxWidth),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (constraints.maxWidth < 980) {
//                   return SizedBox(
//                     height: Get.height,
//                     width: Get.width,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildForgotPinUi(
//                                       width: constraints.maxWidth),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   return SizedBox(
//                     height: Get.height,
//                     width: Get.width,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildui(),
//                                 ),
//                                 Expanded(
//                                     child: _buildForgotPinUi(
//                                         width: constraints.maxWidth)),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildui() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               color: priMeryColor,
//               height: 935,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 70),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text("Secure Your Account".tr,
//                         style: Typographyy.heading2
//                             .copyWith(color: containerColor)),
//                     Text(
//                       'Reset your PIN securely with OTP verification. Your account safety is our priority.'
//                           .tr,
//                       style: Typographyy.bodyMediumMedium
//                           .copyWith(color: containerColor.withOpacity(0.7)),
//                       textAlign: TextAlign.center,
//                     ),
//                     const Flexible(
//                         child: SizedBox(
//                       height: 140,
//                     )),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   SvgPicture.asset(
//                     "assets/images/finallogotext.svg",
//                     color: Colors.white,
//                   ),
//                   const SizedBox(
//                     width: 12,
//                   ),
//                   SvgPicture.asset("assets/images/finallogo.svg",
//                       height: 20, width: 30, color: Colors.white),
//                 ],
//               ),
//             ),
//             Positioned(
//                 right: 0,
//                 left: 0,
//                 bottom: 300,
//                 child: Container(
//                     margin: const EdgeInsets.all(12),
//                     child: Image.asset(
//                       "assets/images/hero-1-img 2.png",
//                       height: 500,
//                       width: 500,
//                     ))),
//             Positioned(
//                 right: 0,
//                 child: Container(
//                     margin: const EdgeInsets.all(12),
//                     child: SvgPicture.asset(
//                       "assets/images/Group.svg",
//                       height: 142,
//                       width: 26,
//                     ))),
//             Positioned(
//                 bottom: 0,
//                 child: Container(
//                     margin: const EdgeInsets.all(12),
//                     child: SvgPicture.asset(
//                       "assets/images/Vector.svg",
//                       height: 81,
//                       width: 81,
//                     ))),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildForgotPinUi({required double width}) {
//     return GetBuilder<ForgotPinController>(builder: (controller) {
//       return Container(
//         color: notifire.getBgColor,
//         height: 960,
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: width < 600
//                         ? 0
//                         : width < 1200
//                             ? 30
//                             : 100),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       width < 600
//                           ? Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: width < 600
//                                       ? 0
//                                       : width < 1200
//                                           ? 15
//                                           : 24.0),
//                               child: const AppLogo(),
//                             )
//                           : const SizedBox(),
//                       SizedBox(
//                         height: width < 600 ? 40 : 148,
//                       ),
//                       Text("Forgot PIN".tr,
//                           style: Typographyy.heading3
//                               .copyWith(color: notifire.getTextColor)),
//                       SizedBox(
//                         height: width < 600 ? 10 : 16,
//                       ),
//                       Text(
//                         "Reset your PIN to secure your account".tr,
//                         style: Typographyy.bodyLargeRegular
//                             .copyWith(color: notifire.getGry500_600Color),
//                       ),
//                       SizedBox(
//                         height: width < 600 ? 20 : 40,
//                       ),
//                       if (currentStep == 0) ...[
//                         // Step 1: Enter Mobile Number
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Enter your registered mobile number".tr,
//                               style: Typographyy.bodyMediumMedium
//                                   .copyWith(color: notifire.getGry500_600Color),
//                             ),
//                             const SizedBox(height: 10),
//                             TextField(
//                               controller: mobileController,
//                               keyboardType: TextInputType.phone,
//                               style: Typographyy.bodyLargeMedium
//                                   .copyWith(color: notifire.getWhitAndBlack),
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.all(16),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 hintText: "Mobile Number".tr,
//                                 hintStyle: Typographyy.bodyLargeRegular
//                                     .copyWith(
//                                         color: notifire.getGry600_500Color),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                             onPressed: () {
//                               if (mobileController.text.isNotEmpty) {
//                                 setState(() {
//                                   currentStep = 1;
//                                 });
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: priMeryColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               fixedSize: const Size.fromHeight(56),
//                             ),
//                             child: Center(
//                                 child: Text(
//                               "Send OTP".tr,
//                               style: Typographyy.bodyLargeSemiBold.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w400),
//                             ))),
//                       ] else if (currentStep == 1) ...[
//                         // Step 2: Enter OTP
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Enter the OTP sent to your mobile".tr,
//                               style: Typographyy.bodyMediumMedium
//                                   .copyWith(color: notifire.getGry500_600Color),
//                             ),
//                             const SizedBox(height: 10),
//                             TextField(
//                               controller: otpController,
//                               keyboardType: TextInputType.number,
//                               style: Typographyy.bodyLargeMedium
//                                   .copyWith(color: notifire.getWhitAndBlack),
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.all(16),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 hintText: "OTP".tr,
//                                 hintStyle: Typographyy.bodyLargeRegular
//                                     .copyWith(
//                                         color: notifire.getGry600_500Color),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                             onPressed: () {
//                               if (otpController.text.isNotEmpty) {
//                                 setState(() {
//                                   currentStep = 2;
//                                 });
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: priMeryColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               fixedSize: const Size.fromHeight(56),
//                             ),
//                             child: Center(
//                                 child: Text(
//                               "Verify OTP".tr,
//                               style: Typographyy.bodyLargeSemiBold.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w400),
//                             ))),
//                       ] else if (currentStep == 2) ...[
//                         // Step 3: Set New PIN
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "New PIN".tr,
//                               style: Typographyy.bodyMediumMedium
//                                   .copyWith(color: notifire.getGry500_600Color),
//                             ),
//                             const SizedBox(height: 10),
//                             TextField(
//                               controller: newPinController,
//                               obscureText: controller.isNewPinHidden,
//                               style: Typographyy.bodyLargeMedium
//                                   .copyWith(color: notifire.getWhitAndBlack),
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.all(16),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 hintText: "Enter new PIN".tr,
//                                 hintStyle: Typographyy.bodyLargeRegular
//                                     .copyWith(
//                                         color: notifire.getGry600_500Color),
//                                 suffixIcon: InkWell(
//                                   onTap: () {
//                                     controller.toggleNewPinVisibility();
//                                   },
//                                   child: SizedBox(
//                                       width: 24,
//                                       height: 24,
//                                       child: Center(
//                                           child: SvgPicture.asset(
//                                         controller.isNewPinHidden
//                                             ? "assets/images/eye-off.svg"
//                                             : "assets/images/eye-2.svg",
//                                         height: 24,
//                                         width: 24,
//                                         color: greyscale600,
//                                       ))),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Confirm New PIN".tr,
//                               style: Typographyy.bodyMediumMedium
//                                   .copyWith(color: notifire.getGry500_600Color),
//                             ),
//                             const SizedBox(height: 10),
//                             TextField(
//                               controller: confirmPinController,
//                               obscureText: controller.isConfirmPinHidden,
//                               style: Typographyy.bodyLargeMedium
//                                   .copyWith(color: notifire.getWhitAndBlack),
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.all(16),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                         color: notifire.getGry700_300Color)),
//                                 hintText: "Confirm new PIN".tr,
//                                 hintStyle: Typographyy.bodyLargeRegular
//                                     .copyWith(
//                                         color: notifire.getGry600_500Color),
//                                 suffixIcon: InkWell(
//                                   onTap: () {
//                                     controller.toggleConfirmPinVisibility();
//                                   },
//                                   child: SizedBox(
//                                       width: 24,
//                                       height: 24,
//                                       child: Center(
//                                           child: SvgPicture.asset(
//                                         controller.isConfirmPinHidden
//                                             ? "assets/images/eye-off.svg"
//                                             : "assets/images/eye-2.svg",
//                                         height: 24,
//                                         width: 24,
//                                         color: greyscale600,
//                                       ))),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                             onPressed: () {
//                               if (newPinController.text.isNotEmpty &&
//                                   confirmPinController.text.isNotEmpty &&
//                                   newPinController.text ==
//                                       confirmPinController.text) {
//                                 // PIN reset successful
//                                 Get.back();
//                                 Get.snackbar(
//                                   "Success".tr,
//                                   "PIN reset successfully".tr,
//                                   backgroundColor: Colors.green,
//                                   colorText: Colors.white,
//                                 );
//                               } else if (newPinController.text !=
//                                   confirmPinController.text) {
//                                 Get.snackbar(
//                                   "Error".tr,
//                                   "PINs do not match".tr,
//                                   backgroundColor: Colors.red,
//                                   colorText: Colors.white,
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: priMeryColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               fixedSize: const Size.fromHeight(56),
//                             ),
//                             child: Center(
//                                 child: Text(
//                               "Reset PIN".tr,
//                               style: Typographyy.bodyLargeSemiBold.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w400),
//                             ))),
//                       ],
//                       const SizedBox(height: 32),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Remember your PIN?".tr,
//                               style: Typographyy.bodyLargeMedium
//                                   .copyWith(color: notifire.getWhitAndBlack)),
//                           InkWell(
//                               onTap: () {
//                                 Get.back();
//                               },
//                               child: Text(" Sign In".tr,
//                                   style: Typographyy.bodyLargeExtraBold
//                                       .copyWith(color: priMeryColor))),
//                         ],
//                       ),
//                     ]),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
