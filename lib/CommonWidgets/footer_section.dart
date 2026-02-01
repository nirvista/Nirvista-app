import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Text(
        'Made with love by Nirvista',
        style: Typographyy.bodySmallMedium.copyWith(
          color: notifire.getTextColor.withOpacity(0.8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
