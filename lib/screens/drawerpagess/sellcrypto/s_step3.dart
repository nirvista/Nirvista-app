// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../ConstData/colorprovider.dart';
import '../../../ConstData/colorfile.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/sellcrypto_controller.dart';
import '../../drawercode.dart';

class SellStep3 extends StatefulWidget {
  const SellStep3({super.key});

  @override
  State<SellStep3> createState() => _SellStep3State();
}

class _SellStep3State extends State<SellStep3> {
  ColorNotifire notifire = ColorNotifire();
  SellCryptoController sellCryptoController = Get.put(SellCryptoController());

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<SellCryptoController>(
        builder: (sellCryptoController) {
            return LayoutBuilder(
            builder: (context, constraints) {
            return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(24),
                // height: 600,
                width: 600,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: notifire.getGry50_800Color),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                            onTap: () {
                              sellCryptoController.selectIndex.remove(2);
                              setState(() {
                                sellCryptoController.selectStep--;
                              });

                              sellCryptoController.setSelectStep(
                                  sellCryptoController.selectStep);
                              sellCryptoController.scrollController.jumpTo(220);
                            },
                            child: SvgPicture.asset(
                              "assets/images/arrow-left-small.svg",
                              height: 20,
                              width: 20,
                              color: notifire.getGry500_600Color,
                            )),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          "Confirm Order",
                          style: Typographyy.heading5
                              .copyWith(color: notifire.getTextColor),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text("Selling Bitcoin",
                                style: Typographyy.bodyMediumRegular.copyWith(
                                    color: notifire.getGry500_600Color,
                                    overflow: TextOverflow.ellipsis)),
                            constraints.maxWidth < 600
                                ? const SizedBox()
                                : const SizedBox(
                                    width: 8,
                                  ),
                            constraints.maxWidth < 600
                                ? const SizedBox()
                                : const CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage:
                                        AssetImage("assets/images/btc.png"),
                                    radius: 15),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: notifire.getGry700_300Color,
                            ),
                            child: constraints.maxWidth < 400
                                ? Column(
                                    children: [
                                      _listTile(),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      _listTile1(),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      _listTile2(),
                                    ],
                                  )
                                : constraints.maxWidth < 600
                                    ? Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: _listTile()),
                                              Expanded(child: _listTile2()),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          _listTile1()
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: _listTile(),
                                          ),
                                          Expanded(
                                            child: _listTile1(),
                                          ),
                                          Expanded(child: _listTile2()),
                                        ],
                                      ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      "You are about to buy 0.02929 BTC from Bitcloud",
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    Row(
                      children: [
                        Text('0.02955',
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                        const Spacer(),
                        Text(
                          "BTC",
                          style: Typographyy.bodyMediumMedium
                              .copyWith(color: notifire.getTextColor),
                        )
                      ],
                    ),
                    Divider(
                      height: 48,
                      color: notifire.getGry700_300Color,
                    ),
                    Row(
                      children: [
                        Text('Service fee',
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color)),
                        const Spacer(),
                        Text(
                          "0.00 BTC",
                          style: Typographyy.bodyMediumMedium
                              .copyWith(color: notifire.getGry500_600Color),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text('You will pay',
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color)),
                        const Spacer(),
                        Text(
                          "\$20.00 USD ",
                          style: Typographyy.bodyMediumMedium
                              .copyWith(color: notifire.getGry500_600Color),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: notifire.getContainerColor,
                                fixedSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: notifire.getGry700_300Color))),
                            onPressed: () {
                              sellCryptoController.selectIndex.remove(2);
                              setState(() {
                                sellCryptoController.selectStep--;
                              });

                              sellCryptoController.setSelectStep(
                                  sellCryptoController.selectStep);
                              sellCryptoController.scrollController.jumpTo(220);
                            },
                            child: Text(
                              "Cancel",
                              style: Typographyy.bodyMediumSemiBold
                                  .copyWith(color: notifire.getTextColor),
                            )),
                        const Spacer(),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: priMeryColor,
                                fixedSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              complete1(context, width: constraints.maxWidth);

                              setState(() {
                                // buyCryptoCreditCard.selectStep++;
                              });
                              sellCryptoController.setSelectStep(0);
                              sellCryptoController.selectIndex = [];
                              sellCryptoController.scrollController.animateTo(0,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                            },
                            child: Text(
                              "I Understand Continue",
                              style: Typographyy.bodyMediumSemiBold
                                  .copyWith(color: Colors.white),
                            )),
                      ],
                    ),

                    // ElevatedButton(
                    //     onPressed: () {
                    //
                    //       if(buyCryptoCreditCard.selectStep != 3){
                    //         setState(() {
                    //           buyCryptoCreditCard.selectStep++;
                    //         });
                    //         buyCryptoCreditCard.setSelectStep(buyCryptoCreditCard.selectStep);
                    //         buyCryptoCreditCard.selectIndex = [];
                    //         buyCryptoCreditCard.scrollController.animateTo(800, duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
                    //
                    //       }
                    //
                    //     }, child: const Text("Next")),
                    // const SizedBox(height: 12,),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       buyCryptoCreditCard.selectIndex.remove(3);
                    //       setState(() {
                    //         buyCryptoCreditCard.selectStep--;
                    //       });
                    //       buyCryptoCreditCard.setSelectStep(buyCryptoCreditCard.selectStep);
                    //
                    //       buyCryptoCreditCard.scrollController.jumpTo(420);
                    //     }, child: const Text("cancle")),
                  ],
                ),
              ),
            ),
          ],
        );
      });
    });
  }

  Widget _listTile() {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
          backgroundColor: Colors.deepPurpleAccent,
          child: SvgPicture.asset(
            "assets/images/wallet.svg",
            height: 20,
            width: 20,
            color: Colors.white,
          )),
      contentPadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          "Send",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
      subtitle: Text(
        "\$29.00",
        style: Typographyy.bodyLargeSemiBold
            .copyWith(color: notifire.getTextColor),
      ),
    );
  }

  Widget _listTile1() {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: SvgPicture.asset(
            "assets/images/wallet.svg",
            height: 20,
            width: 20,
            color: Colors.white,
          )),
      contentPadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          "Get",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
      subtitle: Text(
        "0.2955 BTC",
        style: Typographyy.bodyLargeSemiBold.copyWith(
            color: notifire.getTextColor, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _listTile2() {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
          backgroundColor: priMeryColor,
          child: SvgPicture.asset(
            "assets/images/wallet.svg",
            height: 20,
            width: 20,
            color: Colors.white,
          )),
      contentPadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          "Method",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
      subtitle: Text(
        "Credit Card",
        style: Typographyy.bodyLargeSemiBold.copyWith(
            color: notifire.getTextColor, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
