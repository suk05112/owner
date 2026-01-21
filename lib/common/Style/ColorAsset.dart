import 'package:flutter/material.dart';

class ColorAssset {
  static const Color mainColor = Color(0xFFFE7831);
  static const Color bankBackground = Color(0xffFAFAFC);
  static const Color greyBackground = Color.fromARGB(255, 232, 232, 232);

  // static final Color mainColor = hexToColor('#FF4C4C)');

  static Color hexToColor(String hexString) {
    String hexStr = hexString.replaceAll('#', '');
    if (hexStr.length == 6) {
      hexStr = "0xFF" + hexStr;
    }
    return Color(int.parse(hexStr, radix: 16));
  }
}
