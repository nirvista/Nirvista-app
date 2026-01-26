// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../CommonWidgets/applogo.dart';
import '../ConstData/colorfile.dart';
import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';
import '../controller/drawercontroller.dart';
import '../services/auth_api_service.dart';
// import 'authscreens/forgotpassword.dart';
// import 'authscreens/otp_screen.dart';
// import 'authscreens/reson.dart';
// import 'authscreens/singin.dart';
// import 'authscreens/singup.dart';
import 'dart:math';

import 'drawerpagess/termsandcondition/policy_detail.dart';

const List<String> privacyPolicyTitles = [
  'PRIVACY POLICY',
  'TERMS & CONDITIONS',
  'REFUND & CANCELLATION POLICY',
  'WITHDRAWAL POLICY',
  'PAYMENT POLICY',
  'STAKING POLICY',
  'REFERRAL POLICY',
  'KYC & AML POLICY',
  'RISK DISCLOSURE POLICY',
  'USER CONDUCT POLICY',
  'DATA RETENTION & DELETION POLICY',
  'COOKIE POLICY',
  'GRIEVANCE REDRESSAL POLICY',
  'COMPLIANCE & LEGAL JURISDICTION POLICY',
  'DISCLAIMER POLICY',
];

class DrawerCode extends StatefulWidget {
  const DrawerCode({super.key});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  ColorNotifire notifire = ColorNotifire();
  DrawerControllerr contoller = Get.put(DrawerControllerr());

