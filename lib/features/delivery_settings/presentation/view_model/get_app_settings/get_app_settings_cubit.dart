import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/delivery_app_settings_model.dart';
import '../../../data/repo/delivery_settings_repo.dart';

part 'get_app_settings_state.dart';

class GetAppSettingsCubit extends Cubit<GetAppSettingsState> {
  GetAppSettingsCubit(this.repo) : super(GetAppSettingsInitial());

  final DeliverySettingsRepo repo;
  DeliveryAppSettingsModel? settingsModel;

  Future<void> getAppSettings() async {
    emit(GetAppSettingsLoadingState());
    final result = await repo.getAppSettings();
    result.fold(
      (failure) {
        emit(GetAppSettingsErrorState(failure.errMessage));
      },
      (data) {
        settingsModel = data;
        emit(GetAppSettingsSuccessState(settingsModel: data));
      },
    );
  }
}
