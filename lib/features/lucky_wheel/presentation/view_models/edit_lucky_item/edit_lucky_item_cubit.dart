import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/luck_wheel_repo.dart';

part 'edit_lucky_item_state.dart';

class EditLuckyItemCubit extends Cubit<EditLuckyItemState> {
  EditLuckyItemCubit(this.repo) : super(EditLuckyItemInitial());

  LuckyWheelRepo repo;
  int? editingItemId;

  Future<void> editLuckyItem({required int itemId, required Map<String, dynamic> data}) async {
    editingItemId = itemId;
    emit(EditLuckyItemLoadingState());
    final result = await repo.editLuckyItem(itemId: itemId, data: data);
    result.fold(
      (failure) {
        editingItemId = null;
        emit(EditLuckyItemErrorState(failure.errMessage));
      },
      (message) {
        editingItemId = null;
        emit(EditLuckyItemSuccessState(message));
      },
    );
  }
}