  int selectedTile = -1;
  bool isProfileLoading = false;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isProfileLoading = true;
    });

    try {
      final response = await AuthApiService.profile();
      if (response['success'] == true) {
        Map<String, dynamic>? data;
        if (response['data'] is Map<String, dynamic>) {
          data = response['data'] as Map<String, dynamic>;
        } else if (response['name'] != null || response['mobile'] != null) {
          data = response;
        }
        if (data != null) {
          setState(() {
            profileData = data;
          });
        }
      }
    } catch (_) {
      // Keep defaults on failure.
    } finally {
      if (mounted) {
        setState(() {
          isProfileLoading = false;
        });
      }
    }
  }

  String _profileName() {
    return profileData?['name']?.toString() ?? 'User';
  }

  String? _selfieUrl() {
    final profileUrl = profileData?['profileImageUrl']?.toString();
    if (profileUrl != null && profileUrl.isNotEmpty) {
      return profileUrl;
    }
    final selfieUrl = profileData?['selfieUrl']?.toString();
    return (selfieUrl != null && selfieUrl.isNotEmpty) ? selfieUrl : null;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(builder: (context, constraints) {
      return Drawer(
        shape: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.transparent)),
        width: 250,
        elevation: 0,
        backgroundColor: notifire.getDrawerColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/dashboard');
                          contoller.function(value: -1);
                          contoller.colorSelecter(value: 0);
                        },
                        child: const AppLogo(size: 40, width: 140)),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Divider(
                color: notifire.getGry700_300Color,
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 41,
                          backgroundColor: notifire.getContainerColor,
                          backgroundImage: _selfieUrl() != null
                              ? NetworkImage(_selfieUrl()!)
                              : const AssetImage("assets/images/05.png"),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(_profileName(),
                            style: Typographyy.bodyLargeMedium
                                .copyWith(color: priMeryColor, fontSize: 18)),
                        const SizedBox(
                          height: 5,
                        ),
                        if (isProfileLoading) ...[
                          const SizedBox(height: 8),
                          const SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(),
                          )
                        ],
                        const SizedBox(
                          height: 30,
                        ),
                        _buildListTile(
                          title: "Dashboard",
                          icon: "assets/images/home-2.svg",
                          ontap: () {
                            Navigator.pushNamed(context, '/dashboard');
                            contoller.function(value: -1);
                            contoller.colorSelecter(value: 0);
                          },
                          index: 0,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "Transaction",
                          icon: "assets/images/receipt-tax.svg",
                          ontap: () {
                            Navigator.pushNamed(context, '/transactions');
                            contoller.function(value: -1);
                            contoller.colorSelecter(value: 1);
                          },
                          index: 1,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "My Wallets",
                          icon: "assets/images/card.svg",
                          index: 3,
                          ontap: () {
                            Navigator.pushNamed(context, '/myWallets');
                            contoller.function(value: -1);
                            contoller.colorSelecter(value: 3);
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "Nirvista ICO",
                          icon: "assets/images/briefcase.svg",
                          index: 5,
                          ontap: () {
                            Navigator.pushNamed(context, '/creditCard');
                            contoller.colorSelecter(value: 5);
                            contoller.function(value: -1);
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ListTileTheme(
                          dense: true,
                          tileColor: 2 == contoller.currentIndex
                              ? priMeryColor
                              : notifire.getDrawerColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            initiallyExpanded: 2 == contoller.currentIndex,
                            key: Key(contoller.currentIndex.toString()),
                            onExpansionChanged: (value) {
                              Navigator.pushNamed(context, '/transactions');
                              contoller.colorSelecter(value: 13);
                              if (value == true) {
                                contoller.function(value: 2);
                              } else {
                                contoller.function(value: -1);
                              }
                            },
                            iconColor: contoller.currentIndex == 2
                                ? whiteColor
                                : notifire.getGry500_600Color,
                            collapsedIconColor: notifire.getGry500_600Color,
                            leading: SizedBox(
                              height: 22,
                              width: 22,
                              child: SvgPicture.asset(
                                "assets/images/dashbord.svg",
                                color: contoller.currentIndex == 2
                                    ? whiteColor
                                    : notifire.getGry500_600Color,
                                height: 22,
                                width: 22,
                              ),
                            ),
                            title: Text("Activity".tr,
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: contoller.currentIndex == 2
                                        ? whiteColor
                                        : notifire.getGry500_600Color)),
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: SizedBox(
                                      height: 60,
                                      child: VerticalDivider(
                                          color: notifire.getGry700_300Color,
                                          width: 2),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 42,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 18,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/transactions');
                                            contoller.colorSelecter(value: 13);
                                          },
                                          child: Text("Transactions".tr,
                                              style: Typographyy
                                                  .bodyMediumMedium
                                                  .copyWith(
                                                      color: contoller
                                                                  .currentcolor ==
                                                              13
                                                          ? priMeryColor
                                                          : notifire
                                                              .getGry500_600Color))),
                                      const SizedBox(
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "Analytics",
                          icon: "assets/images/Chart.svg",
                          index: 15,
                          ontap: () {
                            Navigator.pushNamed(context, '/analytics');
                            contoller.colorSelecter(value: 15);
                            contoller.function(value: -1);
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "Get Help",
                          icon: "assets/images/question-circle-outlined.svg",
                          index: 16,
                          ontap: () {
                            Navigator.pushNamed(context, '/getHelp');
                            contoller.colorSelecter(value: 16);
                            contoller.function(value: -1);
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildListTile(
                          title: "Settings",
                          icon: "assets/images/settings.svg",
                          index: 17,
                          ontap: () {
                            Navigator.pushNamed(context, '/settings');
                            contoller.colorSelecter(value: 17);
                            contoller.function(value: -1);
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ListTileTheme(
                          dense: true,
                          tileColor: 18 == contoller.currentIndex
                              ? priMeryColor
                              : notifire.getDrawerColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            initiallyExpanded: 18 == contoller.currentIndex,
                            onExpansionChanged: (value) {
                              contoller.colorSelecter(value: 18);
                              if (value) {
                                contoller.function(value: 18);
                              } else {
                                contoller.function(value: -1);
                              }
                            },
                            iconColor: contoller.currentIndex == 18
                                ? whiteColor
                                : notifire.getGry500_600Color,
                            collapsedIconColor: notifire.getGry500_600Color,
                            leading: SizedBox(
                              height: 22,
                              width: 22,
                              child: SvgPicture.asset(
                                "assets/images/document.svg",
                                color: contoller.currentIndex == 18
                                    ? whiteColor
                                    : notifire.getGry500_600Color,
                                height: 22,
                                width: 22,
                              ),
                            ),
                            title: Text(
                              "Policy Pages",
                              style: Typographyy.bodyMediumMedium.copyWith(
                                  color: contoller.currentIndex == 18
                                      ? whiteColor
                                      : notifire.getGry500_600Color),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 16, bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                        height:
                                            min(privacyPolicyTitles.length, 5) *
                                                44.0,
                                        child: VerticalDivider(
                                            color: notifire.getGry700_300Color,
                                            width: 2),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 42,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height:
                                            min(privacyPolicyTitles.length, 5) *
                                                45.0,
                                        child: Scrollbar(
                                          scrollbarOrientation:
                                              ScrollbarOrientation.right,
                                          child: ListView.separated(
                                            physics:
                                                const ClampingScrollPhysics(),
                                            itemCount:
                                                privacyPolicyTitles.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 8),
                                            itemBuilder: (context, index) {
                                              final policy =
                                                  privacyPolicyTitles[index];
                                              return InkWell(
                                                onTap: () {
                                                  contoller.colorSelecter(
                                                      value: 18);
                                                  contoller.function(value: 18);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          PolicyDetailScreen(
                                                              policyTitle:
                                                                  policy),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4, bottom: 4),
                                                  child: Text(
                                                    policy,
                                                    style: Typographyy
                                                        .bodyMediumMedium
                                                        .copyWith(
                                                      color: contoller
                                                                  .currentcolor ==
                                                              18
                                                          ? priMeryColor
                                                          : notifire
                                                              .getGry600_500Color,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  bool isTransfer = false;

  Widget _buildListTile(
      {required String title,
      required String icon,
      void Function()? ontap,
      required int index}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color:
            contoller.currentcolor == index ? priMeryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: ListTile(
          // tileColor: Colors.lightGreen,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          onTap: ontap,
          dense: true,
          leading: SizedBox(
            height: 22,
            width: 22,
            child: SvgPicture.asset(
              icon,
              color: contoller.currentcolor == index
                  ? whiteColor
                  : notifire.getGry500_600Color,
              height: 22,
              width: 22,
            ),
          ),
          title: Text(
            title.tr,
            style: Typographyy.bodyMediumMedium.copyWith(
                color: contoller.currentcolor == index
                    ? whiteColor
                    : notifire.getGry500_600Color),
          ),
        ),
      ),
    );
  }
}

Widget _buildFrom() {
  return GetBuilder<DrawerControllerr>(builder: (contoller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(
          height: 8,
        ),
        PopupMenuButton(
          onOpened: () {
            contoller.setIsFrom(true);
          },
          onCanceled: () {
            contoller.setIsFrom(false);
          },
          offset: const Offset(0, 50),
          color: notifire.getContainerColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          constraints: BoxConstraints(minWidth: 60, maxWidth: Get.width),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifire.getGry700_300Color)),
            child: Row(
              children: [
                Text(
                  contoller.from[contoller.selectFrom],
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getTextColor),
                ),
                const Spacer(),
                SvgPicture.asset(
                  contoller.isFrom
                      ? "assets/images/chevron-up.svg"
                      : "assets/images/chevron-down.svg",
                  height: 20,
                  width: 20,
                )
              ],
            ),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: SizedBox(
                height: 110,
                width: 70,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contoller.from.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              contoller.setSelectFrom(index);
                              Get.back();
                            },
                            child: Text(
                              contoller.from[index],
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getTextColor),
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    );
                  },
                ),
              )),
            ];
          },
        ),
      ],
    );
  });
}

