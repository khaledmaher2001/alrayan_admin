import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/awaiting_customer_orders_view_body.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_awaiting_customer_orders/get_awaiting_customer_orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة "طلبات بانتظار العميل" — الطلبات التي حرّرها عامل التوصيل لتعذّر
/// الوصول للعميل، وتحتاج تدخّل الإدارة. `GET /orders?status=awaiting_customer`.
class AwaitingCustomerOrdersView extends StatelessWidget {
  const AwaitingCustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetAwaitingCustomerOrdersCubit(getIt<OrdersRepoImpl>())
            ..getOrders(withLoading: true),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: DsSpace.sm),
              const Expanded(child: AwaitingCustomerOrdersViewBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DsTopBar(title: "s_orders_waiting_for_the_customer".tr(), subtitle: "s_orders_released_by_the_courier_becau".tr());
  }
}
