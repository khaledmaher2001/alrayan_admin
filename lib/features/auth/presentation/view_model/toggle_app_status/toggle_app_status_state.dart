part of 'toggle_app_status_cubit.dart';

abstract class ToggleAppStatusState {}

class ToggleAppStatusInitial extends ToggleAppStatusState {}

class ToggleAppStatusLoadingState extends ToggleAppStatusState {}

class ToggleAppStatusSuccessState extends ToggleAppStatusState {
  final bool isOpen;
  ToggleAppStatusSuccessState(this.isOpen);
}

class ToggleAppStatusErrorState extends ToggleAppStatusState {
  final String error;
  ToggleAppStatusErrorState(this.error);
}
