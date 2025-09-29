import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
import 'package:bloc/bloc.dart';

class GetOrdersCubit extends Cubit<GetOrdersStates> {
  GetOrdersCubit(this.repo) : super(GetOrdersInitState());
  OrdersRepo? repo;

  List<Items> ordersList = [];
  OrdersModel? ordersModel;
  int page = 1;

  Future<void> getOrders({String? status, bool withLoading = true}) async {
    if (withLoading) {
      ordersModel = null;
      ordersList.clear();
      page = 1;
      emit(GetOrdersLoadingState());
    }
    var result = await repo!.getOrders(data: {"page": page, if (status != null) "status": status});
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
}
