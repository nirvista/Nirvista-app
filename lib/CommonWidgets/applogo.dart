import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final Color? logoColor;
  final Color? textColor;
  final double? size;
  final double? width;

  const AppLogo(
      {super.key, this.logoColor, this.textColor, this.size, this.width});

  @override
  Widget build(BuildContext context) {
    final height = size ?? 56;
    final targetWidth = width ?? height * 4.2;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : targetWidth;
        final resolvedWidth =
            maxWidth < targetWidth ? maxWidth : targetWidth;
        return SizedBox(
          height: height,
          width: resolvedWidth,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 0.8,
                heightFactor: 0.14,
                child: Image.asset(
                  "assets/images/nivista logo.png",
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
