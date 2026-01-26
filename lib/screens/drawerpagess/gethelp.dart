// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../commonwidgets/applogo.dart';


class GetHelp extends StatefulWidget {
  const GetHelp({super.key});

  @override
  State<GetHelp> createState() => _GetHelpState();
}

class _GetHelpState extends State<GetHelp> {
  ColorNotifire notifire = ColorNotifire();
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: notifire.getBgColor,


      child: LayoutBuilder(
        builder: (context, constraints) {
         if(constraints.maxWidth<800){
           return  SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 15),
               child: Column(
                 children: [
                   _buildCompo1(),
                   const SizedBox(height: 15,),
                   _buildCompo2(),

               ],),
             ),
           );
         }else{
           return SingleChildScrollView(
             child: Column(
               children: [
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 15),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                   Expanded(
                     flex: 3,
                     child:  _buildCompo1(),
                   ),
                  SizedBox(
                      height: Get.height,
                      child: VerticalDivider(width: 80,color: notifire.getGry700_300Color)),
                   Expanded(
                     flex: 5,
                     child: _buildCompo2(),
                   ),

                 ],),
               )

             ],),
           );
         }
      },),
    );
  }
int select = 0;

  List icons = [
    "assets/images/card-send.svg",
    "assets/images/user.svg",
    "assets/images/dollar-circle.svg",
    "assets/images/briefcase.svg",
  ];

  List title = [
    "Sending Money",
    "Your Account",
    "Sell Token",
    "Nirvista Business",
  ];


  Widget _buildCompo1(){
    return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  // height: 300,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("How can we help you?",style: Typographyy.heading4.copyWith(color: notifire.getTextColor),),
                    const SizedBox(height: 8,),
                    Text(
                      "Will give with FAQs. FAQs will be provided later.",
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    ),
                    const SizedBox(height: 32,),
                    TextField(
                      style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        prefixIcon: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(child: SvgPicture.asset("assets/images/Search.svg",height: 20,width: 20,color: notifire.getGry500_600Color ,))),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                        disabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                        isDense: true,
                        hintText: "Search...",
                        hintStyle: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getGry500_600Color),
                      ),
                    ),
                    const SizedBox(height: 24,),
                    Text("Popular search:",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),),
                    const SizedBox(height: 12,),

                    Wrap(
                      runSpacing: 12,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: priMeryColor),
                          ),
                            padding: const EdgeInsets.all(10),
                            child: Text("Send Money",style: Typographyy.bodySmallSemiBold.copyWith(color: priMeryColor))),
                        const SizedBox(width: 12,),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: priMeryColor),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text("Transfer",style: Typographyy.bodySmallSemiBold.copyWith(color: priMeryColor))),
                        const SizedBox(width: 12,),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: priMeryColor),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text("Change Card",style: Typographyy.bodySmallSemiBold.copyWith(color: priMeryColor))),

                      ],
                    ),



                  ],
                ),
                ),
              )
            ],
          ),

          ListView.builder(
            shrinkWrap: true,
            itemCount: title.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                select = index;
                });
              },
              child: Container(
                height: 96,
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: select == index? priMeryColor :  notifire.getGry700_300Color),
                ),
                child: Center(
                  child: ListTile(
                    leading: CircleAvatar(radius: 24,backgroundColor: select ==index? priMeryColor : notifire.getGry50_800Color,child:  SvgPicture.asset(icons[index],height: 20,width: 20,color:  select ==index? Colors.white : notifire.getTextColor,)),
                      trailing: SvgPicture.asset("assets/images/chevron-right.svg",height: 20,width: 20,color: notifire.getGry500_600Color),
                      subtitle: Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum",style: Typographyy.bodySmallRegular.copyWith(color: notifire.getGry500_600Color),maxLines: 3, overflow: TextOverflow.ellipsis,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(title[index],style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getTextColor),),
                      )),
                  ),
                ),
              );
            },
          ),
    ]);
  }

  Widget _buildCompo2(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24,),
      Text("Nirvista Money",style: Typographyy.heading4.copyWith(color: notifire.getTextColor),),
      const SizedBox(height: 8,),
      Text("Holding balances, setting up cards debits, and using assets",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color)),
      const SizedBox(height: 48,),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        shrinkWrap: true,
        itemBuilder: (context, index) {
        return Container(
          // height: 180,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifire.getGry700_300Color),
          ),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Why can’t I open balance?",style: Typographyy.heading6.copyWith(color: notifire.getTextColor),),
              const SizedBox(height: 12,),
              Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),maxLines: 3,overflow: TextOverflow.ellipsis,),
              const SizedBox(height: 30,),
              Row(
                children: [
                  const AppLogo(size: 48),
                  const SizedBox(width: 8,),
                  Text("Nirvista",style: Typographyy.bodyMediumExtraBold.copyWith(color: notifire.getTextColor),),
                  const Spacer(),
                  SvgPicture.asset("assets/images/tabler_tag.svg",width: 20,height: 20),
                  const SizedBox(width: 8,),
                  Text("Balance",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),),
                  const SizedBox(width: 16,),
                  SvgPicture.asset("assets/images/ike-outlined.svg",width: 20,height: 20),
                  const SizedBox(width: 8,),
                  Text("29",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),),
                ],
              )
            ],
          ),
        );
      },),

    ]);
  }
}
