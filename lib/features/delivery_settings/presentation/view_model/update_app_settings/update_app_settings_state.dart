import '../../../data/models/delivery_app_settings_model.dart';

abstract class UpdateAppSettingsState {}

class UpdateAppSettingsInitialState extends UpdateAppSettingsState {}

class UpdateAppSettingsLoadingState extends UpdateAppSettingsState {}

class UpdateAppSettingsSuccessState extends UpdateAppSettingsState {
  final DeliveryAppSettingsModel settingsModel;

  UpdateAppSettingsSuccessState(this.settingsModel);
}

class UpdateAppSettingsErrorState extends UpdateAppSettingsState {
  final String errorMessage;

  UpdateAppSettingsErrorState(this.errorMessage);
}
