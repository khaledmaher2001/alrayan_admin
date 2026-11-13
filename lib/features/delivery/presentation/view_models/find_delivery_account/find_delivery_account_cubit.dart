import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'find_delivery_account_state.dart';

class FindDeliveryAccountCubit extends Cubit<FindDeliveryAccountState> {
  FindDeliveryAccountCubit(this.repo) : super(FindDeliveryAccountInitial());

  final DeliveryRepo repo;

  Future<void> find(int userId) async {
    emit(FindDeliveryAccountLoading());
    final result = await repo.findDeliveryAccount(userId);
    result.fold(
      (failure) => emit(FindDeliveryAccountError(failure.errMessage)),
      (account) => emit(FindDeliveryAccountSuccess(account)),
    );
  }
}
