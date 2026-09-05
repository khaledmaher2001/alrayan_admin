import 'dart:async';

import 'package:alrayan_admin/core/utils/services/local_services/local_notification_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/data/services/orders_socket_service.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
import 'package:bloc/bloc.dart';

class GetOrdersCubit extends Cubit<GetOrdersStates> {
  GetOrdersCubit(this.repo) : super(GetOrdersInitState()) {
    _listenForNewOrders();
  }

  OrdersRepo? repo;

  List<Items> ordersList = [];
  OrdersModel? ordersModel;
  int page = 1;

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
      title: "طلب جديد",
      body: order.orderNumber != null
          ? "رقم الطلب: ${order.orderNumber}"
          : "وصل طلب جديد الآن",
    );
  }

  /// Clears the "new" highlight for an order once the admin opens it.
  void markOrderSeen(int orderId) {
    if (newOrderIds.remove(orderId)) {
      if (ordersModel != null) emit(GetOrdersSuccessState(model: ordersModel!));
    }
  }

  void updateOrderStatusLocally(int orderId, String newStatus, {String? currentFilter}) {
    final index = ordersList.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      if (currentFilter == null || currentFilter == newStatus) {
        ordersList[index].status = newStatus;
      } else {
        ordersList.removeAt(index);
      }
      emit(GetOrdersSuccessState(model: ordersModel!));
    }
  }

  Future<void> getOrders({String? status, bool withLoading = true}) async {
    currentStatusFilter = status;
    if (withLoading) {
      ordersModel = null;
      ordersList.clear();
      page = 1;
      emit(GetOrdersLoadingState());
    }
    var result = await repo!.getOrders(data: {
      "page": page,
      if (status != null) "status": status,
      "sortOrder": "DESC",
    });
    return result.fold(
      (failure) {
        emit(GetOrdersErrorState());
      },
      (data) {
        ordersModel = data;
        ordersList = ordersList + data.data!.items!;
        emit(GetOrdersSuccessState(model: data));
      },
    );
  }

  @override
  Future<void> close() {
    _newOrderSubscription?.cancel();
    return super.close();
  }
}
