import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_orders_filter_sheet.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_orders_view_body.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة متابعة طلبات الدليفري — `GET /orders` بفلاتر الدليفري المدعومة
/// (status, paymentStatus, startDate, endDate, orderNumber, finished,
/// deliveryUserId, unassigned, sortBy, sortOrder).
class DeliveryOrdersView extends StatelessWidget {
  const DeliveryOrdersView({super.key, this.initialFilters});

  final Map<String, dynamic>? initialFilters;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = GetDeliveryOrdersCubit(getIt<OrdersRepoImpl>());
        if (initialFilters != null) cubit.setFilters(initialFilters!);
        cubit.getDeliveryOrders(withLoading: true);
        return cubit;
      },
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                DsTopBar(
                  title: "delivery_orders_title".tr(),
                  actions: [
                    DsIconButton(
                      icon: Icons.tune_rounded,
                      label: "filters".tr(),
                      onPressed: () => showDeliveryOrdersFilterSheet(
                        context: context,
                        ordersCubit: context.read<GetDeliveryOrdersCubit>(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DsSpace.xs),
                const Expanded(child: DeliveryOrdersViewBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
