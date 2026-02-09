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
          'Direct Signup Disabled',
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account creation is currently restricted.',
              style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 16),
            Text(
              'New user registrations are allowed only via a referral link shared by existing community members or token holders.',
              style: Typographyy.bodyLargeMedium.copyWith(
                  color: notifire.getTextColor, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              'If you do not have a referral link, please contact our support team using the details below.',
              style: Typographyy.bodyLargeMedium.copyWith(
                  color: notifire.getTextColor, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Our team will assist you with access.',
              style: Typographyy.bodyLargeMedium.copyWith(
                  color: notifire.getTextColor, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Support Email:',
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            const SizedBox(height: 8),
            Text('support@nirvista.in',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const SizedBox(height: 8),
            Text('support@nirvistagroup.com',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const SizedBox(height: 16),
            Text(
              'Phone:',
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            const SizedBox(height: 8),
            Text('97656 53615',
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor)),
            const Spacer(),
            Text(
              '© 2026 Nirvista. All rights reserved. Access subject to eligibility',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
          ],
        ),
      ),
    );
  }
}
