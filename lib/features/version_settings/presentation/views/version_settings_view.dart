import 'package:alrayan_admin/features/version_settings/presentation/views/widgets/version_settings_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VersionSettingsView extends StatelessWidget {
  const VersionSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: VersionSettingsViewBody()),
    );
  }
}
