import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/spin_wheel_config_model.dart';
import '../../../data/repo/luck_wheel_repo.dart';

part 'spin_config_state.dart';

/// Order rules ("spins by order value") of the wheel: load and save.
class SpinConfigCubit extends Cubit<SpinConfigState> with RequestGuardMixin {
  SpinConfigCubit(this.repo) : super(SpinConfigInitial());

  final LuckyWheelRepo repo;
  SpinWheelConfigModel? config;

  Future<void> load() async {
    final reqId = beginRequest();
    emit(SpinConfigLoadingState());
    final result = await repo.getSpinConfig(cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    result.fold(
      (failure) => emit(SpinConfigErrorState(failure.errMessage)),
      (data) {
        config = data;
        emit(SpinConfigLoadedState(data));
      },
    );
  }

  /// `[]` clears the rules (back to 1 spin per delivered order).
  Future<void> saveRules(List<SpinOrderRule> rules) async {
    emit(SpinConfigSavingState());
    final result = await repo.updateSpinConfig(orderRules: rules);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SpinConfigSaveErrorState(failure.errMessage)),
      (data) {
        config = data;
        emit(SpinConfigSavedState(data));
      },
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
