// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/typography.dart';
import 'chatinfopage.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifire.getBgColor,
        body: Container(
          decoration: BoxDecoration(
              border: Border.all(color: notifire.getGry700_300Color),
              color: notifire.getBgColor
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                const SizedBox(height: 20,),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.arrow_back_ios,color: notifire.getGry500_600Color,size: 18,),
                        )),
                    Expanded(
                      child: ListTile(
                        onTap: () {
                          Get.to(const ChatInfo());
                        },
                        dense: true,
                        leading: const CircleAvatar(radius: 24,backgroundColor: Colors.transparent,backgroundImage: AssetImage("assets/images/05.png")),
                        title: Text("Elon Musk",style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text("Online",style: Typographyy.bodySmallMedium.copyWith(color: const Color(0xff22C55E)),),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,width: 45,decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: notifire.getGry700_300Color),
                            ),
                              child: Center(child: SvgPicture.asset("assets/images/video.svg",height: 24,width: 24,)),
                            ),
                            const SizedBox(width: 10,),
                            Container(
                              height: 45,width: 45,decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: notifire.getGry700_300Color),
                            ),
                              child: Center(child: SvgPicture.asset("assets/images/phone.svg",height: 24,width: 24,)),
                            ),
                            const SizedBox(width: 10,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: notifire.getGry700_300Color,height: 40,),
                _builchatui(contante: "The exported video seems laggy, what can I do to fix it?"),
                _builchatui1(contante: "Shut down other applications on your laptop to improve the animation."),
                _builchatui(contante: "Can it export in MP4 too?"),
                _builchatui1(contante: "You can convert the .webm files in this video converter from VEED."),
                _builchatui(contante: "Can it export in MP4 too?"),
                _builchatui1(contante: "You can convert the .webm files in this video converter from VEED."),
                _builchatui(contante: "The exported video seems laggy, what can I do to fix it?"),
                const SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      border: Border.all(color: notifire.getGry700_300Color),
                      color: notifire.getBgColor,
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Center(
                      child: TextField(
                        style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),
                        decoration: InputDecoration(isDense: true,hintText: "Type a Message...",hintStyle: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),border: InputBorder.none,contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/photo.svg",height: 22,width: 22,color: notifire.getGry500_600Color),
                      const SizedBox(width: 8,),
                      SvgPicture.asset("assets/images/link.svg",height: 22,width: 22,color: notifire.getGry500_600Color),
                      const SizedBox(width: 8,),
                      SvgPicture.asset("assets/images/mood-smile.svg",height: 22,width: 22,color: notifire.getGry500_600Color),
                      const Spacer(),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 40),
                              backgroundColor: priMeryColor
                          ),
                          onPressed: () {}, child: Text("Send".tr,style: Typographyy.bodySmallExtraBold.copyWith(color: whiteColor),))
                    ],),
                ),
                const SizedBox(height: 15,),


              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _builchatui({required String contante}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          // height: 160,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12),bottomRight: Radius.circular(12),bottomLeft: Radius.circular(4)),
                            color: notifire.getGry50_800Color,
                          ),
                          child: Center(child: Text(contante,style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color,height: 1.6,letterSpacing: 0.6),)),
                        ),
                      ),
                      const SizedBox(width: 16,),
                      SvgPicture.asset("assets/images/share-two.svg",height: 22,width: 22,),
                    ],
                  ),
                  const SizedBox(height: 14,),
                  Text("08:23 AM",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),)
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          )
        ],
      ),
    );
  }
  Widget _builchatui1({required String contante}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child:  Container(),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/images/share-two.svg",height: 22,width: 22,),
                      const SizedBox(width: 16,),
                      Expanded(
                        child: Container(
                          // height: 160,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12),bottomRight: Radius.circular(4),bottomLeft: Radius.circular(12)),
                            color: priMeryColor,
                          ),
                          child: Center(child: Text(contante,style: Typographyy.bodySmallMedium.copyWith(color: Colors.white,height: 1.6,letterSpacing: 0.6),)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14,),
                  Text("08:23 AM",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
