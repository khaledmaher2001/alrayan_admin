import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_states.dart';
import 'package:bloc/bloc.dart';

class OrderStatusFilterCubit extends Cubit<OrderStatusFilterStates> {
  OrderStatusFilterCubit() : super(OrderStatusFilterInitState());

  List<String?> status = [null, "pending", "confirmed", "shipped", "delivered", "cancelled", "refunded"];

  // Open on "pending" by default — that's where newly-arrived orders land,
  // instead of "الكل" which buries them among everything else.
  int selectedFilterIndex = 1;

  void selectIndex({required int index}) {
    selectedFilterIndex = index;
    emit(OrderStatusFilterSuccessState());
  }
}
