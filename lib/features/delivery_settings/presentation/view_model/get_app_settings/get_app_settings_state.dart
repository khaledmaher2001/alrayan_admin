part of 'get_app_settings_cubit.dart';

abstract class GetAppSettingsState {}

class GetAppSettingsInitial extends GetAppSettingsState {}

class GetAppSettingsLoadingState extends GetAppSettingsState {}

class GetAppSettingsSuccessState extends GetAppSettingsState {
  final DeliveryAppSettingsModel settingsModel;

  GetAppSettingsSuccessState({required this.settingsModel});
}

class GetAppSettingsErrorState extends GetAppSettingsState {
  final String errorMessage;

  GetAppSettingsErrorState(this.errorMessage);
}
