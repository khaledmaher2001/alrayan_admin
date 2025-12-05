import 'package:alrayan_admin/features/lucky_wheel/presentation/views/widgets/lucky_wheel_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LuckyWheelView extends StatelessWidget {
  const LuckyWheelView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: LuckyWheelViewBody()),
    );
  }
}
