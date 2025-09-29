import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_states.dart';
import 'package:bloc/bloc.dart';

class ChangeOrderStatusCubit extends Cubit<ChangeOrderStatusStates> {
  ChangeOrderStatusCubit(this.repo) : super(ChangeOrderStatusInitState());
  OrdersRepo? repo;

  Future<void> changeOrderStatus({required int orderId, required Map<String, dynamic> data}) async {
    emit(ChangeOrderStatusLoadingState());

    var result = await repo!.changeOrderStatus(orderId: orderId, data: data);
    return result.fold(
      (failure) {
        emit(ChangeOrderStatusErrorState(error: failure.errMessage));
      },
      (data) {
        emit(ChangeOrderStatusSuccessState(message: data));
      },
    );
  }
}
