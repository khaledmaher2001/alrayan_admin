import 'package:bloc/bloc.dart';

import '../../../data/repo/luck_wheel_repo.dart';
import 'create_coupon_states.dart';

class CreateLuckyItemCubit extends Cubit<CreateLuckyItemStates> {
  CreateLuckyItemCubit(this.luckyWheelRepo) : super(CreateLuckyItemInitState());
  LuckyWheelRepo? luckyWheelRepo;

  Future<void> createLuckyItem({required Map<String, dynamic> data}) async {
    emit(CreateLuckyItemLoadingState());
    var result = await luckyWheelRepo!.createLuckyItem(data: data);
    return result.fold(
      (failure) {
        emit(CreateLuckyItemErrorState(error: failure.errMessage));
      },
      (data) {
        emit(CreateLuckyItemSuccessState(message: data));
      },
    );
  }
}
