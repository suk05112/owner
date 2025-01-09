import 'package:flutter/material.dart';

class ColorAssset {
  static const Color mainColor = Color(0xffFF4c4c);
  static const Color bankBackground = Color(0xffFAFAFC);

  // static final Color mainColor = hexToColor('#FF4C4C)');

  static Color hexToColor(String hexString) {
    String hexStr = hexString.replaceAll('#', '');
    if (hexStr.length == 6) {
      hexStr = "0xFF" + hexStr;
    }
    return Color(int.parse(hexStr, radix: 16));
  }
}
