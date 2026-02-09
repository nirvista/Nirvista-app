import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';
import '../screens/drawerpagess/termsandcondition/policy_detail.dart';

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
          InkWell(
            onTap: () => Get.to(
                () => const PolicyDetailScreen(policyTitle: 'PRIVACY POLICY')),
            child: Text("Privacy Policy".tr,
                style: Typographyy.bodyMediumMedium
                    .copyWith(color: notifire.getGry600_500Color)),
          ),
          Text(
            "© 2026 Nirvista. All rights reserved. Access subject to eligibility"
                .tr,
            style: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry600_500Color),
          ),
        ],
      ),
    );
  }
}
