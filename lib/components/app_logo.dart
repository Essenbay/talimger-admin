import 'package:flutter/material.dart';
import 'package:increatorkz_admin/configs/app_config.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key, this.height, this.width, required this.imageString})
      : super(key: key);

  final double? height;
  final double? width;
  final String imageString;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 60,
      width: width ?? 140,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppConfig.themeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Image.asset(
        imageString,
        height: height ?? 60,
        width: width ?? 140,
      ),
    );
  }
}
