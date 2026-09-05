import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'update_delivery_profile_states.dart';

class UpdateDeliveryProfileCubit extends Cubit<UpdateDeliveryProfileState> {
  UpdateDeliveryProfileCubit(this.repo) : super(UpdateDeliveryProfileInitial());

  final DeliveryRepo repo;

  Future<void> updateProfile({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    emit(UpdateDeliveryProfileLoading());
    final result = await repo.updateDeliveryProfile(userId: userId, data: data);
    result.fold(
      (failure) => emit(UpdateDeliveryProfileError(failure.errMessage)),
      (account) => emit(UpdateDeliveryProfileSuccess(account)),
    );
  }
}
