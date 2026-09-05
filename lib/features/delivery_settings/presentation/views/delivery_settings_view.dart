import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/delivery_settings_view_body.dart';

class DeliverySettingsView extends StatelessWidget {
  const DeliverySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: const Scaffold(body: DeliverySettingsViewBody()),
    );
  }
}
