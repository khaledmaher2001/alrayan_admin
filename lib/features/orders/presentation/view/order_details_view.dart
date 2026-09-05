import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_details_view_body.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/orders_model.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({
    super.key,
    required this.orderData,
    this.onStatusChanged,
  });

  final Items orderData;
  final void Function(int id, String newStatus)? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocProvider(
        create: (_) => GetOrderDetailsCubit(getIt<OrdersRepoImpl>())
          ..getOrderDetails(orderId: orderData.id!),
        child: Scaffold(
          body: OrderDetailsViewBody(
            orderData: orderData,
            onStatusChanged: onStatusChanged,
          ),
        ),
      ),
    );
  }
}
