import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/auth_repo.dart';

part 'toggle_maintenance_state.dart';

class ToggleMaintenanceCubit extends Cubit<ToggleMaintenanceState> {
  ToggleMaintenanceCubit(this.repo) : super(ToggleMaintenanceInitial());

  final AuthRepo repo;

  Future<void> toggleMaintenance() async {
    emit(ToggleMaintenanceLoadingState());
    final result = await repo.toggleMaintenance();
    result.fold(
      (failure) => emit(ToggleMaintenanceErrorState(failure.errMessage)),
      (maintenance) => emit(ToggleMaintenanceSuccessState(maintenance)),
    );
  }
}
