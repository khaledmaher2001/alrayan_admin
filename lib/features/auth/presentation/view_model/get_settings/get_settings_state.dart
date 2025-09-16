part of 'get_settings_cubit.dart';

abstract class GetSettingsState {}

class GetSettingsInitial extends GetSettingsState {}


class GetSettingsLoadingState extends GetSettingsState {}
class GetSettingsSuccessState extends GetSettingsState {
  final SettingsModel settingsModel;

  GetSettingsSuccessState({required this.settingsModel});
}
class GetSettingsErrorState extends GetSettingsState {
  final String error;

  GetSettingsErrorState(this.error);
}
