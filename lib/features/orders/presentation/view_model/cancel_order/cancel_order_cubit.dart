import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:bloc/bloc.dart';

class CancelOrderCubit extends Cubit<CancelOrderStates> {
  CancelOrderCubit(this.repo) : super(CancelOrderInitState());
  OrdersRepo? repo;


  Future<void> cancelOrder({required int orderId}) async {
    emit(CancelOrderLoadingState());

    var result = await repo!.cancelOrder(orderId:orderId );
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
