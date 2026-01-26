// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorfile.dart';
import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';

class TextFilde extends StatefulWidget {

final String hinttext;
final bool suffixIconisture;
final String? icon;

  const TextFilde({super.key, required this.hinttext, required this.suffixIconisture, this.icon});

  @override
  State<TextFilde> createState() => _TextFildeState();
}

class _TextFildeState extends State<TextFilde> {
  ColorNotifire notifire = ColorNotifire();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SizedBox(
      height: 56,
      // width: 427,
      child: TextField(
        style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getWhitAndBlack),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius:  BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
          enabledBorder: OutlineInputBorder(borderRadius:  BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
          hintText: widget.hinttext.tr,
          hintStyle: Typographyy.bodyLargeRegular.copyWith(color: notifire.getGry600_500Color),
          suffixIcon: widget.suffixIconisture? SizedBox(
              width: 24,
              height: 24,
              child: Center(child: SvgPicture.asset(widget.icon!,height: 24,width: 24,color: greyscale600,))):const SizedBox(),

        ),
      ),
    );
  }
}
