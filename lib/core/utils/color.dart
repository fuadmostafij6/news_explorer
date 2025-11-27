import 'dart:ui';

class AppColor {
  AppColor._();
  // #1279E1, #FFFFFF, #888F9B, #172D36,
  static Color scaffoldBgColor = hexToColor("#101922");
  static Color scaffoldDimBgColor = hexToColor("#172D36");
  static Color textColor = hexToColor("#FFFFFF");
  static Color textDimColor = hexToColor("#888F9B");
  static Color blueColor = hexToColor("#1279E1");

  static Color hexToColor(String hex) {
    assert(
      RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
      'hex color must be #rrggbb or #rrggbbaa',
    );

    return Color(
      int.parse(hex.substring(1), radix: 16) +
          (hex.length == 7 ? 0xff000000 : 0x00000000),
    );
  }
}