Widget _buildTo() {
  return GetBuilder<DrawerControllerr>(builder: (contoller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(
          height: 8,
        ),
        PopupMenuButton(
          offset: const Offset(0, 50),
          color: notifire.getContainerColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          constraints: BoxConstraints(minWidth: 100, maxWidth: Get.width),
          onOpened: () {
            contoller.setIsTo(true);
          },
          onCanceled: () {
            contoller.setIsTo(false);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifire.getGry700_300Color)),
            child: Row(
              children: [
                Text(
                  contoller.to[contoller.selectTo],
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getTextColor),
                ),
                const Spacer(),
                SvgPicture.asset(
                  contoller.isto
                      ? "assets/images/chevron-up.svg"
                      : "assets/images/chevron-down.svg",
                  height: 20,
                  width: 20,
                )
              ],
            ),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: SizedBox(
                height: 90,
                width: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contoller.to.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              contoller.setSelectTo(index);
                              Get.back();
                            },
                            child: Text(
                              contoller.to[index],
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getTextColor),
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    );
                  },
                ),
              )),
            ];
          },
        ),
      ],
    );
  });
}

Future<void> transfer({required double width, context}) async {
  return showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return GetBuilder<DrawerControllerr>(builder: (contoller) {
        return GetBuilder<DrawerControllerr>(builder: (drawerControllerr) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 8),
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: notifire.getBgColor,
            content: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  // height: 200,
                  width: width < 600 ? Get.width : 500,
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                  Navigator.pushNamed(context, '/dashboard');
                                  contoller.function(value: -1);
                                  contoller.colorSelecter(value: 0);
                                },
                                child: SvgPicture.asset(
                                  "assets/images/plus.svg",
                                  height: 22,
                                  width: 22,
                                  color: priMeryColor,
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Staking",
                          style: Typographyy.heading4
                              .copyWith(color: notifire.getTextColor),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                              // height: 80,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: notifire.getGry50_800Color,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Available",
                                        style: Typographyy.bodyLargeMedium
                                            .copyWith(
                                                color: notifire
                                                    .getGry500_600Color),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "29.231477 BTC",
                                        style: Typographyy.bodyLargeExtraBold
                                            .copyWith(
                                                color: notifire.getTextColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Balance",
                                        style: Typographyy.bodyLargeMedium
                                            .copyWith(
                                                color: notifire
                                                    .getGry500_600Color),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "\$29,277",
                                        style: Typographyy.bodyLargeExtraBold
                                            .copyWith(
                                                color: notifire.getTextColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ))
                          ],
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        drawerControllerr.isTransfer
                            ? _buildTo()
                            : _buildFrom(),
                        const SizedBox(
                          height: 18,
                        ),
                        InkWell(
                            onTap: () {
                              drawerControllerr.setIsTransfer(drawerControllerr
                                  .isTransfer = !drawerControllerr.isTransfer);
                            },
                            child: CircleAvatar(
                              backgroundColor: notifire.getGry50_800Color,
                              child: Center(
                                  child: SvgPicture.asset(
                                      "assets/images/Group 47984.svg",
                                      height: 16,
                                      width: 16,
                                      color: notifire.getGry500_600Color)),
                            )),
                        const SizedBox(
                          height: 18,
                        ),
                        drawerControllerr.isTransfer
                            ? _buildFrom()
                            : _buildTo(),
                        const SizedBox(
                          height: 18,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Coin",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            PopupMenuButton(
                              onOpened: () {
                                contoller.setIsCoin(true);
                              },
                              onCanceled: () {
                                contoller.setIsCoin(false);
                              },
                              offset: const Offset(0, 50),
                              color: notifire.getContainerColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              constraints: BoxConstraints(
                                  minWidth: 60, maxWidth: Get.width),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: notifire.getGry700_300Color)),
                                child: Row(
                                  children: [
                                    Text(
                                      contoller.coins[contoller.selectCoins],
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(
                                              color: notifire.getTextColor),
                                    ),
                                    const Spacer(),
                                    SvgPicture.asset(
                                      "assets/images/chevron-down.svg",
                                      height: 20,
                                      width: 20,
                                    )
                                  ],
                                ),
                              ),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                      child: SizedBox(
                                    height: 110,
                                    width: 120,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: contoller.coins.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  contoller
                                                      .setSelectCoin(index);
                                                  Get.back();
                                                },
                                                child: Text(
                                                  contoller.coins[index],
                                                  style: Typographyy
                                                      .bodyMediumMedium
                                                      .copyWith(
                                                          color: notifire
                                                              .getTextColor),
                                                )),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )),
                                ];
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Direct staking from Token Wallet",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: notifire.getGry700_300Color)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: TextField(
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(color: notifire.getTextColor),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        suffixIcon: Text(
                                          "Max Amount",
                                          style: Typographyy.bodySmallSemiBold
                                              .copyWith(
                                                  color: notifire
                                                      .getGry500_600Color),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "29.231477 BTC Available",
                          style: Typographyy.bodyXSmallMedium
                              .copyWith(color: notifire.getGry500_600Color),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: priMeryColor,
                                        fixedSize: const Size.fromHeight(42),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    onPressed: () {
                                      // Get.back();
                                      // Navigator.pushNamed(context, '/dashboard');
                                      contoller.offIsLoading(context, width);
                                      // contoller.function(value: -1);
                                      // contoller.colorSelecter(value: 0);
                                      // complete(context,width: width);
                                    },
                                    child: Text(
                                      "Staking",
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(color: Colors.white),
                                    ))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                contoller.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox(),
              ],
            ),
          );
        });
      });
    },
  );
}

