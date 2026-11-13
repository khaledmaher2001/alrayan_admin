import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'dart:async';

import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:alrayan_admin/core/utils/services/local_services/local_notification_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/data/services/orders_socket_service.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

class GetOrdersCubit extends Cubit<GetOrdersStates> with RequestGuardMixin {
  GetOrdersCubit(this.repo) : super(GetOrdersInitState()) {
    _listenForNewOrders();
  }

  OrdersRepo? repo;

  List<Items> ordersList = [];
  OrdersModel? ordersModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  /// The status filter currently applied to [ordersList], kept in sync so a
  /// realtime order can be spliced into the list only when it belongs there.
  String? currentStatusFilter;

  /// Ids of orders that arrived over the realtime socket and haven't been
  /// opened yet — used to give them a distinct look in the list.
  final Set<int> newOrderIds = {};

  /// How many realtime orders landed per status since the last dashboard
  /// stats fetch — added on top of the (otherwise-stale) server counts so
  /// the status filter cards bump instantly instead of waiting on the next
  /// dashboard refresh.
  final Map<String, int> realtimeStatusDelta = {};

  StreamSubscription<Items>? _newOrderSubscription;

  /// Server-side matches for the search box: `GET /orders?search=` matches the
  /// order number, customer name or phone. The view also merges in matches from
  /// the loaded [ordersList] so results show while the request runs.
  List<Items> searchResults = [];
  String searchTerm = "";
  bool isSearchLoading = false;
  int _searchSeq = 0;
  CancelToken? _searchCancelToken;

  bool get hasUnseenNewOrders => newOrderIds.isNotEmpty;

  int deltaFor(String? status) {
    if (status == null) {
      return realtimeStatusDelta.values.fold(0, (sum, v) => sum + v);
    }
    return realtimeStatusDelta[status] ?? 0;
  }

  void _listenForNewOrders() {
    _newOrderSubscription = getIt<OrdersSocketService>().onOrderCreated.listen(
      _handleRealtimeOrderCreated,
    );
  }

  void _handleRealtimeOrderCreated(Items order) {
    if (order.id == null) return;
    if (ordersList.any((o) => o.id == order.id)) return;

    newOrderIds.add(order.id!);
    if (order.status != null) {
      realtimeStatusDelta[order.status!] =
          (realtimeStatusDelta[order.status!] ?? 0) + 1;
    }

    if (ordersModel != null &&
        (currentStatusFilter == null || currentStatusFilter == order.status)) {
      ordersList.insert(0, order);
      final metadata = ordersModel!.data?.metadata;
      if (metadata != null) {
        metadata.totalItems = (metadata.totalItems ?? 0) + 1;
      }
      emit(GetOrdersSuccessState(model: ordersModel!));
    }

    LocalNotificationService.showWithSound(
      title: "s_new_order".tr(),
      body: order.orderNumber != null
          ? "i_order_no_x_82".tr(namedArgs: {"a": "${order.orderNumber}"})
          : "s_a_new_order_just_arrived".tr(),
    );
  }

  /// Clears the "new" highlight for an order once the admin opens it.
  void markOrderSeen(int orderId) {
    if (newOrderIds.remove(orderId)) {
      if (ordersModel != null) emit(GetOrdersSuccessState(model: ordersModel!));
    }
  }

  /// Looks [query] up by order number on the server, within the current
  /// status filter. The caller debounces; an empty query clears the results.
  Future<void> searchOrders(String query) async {
    final term = query.trim();
    final seq = ++_searchSeq;
    _searchCancelToken?.cancel('superseded by search #$seq');
    _searchCancelToken = null;
    searchTerm = term;

    if (term.isEmpty) {
      searchResults = [];
      isSearchLoading = false;
      _emitCurrent();
      return;
    }

    isSearchLoading = true;
    _emitCurrent();
    final token = _searchCancelToken = CancelToken();
    final result = await repo!.getOrders(
      data: {
        "page": 1,
        "limit": 50,
        "search": term,
        if (currentStatusFilter != null) "status": currentStatusFilter,
        "sortOrder": "DESC",
      },
      cancelToken: token,
    );
    if (isClosed || seq != _searchSeq) return;

    isSearchLoading = false;
    result.fold(
      (failure) => searchResults = [],
      (data) => searchResults = data.data?.items ?? [],
    );
    _emitCurrent();
  }

  void _emitCurrent() {
    if (!isClosed && ordersModel != null) {
      emit(GetOrdersSuccessState(model: ordersModel!));
    }
  }

  void updateOrderStatusLocally(int orderId, String newStatus, {String? currentFilter}) {
    final searchIndex = searchResults.indexWhere((o) => o.id == orderId);
    if (searchIndex != -1) {
      if (currentFilter == null || currentFilter == newStatus) {
        searchResults[searchIndex].status = newStatus;
      } else {
        searchResults.removeAt(searchIndex);
      }
    }
    final index = ordersList.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      if (currentFilter == null || currentFilter == newStatus) {
        ordersList[index].status = newStatus;
      } else {
        ordersList.removeAt(index);
      }
      emit(GetOrdersSuccessState(model: ordersModel!));
    } else if (searchIndex != -1) {
      _emitCurrent();
    }
  }

  Future<void> getOrders({String? status, bool withLoading = true}) async {
    // Supersede any request still in flight: bump the generation and cancel its
    // socket so its response can neither be parsed nor merged below.
    final reqId = beginRequest();

    currentStatusFilter = status;
    if (withLoading) {
      ordersModel = null;
      ordersList.clear();
      page = 1;
      hasMore = true;
      emit(GetOrdersLoadingState());
      // Status filter changed (or refresh) mid-search: redo the server lookup for it.
      if (searchTerm.isNotEmpty) searchOrders(searchTerm);
    }
    final pageToLoad = page;
    var result = await repo!.getOrders(
      data: {
        "page": pageToLoad,
        if (status != null) "status": status,
        "sortOrder": "DESC",
      },
      cancelToken: requestCancelToken,
    );

    // A newer call started (or the cubit was closed) while we awaited — this
    // result is stale, drop it silently.
    if (!isCurrentRequest(reqId)) return;

    return result.fold(
      (failure) {
        emit(GetOrdersErrorState());
      },
      (data) {
        ordersModel = data;
        ordersList = ordersList + data.data!.items!;
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetOrdersSuccessState(model: data));
      },
    );
  }

  /// Loads the next page for the currently applied status filter. Pagination
  /// bookkeeping stays here so a filter switch mid-scroll can't be raced by a
  /// stale page append (handled by [RequestGuardMixin]).
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || ordersModel == null) return;
    isLoadingMore = true;
    emit(GetOrdersSuccessState(model: ordersModel!));
    page++;
    try {
      await getOrders(status: currentStatusFilter, withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (ordersModel != null) {
          emit(GetOrdersSuccessState(model: ordersModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    _searchCancelToken?.cancel('cubit closed');
    _newOrderSubscription?.cancel();
    return super.close();
  }
}
