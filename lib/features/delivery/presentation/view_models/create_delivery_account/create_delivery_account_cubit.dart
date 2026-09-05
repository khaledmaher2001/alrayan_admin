import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'create_delivery_account_states.dart';

class CreateDeliveryAccountCubit extends Cubit<CreateDeliveryAccountState> {
  CreateDeliveryAccountCubit(this.repo) : super(CreateDeliveryAccountInitial());

  final DeliveryRepo repo;

  Future<void> createDeliveryAccount(Map<String, dynamic> data) async {
    emit(CreateDeliveryAccountLoading());
    final result = await repo.createDeliveryAccount(data: data);
    result.fold(
      (failure) => emit(CreateDeliveryAccountError(failure.errMessage)),
      (account) => emit(CreateDeliveryAccountSuccess(account)),
    );
  }
}