Future<void> complete1(context, {required double width}) {
  notifire = Provider.of<ColorNotifire>(context, listen: false);
  return Get.defaultDialog(
      backgroundColor: notifire.getContainerColor,
      title: "",
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // height: 400,
              width: width < 600 ? Get.width : 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset("assets/images/discount-voucher.png",
                      height: 80, width: 80),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Yay!",
                    style: Typographyy.heading3
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                              text: "You Successfully Transfer",
                              style: Typographyy.bodyLargeExtraBold
                                  .copyWith(color: notifire.getTextColor)),
                          TextSpan(
                              text: " 0.25644 BTC ",
                              style: Typographyy.bodyLargeExtraBold
                                  .copyWith(color: priMeryColor)),
                          TextSpan(
                              text: "From Bitcloud",
                              style: Typographyy.bodyLargeExtraBold
                                  .copyWith(color: notifire.getTextColor)),
                        ])),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Text(
                        "Status",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                      const Spacer(),
                      Text(
                        "Transaction ID",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Completed",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: priMeryColor),
                      ),
                      const Spacer(),
                      Text(
                        "0Am4520xws..23231",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              fixedSize: const Size.fromHeight(42),
                              backgroundColor: notifire.getGry700_300Color,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Transaction",
                              style: Typographyy.bodyLargeMedium.copyWith(
                                color: notifire.getTextColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              fixedSize: const Size.fromHeight(42),
                              backgroundColor: priMeryColor,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Wallet",
                              style: Typographyy.bodyLargeMedium
                                  .copyWith(color: Colors.white),
                            )),
                      ),
                    ],
                  )
                ],
              )),
          Positioned(
              top: -150,
              right: 0,
              left: 0,
              child: Lottie.asset('assets/images/L6o2mVij1E.json',
                  height: 300, width: 300)),
        ],
      ));
}
