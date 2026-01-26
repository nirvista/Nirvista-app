// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/sellcrypto_controller.dart';
import '../../../controller/ico_summary_controller.dart';

class SellCrypto extends StatefulWidget {
  const SellCrypto({super.key});

  @override
  State<SellCrypto> createState() => _SellCryptoState();
}

class _SellCryptoState extends State<SellCrypto> {

  List stepName = [
    "Select Token",
    "Enter Amount",
    "Confirm ",
  ];

  ColorNotifire notifire = ColorNotifire();
  SellCryptoController sellCryptoController = Get.put(SellCryptoController());
  final IcoSummaryController icoSummaryController =
      Get.put(IcoSummaryController());

  bool isBuyCrypto = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<IcoSummaryController>(builder: (icoController) {
      final sellAllowed = icoController.summary?['sellAllowed'] == true;
      final isLoading = icoController.isLoading && icoController.summary == null;
      return GetBuilder<SellCryptoController>(builder: (sellCryptoController) {
        if (isLoading) {
          return Center(
              child: CircularProgressIndicator(
                  color: notifire.getTextColor));
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: notifire.getBgColor,
          child: LayoutBuilder(
              builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Sell Token",
                        style: Typographyy.heading4
                            .copyWith(color: notifire.getTextColor),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: icoController.fetchSummary,
                        icon: const Icon(Icons.refresh),
                        color: notifire.getTextColor,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!sellAllowed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorWithOpacity(Colors.orange, 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Text(
                        "You cannot sell tokens during the Pre-ICO stage.",
                        style: Typographyy.bodyMediumExtraBold
                            .copyWith(color: Colors.orange[800]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: sellAllowed ? 8 : 16),
                  IgnorePointer(
                    ignoring: !sellAllowed,
                    child: Opacity(
                      opacity: sellAllowed ? 1 : 0.5,
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            controller:
                                sellCryptoController.scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: stepName.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              sellCryptoController
                                                  .setSelectStep(index);
                                            },
                                            child: Container(
                                              width: 160,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                                color: sellCryptoController
                                                            .selectStep ==
                                                        index
                                                    ? notifire
                                                        .getGry50_800Color
                                                    : Colors.transparent,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 32,
                                                    width: 32,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            8),
                                                    decoration:
                                                        BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            border: Border.all(
                                                                color: sellCryptoController
                                                                            .selectStep ==
                                                                        index
                                                                    ? priMeryColor
                                                                    : Colors
                                                                        .transparent),
                                                            color: sellCryptoController
                                                                    .selectIndex
                                                                    .contains(
                                                                        index)
                                                                ? priMeryColor
                                                                : Colors
                                                                    .transparent),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        sellCryptoController
                                                                .selectIndex
                                                                .contains(
                                                                    index)
                                                            ? SvgPicture.asset(
                                                                "assets/images/check29.svg",
                                                                height: 20,
                                                                width: 20,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : Text(
                                                                "${index + 1}"
                                                                    .toString(),
                                                                style: Typographyy
                                                                    .bodyMediumMedium
                                                                    .copyWith(
                                                                        color:
                                                                            notifire.getTextColor),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    stepName[index],
                                                    style: Typographyy
                                                        .bodyMediumExtraBold
                                                        .copyWith(
                                                            color: notifire
                                                                .getTextColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          index == 2
                                              ? SizedBox(
                                                  width:
                                                      constraints.maxWidth <
                                                              600
                                                          ? 300
                                                          : 0,
                                                )
                                              : SizedBox(
                                                  width: 50,
                                                  child: Divider(
                                                      height: 20,
                                                      color: notifire
                                                          .getGry700_300Color)),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          sellCryptoController.step[
                              sellCryptoController.selectStep],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      });
    });
  }
}
