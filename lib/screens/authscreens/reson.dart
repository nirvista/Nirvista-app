import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../CommonWidgets/applogo.dart';
import '../../CommonWidgets/bottombar.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';

class ResonPage extends StatefulWidget {
  const ResonPage({super.key});

  @override
  State<ResonPage> createState() => _ResonPageState();
}

class _ResonPageState extends State<ResonPage> {
  ColorNotifire notifire = ColorNotifire();
  int selectedCard = -1;
  DrawerControllerr contoller = Get.put(DrawerControllerr());
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            bottomNavigationBar: const BottomBarr(),
            backgroundColor: notifire.getBgColor,
            appBar:constraints.maxWidth<600? appBar(isphone: true) :PreferredSize(

                preferredSize:  const Size.fromHeight(80),
                child: appBar(isphone: false)
            ),
            body:  SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          width: 510,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                 SizedBox(height: constraints.maxWidth<600? 15 :40,),
                                Text("Tell us your main reason for using Nirvista?".tr,style: Typographyy.heading3.copyWith(color: notifire.getWhitAndBlack),overflow: TextOverflow.ellipsis,maxLines: 3,textAlign: TextAlign.center),
                                const SizedBox(height: 16,),
                                Text("Tell us about the current situation and we will make the right recommendations for you".tr,style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getGry500_600Color),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,maxLines: 3),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: constraints.maxWidth<600? 0 :56,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: 800,
                          child: GridView.builder(gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: constraints.maxWidth<720? 2 :4 ,mainAxisExtent: 200,),
                            itemCount: icon.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GetBuilder<DrawerControllerr>(
                                builder: (contoller) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                      selectedCard = index;
                                      });
                                      Future.delayed(const Duration(milliseconds: 500),() {
                                         Get.offAllNamed("/dashboard");
                                         contoller.function(value: -1);
                                         contoller.colorSelecter(value: 0);
                                      },);
                                    },
                                    child: Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color:  selectedCard == index ? Colors.transparent :notifire.isDark? Colors.transparent :notifire.getBorderColor),
                                      color: selectedCard == index?  priMeryColor :notifire.getContainerColor,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration:  BoxDecoration(shape: BoxShape.circle,
                                            color:  selectedCard == index? Colors.white : notifire.getContainerColor2

                                            ),
                                            height: 56,

                                            width: 56,
                                            child: Center(child: SvgPicture.asset(icon[index],)),
                                          ),
                                          const SizedBox(height: 24,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Text(title[index].toString().tr,style: Typographyy.bodyLargeSemiBold.copyWith(color: selectedCard == index? Colors.white : notifire.getWhitAndBlack)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              ),
                            );
                          },),
                        ),
                      ),
                    ],
                  )
                  // SizedBox(height: 200),

                ],

              ),
            ),
          );
        }
    );
  }
  PreferredSizeWidget appBar({required bool isphone}){
    return AppBar(
      toolbarHeight: isphone? 52 : 120.0,
      actions: [
        Padding(
          padding:  EdgeInsets.symmetric(vertical: isphone? 8 : 12),
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: priMeryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                fixedSize:  Size(isphone?100:156, isphone? 30 : 50),
              ),
              child: Center(child: Text("Sing In",style: Typographyy.bodyLargeSemiBold.copyWith(color: Colors.white,fontWeight: FontWeight.w400),))),
        ),
        const SizedBox(width: 10,),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: notifire.getAppBarColor,
      centerTitle: false,
      title: isphone? const AppLogo(textColor: Colors.white,size: 80,):  const AppLogo(textColor: Colors.white,),
    );
  }
}
