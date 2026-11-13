import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:bloc/bloc.dart';

import 'get_awaiting_customer_orders_states.dart';

/// Dedicated cubit for the "طلبات بانتظار العميل" screen. Reuses `OrdersRepo`
/// / `GET /orders` with a fixed `status=awaiting_customer` filter and keeps
/// its own pagination/search state so the customer-facing Orders tab
/// (`GetOrdersCubit`) is never touched.
class GetAwaitingCustomerOrdersCubit
    extends Cubit<GetAwaitingCustomerOrdersStates> with RequestGuardMixin {
  GetAwaitingCustomerOrdersCubit(this.repo)
    : super(GetAwaitingCustomerOrdersInitState());

  final OrdersRepo repo;

  static const String status = 'awaiting_customer';

  List<Items> ordersList = [];
  OrdersModel? ordersModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  /// Inline search box query. `GET /orders` only filters by `orderNumber` on
  /// the server, so — to honor "search by order number / customer name /
  /// phone" — this matches all three but only over the currently loaded
  /// page(s); the UI discloses that limitation.
  String? clientSearchQuery;

  List<Items> get visibleOrders {
    final query = clientSearchQuery?.trim().toLowerCase();
    if (query == null || query.isEmpty) return ordersList;
    return ordersList.where((o) {
      final orderNumber = (o.orderNumber ?? '').toLowerCase();
      final customerName = (o.shippingAddress?.user?.fullName ?? '')
          .toLowerCase();
      final phone =
          '${o.shippingAddress?.phone1 ?? ''} ${o.shippingAddress?.phone2 ?? ''}'
              .toLowerCase();
      return orderNumber.contains(query) ||
          customerName.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  int get totalCount =>
      ordersModel?.data?.metadata?.totalItems ?? ordersList.length;

  Future<void> getOrders({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      ordersModel = null;
      ordersList.clear();
      page = 1;
      hasMore = true;
      emit(GetAwaitingCustomerOrdersLoadingState());
    }

    final pageToLoad = page;
    final result = await repo.getOrders(
      data: {
        'page': pageToLoad,
        'limit': 15,
        'status': status,
        'sortOrder': 'DESC',
      },
      cancelToken: requestCancelToken,
    );

    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) =>
          emit(GetAwaitingCustomerOrdersErrorState(failure.errMessage)),
      (data) {
        ordersModel = data;
        ordersList = ordersList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetAwaitingCustomerOrdersSuccessState(model: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || ordersModel == null) return;
    isLoadingMore = true;
    emit(GetAwaitingCustomerOrdersSuccessState(model: ordersModel!));
    page++;
    try {
      await getOrders(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (ordersModel != null) {
          emit(GetAwaitingCustomerOrdersSuccessState(model: ordersModel!));
        }
      }
    }
  }

  /// Reloads page 1 from the server without flipping the screen back to the
  /// full-screen loading state — used after a reopen/cancel so the list
  /// reflects backend truth even when the action response carried no data.
  Future<void> refreshSilently() async {
    final reqId = beginRequest();
    final result = await repo.getOrders(
      data: {'page': 1, 'limit': 15, 'status': status, 'sortOrder': 'DESC'},
      cancelToken: requestCancelToken,
    );

    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) =>
          emit(GetAwaitingCustomerOrdersErrorState(failure.errMessage)),
      (data) {
        page = 1;
        ordersModel = data;
        ordersList = data.data?.items ?? [];
        emit(GetAwaitingCustomerOrdersSuccessState(model: data));
      },
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }

  /// Drops an order from the list after a successful reopen / cancel and
  /// keeps the header counter in sync. If the backend response carried no
  /// fresh list data the caller should still reload from the server.
  void removeOrderLocally(int orderId) {
    final index = ordersList.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    ordersList.removeAt(index);
    final metadata = ordersModel?.data?.metadata;
    if (metadata?.totalItems != null && metadata!.totalItems! > 0) {
      metadata.totalItems = metadata.totalItems! - 1;
    }
    if (ordersModel != null) {
      emit(GetAwaitingCustomerOrdersSuccessState(model: ordersModel!));
    }
  }
}
