// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/messagescontroller.dart';
import 'chatboxpage.dart';


class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  MassageController massageController = Get.put(MassageController());
  ColorNotifire notifire = ColorNotifire();
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<MassageController>(
      builder: (massageController) {
        return LayoutBuilder(builder: (context, constraints) {
          if(constraints.maxWidth<800){
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: notifire.getBgColor,
              child:  SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      _buildui1(width: constraints.maxWidth),

                ]),
              ),

            );
          }else if(constraints.maxWidth<1200){
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: notifire.getBgColor,
              child:  SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildui1(width: constraints.maxWidth),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildui2(width: constraints.maxWidth),
                          ),
                        ],
                      )
                ]),
              ),

            );
          }else{
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: notifire.getBgColor,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildui1(width: constraints.maxWidth),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildui2(width: constraints.maxWidth),
                          ),
                          Expanded(
                            flex: 1,
                            child:_buildui3(),
                          )
                        ],
                      )
                ]),
              ),
            );
          }

        },);
      }
    );
  }
  Widget _buildui1({required double width}){
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: notifire.getGry700_300Color),
          color: notifire.getBgColor
      ),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: width<600? 20 : 40),
        child: Column(
          children: [
            const SizedBox(height: 40,),
            TextField(
              style: Typographyy.bodyMediumRegular.copyWith(color: notifire.getTextColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                hintText: "Search...",
                hintStyle: Typographyy.bodyMediumRegular.copyWith(color: notifire.getGry500_600Color),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: massageController.pepoleimage.length,
              itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.to(const ChatBox());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading:  CircleAvatar(radius: 24,backgroundColor: Colors.transparent,backgroundImage: AssetImage(massageController.pepoleimage[index])),
                      title: Text(massageController.pepolename[index],style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),overflow: TextOverflow.ellipsis),
                    trailing: Text(massageController.dates[index],style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 16,),
                    Text(massageController.qutes[index],style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),overflow: TextOverflow.ellipsis,maxLines: 1,)
                  ],
                ),
              );

            },),
            const SizedBox(height: 20,),

          ],
        ),
      ),
    );
  }
  Widget _buildui2({required double width}){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: notifire.getGry700_300Color),
        color: notifire.getBgColor
      ),
      child: Column(
        children: [
          const SizedBox(height: 20,),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  dense: true,
                  leading: const CircleAvatar(radius: 24,backgroundColor: Colors.transparent,backgroundImage: AssetImage("assets/images/02.png")),
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
                      width<1200? PopupMenuButton(
                        color: notifire.getDrawerColor,
                        constraints: const BoxConstraints(minWidth: 300,maxWidth: 300),
                        offset: const Offset(0, 50),
                        child:  Container(
                          height: 45,width: 45,decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: notifire.getGry700_300Color),
                        ),
                          child: Center(child: SvgPicture.asset("assets/images/dots-vertical.svg",height: 24,width: 24,)),
                        ),
                        itemBuilder: (context) {
                        return [PopupMenuItem(padding: const EdgeInsets.all(0),child: _buildui3())];
                      },):const SizedBox(),
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
          _builchatui1(contante: "You can convert the."),
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
    );
  }
  Widget _buildui3(){
    return Container(
      // height: 700,
      decoration: BoxDecoration(
          border: Border.all(color: notifire.getGry700_300Color),
          color: notifire.getBgColor
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 45,width: 45,decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: notifire.getGry700_300Color),
                  ),
                    child: Center(child: SvgPicture.asset("assets/images/plus.svg",height: 24,width: 24,)),
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              const CircleAvatar(radius: 70,backgroundColor: Colors.transparent,backgroundImage: AssetImage("assets/images/01.png"),),
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
              const SizedBox(height: 40,),
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
              const SizedBox(height: 20,),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      // width: 112,
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
                      // width: 112,
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
                      // width: 112,
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
                      // width: 112,
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
    );
  }
  Widget _builchatui({required String contante}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 120,
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
            child: Container(
              height: 120,),
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
            child:  Container(
              height: 125,),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 125,
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
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12),bottomRight: Radius.circular(12),bottomLeft: Radius.circular(4)),
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
