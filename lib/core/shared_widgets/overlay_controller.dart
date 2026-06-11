import 'package:flutter/material.dart';

class InternetOverlayController {
  static final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);

  static void show() => isOffline.value = true;
  static void hide() => isOffline.value = false;
}