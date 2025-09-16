import 'package:alrayan_admin/features/auth/data/repo/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/settings_model.dart';

part 'get_settings_state.dart';

class GetSettingsCubit extends Cubit<GetSettingsState> {
  GetSettingsCubit(this.repo) : super(GetSettingsInitial());

  AuthRepo repo;
  SettingsModel? settingsModel;

  Future<void> getSettings() async {
    emit(GetSettingsLoadingState());
    final result = await repo.getSettings();
    result.fold(
      (failure) {
        emit(GetSettingsErrorState(failure.errMessage));
      },
      (data) {
        settingsModel=data;
        emit(GetSettingsSuccessState(settingsModel: data));
      },
    );
  }
}
