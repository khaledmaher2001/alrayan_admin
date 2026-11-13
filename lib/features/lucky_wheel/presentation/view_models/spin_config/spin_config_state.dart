part of 'spin_config_cubit.dart';

abstract class SpinConfigState {}

class SpinConfigInitial extends SpinConfigState {}

class SpinConfigLoadingState extends SpinConfigState {}

class SpinConfigLoadedState extends SpinConfigState {
  final SpinWheelConfigModel config;
  SpinConfigLoadedState(this.config);
}

class SpinConfigErrorState extends SpinConfigState {
  final String error;
  SpinConfigErrorState(this.error);
}

class SpinConfigSavingState extends SpinConfigState {}

class SpinConfigSavedState extends SpinConfigState {
  final SpinWheelConfigModel config;
  SpinConfigSavedState(this.config);
}

class SpinConfigSaveErrorState extends SpinConfigState {
  final String error;
  SpinConfigSaveErrorState(this.error);
}
