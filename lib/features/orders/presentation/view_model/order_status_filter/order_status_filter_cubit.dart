import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_states.dart';
import 'package:bloc/bloc.dart';

class OrderStatusFilterCubit extends Cubit<OrderStatusFilterStates> {
  OrderStatusFilterCubit() : super(OrderStatusFilterInitState());

  List<String?> status = [null, "pending", "confirmed", "shipped", "delivered", "cancelled", "refunded"];

  // Open on "الكل" (all statuses) by default, like the dashboard — an empty
  // "pending" tab looked like there were no orders at all.
  int selectedFilterIndex = 0;

  void selectIndex({required int index}) {
    selectedFilterIndex = index;
    emit(OrderStatusFilterSuccessState());
  }
}
