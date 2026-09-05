import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repo/auth_repo.dart';

part 'toggle_app_status_state.dart';

class ToggleAppStatusCubit extends Cubit<ToggleAppStatusState> {
  ToggleAppStatusCubit(this.repo) : super(ToggleAppStatusInitial());

  final AuthRepo repo;

  Future<void> toggleAppStatus() async {
    emit(ToggleAppStatusLoadingState());
    final result = await repo.toggleAppStatus();
    result.fold(
      (failure) => emit(ToggleAppStatusErrorState(failure.errMessage)),
      (isOpen) => emit(ToggleAppStatusSuccessState(isOpen)),
    );
  }
}
