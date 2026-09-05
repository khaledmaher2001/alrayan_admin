import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'delete_delivery_account_state.dart';

class DeleteDeliveryAccountCubit extends Cubit<DeleteDeliveryAccountState> {
  DeleteDeliveryAccountCubit(this.repo) : super(DeleteDeliveryAccountInitial());

  final DeliveryRepo repo;

  Future<void> deleteDeliveryAccount(int userId) async {
    emit(DeleteDeliveryAccountLoading());
    final result = await repo.deleteDeliveryAccount(userId);
    result.fold(
      (failure) => emit(DeleteDeliveryAccountError(failure.errMessage)),
      (_) => emit(DeleteDeliveryAccountSuccess()),
    );
  }
}
