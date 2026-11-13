import 'package:flutter/material.dart';

/// El Rayan brand tokens (from the logo and launcher icon: signature red + navy).
/// This is the only design file that differs between the two brands.
class DsBrand {
  DsBrand._();
  static const primary = Color(0xFFE3000F);
  static const primaryPressed = Color(0xFFB8000C);
  static const primaryContainer = Color(0xFFFEECED);
  static const onPrimaryContainer = Color(0xFF1D1D2F);

  /// Highlights only ("new", notification dot) — El Rayan navy.
  static const accent = Color(0xFF1D1D2F);
  static const background = Color(0xFFF6F6F8);
}
