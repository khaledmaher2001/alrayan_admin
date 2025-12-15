import 'package:alrayan_admin/features/top_products/presentation/views/widgets/top_products_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopProductsView extends StatelessWidget {
  const TopProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: TopProductsViewBody()),
    );
  }
}
