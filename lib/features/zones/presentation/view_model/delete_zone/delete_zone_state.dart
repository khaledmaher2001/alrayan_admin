sealed class DeleteZoneStates {}

final class DeleteZoneInitialState extends DeleteZoneStates {}

final class DeleteZoneLoadingState extends DeleteZoneStates {}

final class DeleteZoneSuccessState extends DeleteZoneStates {
  final String message;

  DeleteZoneSuccessState(this.message);
}

final class DeleteZoneErrorState extends DeleteZoneStates {
  final String error;

  DeleteZoneErrorState(this.error);
}

final class SelectZoneState extends DeleteZoneStates {}


