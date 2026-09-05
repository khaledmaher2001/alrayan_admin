import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:bloc/bloc.dart';

class CancelOrderCubit extends Cubit<CancelOrderStates> {
  CancelOrderCubit(this.repo) : super(CancelOrderInitState());
  OrdersRepo? repo;

  /// [data] is forwarded verbatim as the request body — pass
  /// `{"reason": "..."}` where the cancel dialog collects one, or omit it to
  /// keep the previous no-body behaviour.
  Future<void> cancelOrder({
    required int orderId,
    Map<String, dynamic>? data,
  }) async {
    emit(CancelOrderLoadingState());

    var result = await repo!.cancelOrder(orderId: orderId, data: data);
    return result.fold(
      (failure) {
        emit(CancelOrderErrorState(error: failure.errMessage));
      },
      (data) {
        emit(CancelOrderSuccessState(message: data));
      },
    );
  }
}
