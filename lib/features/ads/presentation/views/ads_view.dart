import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdsView extends StatelessWidget {
  const AdsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: AdsViewBody()),
    );
  }
}
