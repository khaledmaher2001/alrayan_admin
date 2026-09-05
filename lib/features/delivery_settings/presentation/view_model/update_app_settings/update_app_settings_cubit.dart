import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/delivery_settings_repo.dart';
import 'update_app_settings_state.dart';

class UpdateAppSettingsCubit extends Cubit<UpdateAppSettingsState> {
  UpdateAppSettingsCubit(this.repo) : super(UpdateAppSettingsInitialState());

  final DeliverySettingsRepo repo;

  Future<void> updateAppSettings({required Map<String, dynamic> data}) async {
    emit(UpdateAppSettingsLoadingState());
    final result = await repo.updateAppSettings(data: data);
    result.fold(
      (failure) {
        emit(UpdateAppSettingsErrorState(failure.errMessage));
      },
      (success) {
        emit(UpdateAppSettingsSuccessState(success));
      },
    );
  }
}
