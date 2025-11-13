import 'package:alrayan_admin/features/coupons/presentation/views/widgets/create_coupon_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateCouponView extends StatelessWidget {
  const CreateCouponView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: CreateCouponViewBody()),
    );
  }
}
