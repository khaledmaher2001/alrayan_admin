import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'update_remittance_status_states.dart';

class UpdateRemittanceStatusCubit extends Cubit<UpdateRemittanceStatusStates> {
  UpdateRemittanceStatusCubit(this.repo)
    : super(UpdateRemittanceStatusInitState());

  final DeliveryRepo repo;

  Future<void> approve(int id) async {
    emit(UpdateRemittanceStatusLoadingState());
    final result = await repo.approveRemittance(id);
    result.fold(
      (failure) => emit(UpdateRemittanceStatusErrorState(failure.errMessage)),
      (message) => emit(
        UpdateRemittanceStatusSuccessState(
          id: id,
          status: 'approved',
          message: message,
        ),
      ),
    );
  }

  Future<void> reject(int id) async {
    emit(UpdateRemittanceStatusLoadingState());
    final result = await repo.rejectRemittance(id);
    result.fold(
      (failure) => emit(UpdateRemittanceStatusErrorState(failure.errMessage)),
      (message) => emit(
        UpdateRemittanceStatusSuccessState(
          id: id,
          status: 'rejected',
          message: message,
        ),
      ),
    );
  }
}
