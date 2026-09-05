import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/loyalty_settings_view_body.dart';

class LoyaltySettingsView extends StatelessWidget {
  const LoyaltySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: const Scaffold(body: LoyaltySettingsViewBody()),
    );
  }
}
