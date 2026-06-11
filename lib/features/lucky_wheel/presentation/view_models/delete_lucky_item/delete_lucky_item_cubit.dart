import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/luck_wheel_repo.dart';

part 'delete_lucky_item_state.dart';

class DeleteLuckyItemCubit extends Cubit<DeleteLuckyItemState> {
  DeleteLuckyItemCubit(this.repo) : super(DeleteLuckyItemInitial());

  LuckyWheelRepo repo;

  int? deletingItemId;

  Future<void> deleteLuckyItem({required int itemId}) async {
    deletingItemId = itemId;
    emit(DeleteLuckyItemLoadingState());

    final result = await repo.deleteLuckyItem(itemId: itemId);
    result.fold(
      (failure) {
        deletingItemId = null;
        emit(DeleteLuckyItemErrorState(failure.errMessage));
      },
      (data) async {
        deletingItemId = null;
        emit(DeleteLuckyItemSuccessState(data));
      },
    );
  }
}
