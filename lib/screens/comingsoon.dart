import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';
import '../controller/drawercontroller.dart';
import 'appbarcode.dart';
import 'drawercode.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    Get.put(DrawerControllerr());
    
    return Scaffold(
      backgroundColor: notifire.getBgColor,
      drawer: const DrawerCode(),
      appBar: const AppBarCode(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: notifire.getBgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 100,
                color: notifire.getGry500_600Color,
              ),
              const SizedBox(height: 20),
              Text(
                "Coming Soon",
                style:
                    Typographyy.heading3.copyWith(color: notifire.getTextColor),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "This feature is not available for the selected region yet.",
                  style: Typographyy.bodyLargeMedium
                      .copyWith(color: notifire.getGry500_600Color),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
