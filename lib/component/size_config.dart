import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockWidth = 0.0;
  static double blockHeight = 0.0;
  static double blockHeightB = 0.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    print(screenHeight / screenWidth);
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
    blockHeightB = screenHeight / 100;
    if (screenHeight / screenWidth >= 1.7 && screenHeight / screenWidth < 1.8) {
      blockHeight = screenHeight / 110;
    } else if (screenHeight / screenWidth >= 1.8 && screenHeight / screenWidth < 1.9) {
      blockHeight = screenHeight / 114;
    } else if (screenHeight / screenWidth >= 1.9 && screenHeight / screenWidth < 2) {
      blockHeight = screenHeight / 116;
    } else if (screenHeight / screenWidth >= 2 && screenHeight / screenWidth < 2.1) {
      blockHeight = screenHeight / 118;
    } else if (screenHeight / screenWidth >= 2.1) {
      blockHeight = screenHeight / 120;
    }
  }
}