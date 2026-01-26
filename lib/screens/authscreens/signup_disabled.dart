import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';

class SignupDisabledScreen extends StatelessWidget {
  const SignupDisabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getBgColor,
      appBar: AppBar(
        backgroundColor: notifire.getBgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getTextColor),
        title: Text(
          'Sign Up Disabled',
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account creation is currently closed.',
              style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 12),
            Text(
              'For any assistance or if you need access, contact support using the email or phone below:',
              style:
                  Typographyy.bodyLargeMedium.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 24),
            Text('support@nirvista.in',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const SizedBox(height: 8),
            Text('support@nirvistagroup.com',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const SizedBox(height: 8),
            Text('Phone: 97656 53615',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const Spacer(),
            Text(
              'We appreciate your interest. Please check back later.',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
          ],
        ),
      ),
    );
  }
}
