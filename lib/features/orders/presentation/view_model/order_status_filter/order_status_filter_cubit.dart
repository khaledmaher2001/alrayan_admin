import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_states.dart';
import 'package:bloc/bloc.dart';

class OrderStatusFilterCubit extends Cubit<OrderStatusFilterStates> {
  OrderStatusFilterCubit() : super(OrderStatusFilterInitState());

  int selectedFilterIndex = 0;

  void selectIndex({required int index}) {
    selectedFilterIndex = index;
    emit(OrderStatusFilterSuccessState());
  }
}
