import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';
import 'update_settings_state.dart';

class UpdateSettingsCubit extends Cubit<UpdateSettingsStates> {
  UpdateSettingsCubit(this.registerRepo) : super(UpdateSettingsInitialState());
  final AuthRepo registerRepo;

  Future<void> userUpdateSettings({required Map<String, dynamic> data}) async {
    emit(UpdateSettingsLoadingState());
    final result = await registerRepo.updateSettings(data: data);
    result.fold(
      (failure) {
        emit(UpdateSettingsErrorState(failure.errMessage));
      },
      (success) {
        emit(UpdateSettingsSuccessState(success));
      },
    );
  }
}
