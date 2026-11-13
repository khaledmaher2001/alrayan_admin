import 'package:alrayan_admin/core/design/brand.dart';
import 'package:flutter/material.dart';

class AppColors {



  static const Color primarySwatchColor = Color(0xFFE3000F);
  // Brand deep shade: fills that carry white text/icons (avatars, small tiles).
  // The orange accent is reserved for highlights (badges, unseen dots) — see DsBrand.accent.
  static const Color secondaryColor = DsBrand.onPrimaryContainer;
  static const Color lightGreen = Color(0xFFFF4D58);

  // Neutral Colors
  static const Color darkColor = Color(0xFF1D1D2F);
  static const Color gray = Color(0xFF6B7280);
  static const Color background = DsBrand.background;
  static const Color white = Color(0xFFFFFFFF);

  // Status Colors
  static const Color redColor = Color(0xFFB91C1C);

  static const MaterialColor primaryColor =
  MaterialColor(0xFFE3000F, <int, Color>{
    50: Color(0xFFFEECED),
    100: Color(0xFFFCD2D5),
    200: Color(0xFFF8A4A9),
    300: Color(0xFFF1666E),
    400: Color(0xFFE9333E),
    500: Color(0xFFE3000F),
    600: Color(0xFFC8000D),
    700: Color(0xFFB8000C),
    800: Color(0xFF8E0009),
    900: Color(0xFFE3000F),
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
