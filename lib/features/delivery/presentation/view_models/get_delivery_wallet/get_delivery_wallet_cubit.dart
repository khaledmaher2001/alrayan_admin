import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'get_delivery_wallet_state.dart';

class GetDeliveryWalletCubit extends Cubit<GetDeliveryWalletState> {
  GetDeliveryWalletCubit(this.repo) : super(GetDeliveryWalletInitial());

  final DeliveryRepo repo;

  Future<void> getWallet(int userId) async {
    emit(GetDeliveryWalletLoading());
    final result = await repo.getDeliveryWallet(userId);
    result.fold(
      (failure) => emit(GetDeliveryWalletError(failure.errMessage)),
      (model) => emit(GetDeliveryWalletSuccess(model)),
    );
  }
}
