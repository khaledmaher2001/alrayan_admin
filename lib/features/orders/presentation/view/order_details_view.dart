import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_details_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/orders_model.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.orderData});
final Items orderData;
  @override
  Widget build(BuildContext context) {
    return  AnnotatedRegion(
      value:  SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: OrderDetailsViewBody(
          orderData: orderData,
        ),
      ),
    );
  }
}
