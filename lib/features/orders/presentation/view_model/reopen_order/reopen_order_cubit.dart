import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/reopen_order/reopen_order_states.dart';
import 'package:bloc/bloc.dart';

class ReopenOrderCubit extends Cubit<ReopenOrderStates> {
  ReopenOrderCubit(this.repo) : super(ReopenOrderInitState());

  OrdersRepo? repo;

  Future<void> reopenOrder({required int orderId}) async {
    emit(ReopenOrderLoadingState());
    final result = await repo!.reopenOrder(orderId: orderId);
    return result.fold(
      (failure) => emit(ReopenOrderErrorState(error: failure.errMessage)),
      (message) => emit(ReopenOrderSuccessState(message: message)),
    );
  }
}
