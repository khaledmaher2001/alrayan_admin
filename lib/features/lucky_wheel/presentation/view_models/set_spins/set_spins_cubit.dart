import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/luck_wheel_repo.dart';

part 'set_spins_state.dart';

/// "Edit count": sets a customer's saved spins to an exact number.
class SetSpinsCubit extends Cubit<SetSpinsState> {
  SetSpinsCubit(this.repo) : super(SetSpinsInitial());

  final LuckyWheelRepo repo;

  Future<void> setSpins({required int userId, required int attemptCount}) async {
    emit(SetSpinsLoadingState(userId));
    final result = await repo.setSpins(userId: userId, attemptCount: attemptCount);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SetSpinsErrorState(failure.errMessage)),
      (count) => emit(SetSpinsSuccessState(userId, count)),
    );
  }
}
