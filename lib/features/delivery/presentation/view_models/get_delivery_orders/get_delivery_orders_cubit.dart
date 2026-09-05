import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:bloc/bloc.dart';

import 'get_delivery_orders_states.dart';

/// Dedicated cubit for the "طلبات الدليفري" screen. Reuses `OrdersRepo` /
/// `GET /orders` (same endpoint the customer-facing Orders tab uses) but
/// keeps its own filter/pagination state so the existing `GetOrdersCubit`
/// and Orders tab are never touched.
class GetDeliveryOrdersCubit extends Cubit<GetDeliveryOrdersStates> {
  GetDeliveryOrdersCubit(this.repo) : super(GetDeliveryOrdersInitState());

  final OrdersRepo repo;

  List<Items> ordersList = [];
  OrdersModel? ordersModel;
  int page = 1;

  /// Current server-supported filters. Keys map 1:1 to the documented
  /// `GET /orders` query params.
  Map<String, dynamic> filters = {};

  /// `GET /orders` has no server-side filter for delivery stage — this is
  /// applied client-side, on the currently loaded page only, and the UI
  /// discloses that explicitly rather than pretending it's a full filter.
  String? clientDeliveryStageFilter;

  /// The inline search box's query. The server only supports filtering by
  /// `orderNumber`, not customer name, so — to honor the "search by order
  /// number OR customer name" hint — this matches against both fields but
  /// only over the currently loaded page(s), same disclosed limitation as
  /// [clientDeliveryStageFilter].
  String? clientSearchQuery;

  List<Items> get visibleOrders {
    var list = ordersList;
    if (clientDeliveryStageFilter != null) {
      list = list
          .where((o) => o.deliveryStage == clientDeliveryStageFilter)
          .toList();
    }
    final query = clientSearchQuery?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      list = list.where((o) {
        final orderNumber = (o.orderNumber ?? '').toLowerCase();
        final customerName =
            (o.shippingAddress?.user?.fullName ?? '').toLowerCase();
        return orderNumber.contains(query) || customerName.contains(query);
      }).toList();
    }
    return list;
  }

  Future<void> getDeliveryOrders({bool withLoading = true}) async {
    if (withLoading) {
      ordersModel = null;
      ordersList.clear();
      page = 1;
      emit(GetDeliveryOrdersLoadingState());
    }

    final result = await repo.getOrders(
      data: {'page': page, 'limit': 12, 'sortOrder': 'DESC', ...filters},
    );

    result.fold(
      (failure) => emit(GetDeliveryOrdersErrorState(failure.errMessage)),
      (data) {
        ordersModel = data;
        ordersList = ordersList + (data.data?.items ?? []);
        emit(GetDeliveryOrdersSuccessState(model: data));
      },
    );
  }

  void setFilters(Map<String, dynamic> newFilters) {
    filters = newFilters;
  }

  void updateOrderLocally(Items updated) {
    final index = ordersList.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      ordersList[index] = updated;
      if (ordersModel != null) {
        emit(GetDeliveryOrdersSuccessState(model: ordersModel!));
      }
    }
  }
}
