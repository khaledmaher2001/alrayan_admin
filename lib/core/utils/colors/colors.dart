import 'package:flutter/material.dart';

class AppColors {
  static const Color primarySwatchColor = Color(0xffe3000f);
  static const Color secondaryColor = Color(0xff1D1D2F);
  static const Color gray = Color(0xff98999A);
  static const Color redColor = Color(0xffC32B43);

  static MaterialColor primaryColor =
  const MaterialColor(0xFFe3000f, <int, Color>{
    50: Color(0x1Ae3000f),
    100: Color(0x33e3000f),
    200: Color(0x4De3000f),
    300: Color(0x66e3000f),
    400: Color(0x80e3000f),
    500: Color(0x99e3000f),
    600: Color(0xB3e3000f),
    700: Color(0xCCe3000f),
    800: Color(0xE6e3000f),
    900: Color(0xFFe3000f),
  });
  static MaterialColor greyColor = const MaterialColor(0xff121212, <int, Color>{
    50: Color(0xffFAFAFA),
    100: Color(0xffF5F5F5),
    200: Color(0xffE8E8E8),
    300: Color(0xffD6D6D6),
    400: Color(0xffB8B8B8),
    500: Color(0xffA6A6A6),
    600: Color(0xff7A7A7A),
    700: Color(0xff454545),
    800: Color(0xff292929),
    900: Color(0xff121212),
  });
}
