// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../ConstData/typography.dart';

class ChatInfo extends StatefulWidget {
  const ChatInfo({super.key});

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(Icons.arrow_back_ios,size: 18,color: notifire.getGry500_600Color,)),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            height: 45,width: 45,decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: notifire.getGry700_300Color),
                          ),
                            child: Center(child: SvgPicture.asset("assets/images/plus.svg",height: 24,width: 24,)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    const CircleAvatar(radius: 70,backgroundColor: Colors.transparent,backgroundImage: AssetImage("assets/images/05.png"),),
                    const SizedBox(height: 20,),
                    Text("Elon Musk",style: Typographyy.heading6.copyWith(color: notifire.getTextColor),),
                    const SizedBox(height: 8,),
                    Text("Flutter Dev.",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),),
                    const SizedBox(height: 50),
                    ListTile(
                      title: Text("Recent files",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getTextColor)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text("123 files",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),),
                      ),
                      trailing: SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(child: SvgPicture.asset("assets/images/chevron-down.svg",height: 20,width: 20,))),
                    ),
                    const SizedBox(height: 16,),
                    ListTile(
                      title: Text("InvoiceXX.pdf",style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getGry500_600Color)),
                      leading: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/receipt.svg",color: notifire.getGry500_600Color,)),
                      trailing: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/dots-h.svg",color: notifire.getGry500_600Color,)),
                    ),
                    ListTile(
                      title: Text("InvoiceZZ.pdf",style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getGry500_600Color)),
                      leading: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/receipt.svg",color: notifire.getGry500_600Color,)),
                      trailing: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/dots-h.svg",color: notifire.getGry500_600Color,)),
                    ),
                    ListTile(
                      title: Text("Document.docx",style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getGry500_600Color)),
                      leading: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/file-text.svg",color: notifire.getGry500_600Color,)),
                      trailing: SizedBox(height: 22,width: 22,child: SvgPicture.asset("assets/images/dots-h.svg",color: notifire.getGry500_600Color,)),
                    ),
                    const SizedBox(height: 30,),
                    ListTile(
                      title: Text("Images",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getTextColor)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text("29 Images",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),),
                      ),
                      trailing: SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(child: SvgPicture.asset("assets/images/chevron-down.svg",height: 20,width: 20,))),
                    ),
                    const SizedBox(height: 10,),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 150,
                            decoration:  BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(image: AssetImage("assets/images/image.png"),fit: BoxFit.cover)
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Container(
                            height: 150,

                            decoration:  BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(image: AssetImage("assets/images/image-1.png"),fit: BoxFit.cover)
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 150,
                            decoration:  BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(image: AssetImage("assets/images/image-2.png"),fit: BoxFit.cover)
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Container(
                            height: 150,
                            decoration:  BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(image: AssetImage("assets/images/more.png"),fit: BoxFit.cover)
                            ),
                          ),
                        )
                      ],
                    )

                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
