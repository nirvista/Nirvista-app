import 'package:flutter/material.dart';
import '../../../ConstData/typography.dart';
import '../../../ConstData/colorfile.dart';

class SellStep1 extends StatelessWidget {
  const SellStep1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWithOpacity(priMeryColor, 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Sell flow has been simplified. Continue to next step.",
        style:
            Typographyy.bodyMediumMedium.copyWith(color: priMeryColor),
      ),
    );
  }
}
