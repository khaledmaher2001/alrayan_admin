part of 'toggle_maintenance_cubit.dart';

abstract class ToggleMaintenanceState {}

class ToggleMaintenanceInitial extends ToggleMaintenanceState {}

class ToggleMaintenanceLoadingState extends ToggleMaintenanceState {}

class ToggleMaintenanceSuccessState extends ToggleMaintenanceState {
  final bool maintenance;
  ToggleMaintenanceSuccessState(this.maintenance);
}

class ToggleMaintenanceErrorState extends ToggleMaintenanceState {
  final String error;
  ToggleMaintenanceErrorState(this.error);
}
