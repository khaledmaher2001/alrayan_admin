import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/details_loader_scaffold.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens an order's details when only its id is known (push notification):
/// fetches `GET orders/{id}`, then shows the usual [OrderDetailsView].
class OrderDetailsLoaderView extends StatelessWidget {
  const OrderDetailsLoaderView({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetOrderDetailsCubit(getIt<OrdersRepoImpl>())..getOrderDetails(orderId: orderId, withLoading: true),
      child: BlocConsumer<GetOrderDetailsCubit, GetOrderDetailsState>(
        listenWhen: (_, state) => state is GetOrderDetailsSuccessState,
        listener: (context, _) => context.read<GetOrdersCubit>().markOrderSeen(orderId),
        builder: (context, state) {
          if (state is GetOrderDetailsSuccessState) {
            final ordersCubit = context.read<GetOrdersCubit>();
            final filterCubit = context.read<OrderStatusFilterCubit>();
            return OrderDetailsView(
              orderData: state.orderDetailsModel,
              onStatusChanged: (id, newStatus) => ordersCubit.updateOrderStatusLocally(
                id,
                newStatus,
                currentFilter: filterCubit.status[filterCubit.selectedFilterIndex],
              ),
            );
          }
          return DetailsLoaderScaffold(
            title: "order_details_title".tr(),
            body: state is GetOrderDetailsErrorState
                ? LoadErrorView(
                    message: state.error,
                    onRetry: () => context.read<GetOrderDetailsCubit>().getOrderDetails(orderId: orderId, withLoading: true),
                  )
                : const CustomLoadingItem(),
          );
        },
      ),
    );
  }
}
