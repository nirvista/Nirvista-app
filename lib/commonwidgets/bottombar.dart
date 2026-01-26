import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';

class BottomBarr extends StatefulWidget {
  const BottomBarr({super.key});

  @override
  State<BottomBarr> createState() => _BottomBarrState();
}

class _BottomBarrState extends State<BottomBarr> {
  ColorNotifire notifire = ColorNotifire();
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Privacy Policy".tr,style: Typographyy.bodyMediumMedium.copyWith(color:  notifire.getGry600_500Color)),
          Text("Copyright 2023".tr,style: Typographyy.bodyMediumMedium.copyWith(color:  notifire.getGry600_500Color)),
        ],
      ),
    );
  }
}
