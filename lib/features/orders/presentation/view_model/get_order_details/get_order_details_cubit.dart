import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/orders_repo.dart';

part 'get_order_details_state.dart';

class GetOrderDetailsCubit extends Cubit<GetOrderDetailsState> {
  GetOrderDetailsCubit(this.repo) : super(GetOrderDetailsInitial());

  OrdersRepo repo;

  Future<void> getOrderDetails({
    required int orderId,
    bool withLoading = false,
  }) async {
    if (withLoading) {
      emit(GetOrderDetailsLoadingState());
    }
    final result = await repo.getOrderDetails(orderId: orderId);
    result.fold(
      (failure) {
        emit(GetOrderDetailsErrorState(failure.errMessage));
      },
      (data) {
        emit(GetOrderDetailsSuccessState(orderDetailsModel: data));
      },
    );
  }
}
