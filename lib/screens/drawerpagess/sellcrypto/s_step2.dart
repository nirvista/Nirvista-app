// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../ConstData/colorprovider.dart';
import '../../../ConstData/colorfile.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/sellcrypto_controller.dart';

class SellStep2 extends StatefulWidget {
  const SellStep2({super.key});

  @override
  State<SellStep2> createState() => _SellStep2State();
}

class _SellStep2State extends State<SellStep2> {

  ColorNotifire notifire = ColorNotifire();
  SellCryptoController sellCryptoController = Get.put(SellCryptoController());

  @override
  void initState() {
    super.initState();
    sellCryptoController.priceController.text = "111";
  }


  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<SellCryptoController>(
        builder: (sellCryptoController) {
          return LayoutBuilder(
              builder: (context, constraints)  {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        height: 330,
                        width: 600,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: notifire.getGry50_800Color),
                        child: Column(
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      sellCryptoController.selectIndex.remove(1);
                                      setState(() {
                                        sellCryptoController.selectStep--;
                                      });
                                      sellCryptoController
                                          .setSelectStep(sellCryptoController.selectStep);
                                      sellCryptoController.scrollController.jumpTo(0);
                                    },
                                    child: SvgPicture.asset(
                                      "assets/images/arrow-left-small.svg",
                                      height: 20,
                                      width: 20,
                                      color: notifire.getGry500_600Color,
                                    )),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Enter Amount",
                                  style: Typographyy.heading5
                                      .copyWith(color: notifire.getTextColor),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text("Selling Bitcoin",style: Typographyy.bodyMediumRegular.copyWith(color: notifire.getGry500_600Color)),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    constraints.maxWidth<600?  const SizedBox() : const CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage:
                                        AssetImage("assets/images/btc.png"),
                                        radius: 15),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 30,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                SizedBox(
                                  // height: 50,
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.end,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            if(sellCryptoController.priceController.text.isEmpty){
                                              sellCryptoController.setPriceSelect(-1);
                                            }
                                          },
                                          onTap: () {
                                            // setState(() {
                                            //   if(buyCryptoCreditCard.priceController.text.isEmpty){
                                            //     buyCryptoCreditCard.setPriceSelect(-1);
                                            //   }
                                            // });
                                          },
                                          controller: sellCryptoController.priceController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,

                                          ),
                                          style: Typographyy.heading1.copyWith(color: notifire.getTextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15,),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text("BTC",style: Typographyy.heading4.copyWith(color: notifire.getTextColor),),
                                ),
                              ],
                            ),

                            RichText(text: TextSpan(children: [
                              TextSpan(text: "You Will Get ",style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getGry500_600Color)),
                              TextSpan(text: "20 ",style: Typographyy.heading6.copyWith(color: notifire.getTextColor)),
                              TextSpan(text: "BTC",style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getGry500_600Color)),
                            ])),
                            // SizedBox(
                            //   height: 50,
                            //   // width: Get.width,
                            //   child: ListView.builder(
                            //     shrinkWrap: true,
                            //     scrollDirection: Axis.horizontal,
                            //     itemCount: 4,
                            //     itemBuilder: (context, index) {
                            //       return InkWell(
                            //         onTap: () {
                            //
                            //           sellCryptoController.setPriceSelect(index);
                            //           setState(() {
                            //             sellCryptoController.priceController.text = price[index];
                            //           });
                            //         },
                            //         child: Container(
                            //           height: 42,
                            //           width: 80,
                            //           margin: const EdgeInsets.all(8),
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(20),
                            //             border: Border.all(color: sellCryptoController.priceSelect == index ? priMeryColor : notifire.getGry700_300Color),
                            //           ),
                            //           child: Center(
                            //               child: Text( price[index],style: Typographyy.bodyMediumMedium.copyWith(color: sellCryptoController.priceSelect == index ? priMeryColor : notifire.getTextColor))),
                            //         ),
                            //       );
                            //     },),
                            // ),
                            const SizedBox(height: 28,),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: priMeryColor,
                                  fixedSize: const Size(100, 42),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    sellCryptoController.selectStep++;
                                  });
                                  sellCryptoController.setSelectStep(sellCryptoController.selectStep);
                                  sellCryptoController.selectIndex.add(1);
                                  sellCryptoController.scrollController.animateTo(440, duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
                                }, child:  Text("Sell",style: Typographyy.bodyLargeExtraBold.copyWith(color: Colors.white),)),
                            // const SizedBox(height: 12,),
                            // ElevatedButton(
                            //     onPressed: () {
                            //       setState(() {
                            //         buyCryptoCreditCard.selectStep--;
                            //       });
                            //       buyCryptoCreditCard.setSelectStep(buyCryptoCreditCard.selectStep);
                            //        buyCryptoCreditCard.selectIndex.remove(1);
                            //       buyCryptoCreditCard.scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeOut);
                            //
                            //     }, child: const Text("cancle")),
                          ],
                        ),
                      ),),
                  ],
                );
              }
          );
        }
    );
  }
}
