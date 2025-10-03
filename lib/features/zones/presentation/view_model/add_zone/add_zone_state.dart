sealed class AddZoneStates {}

final class AddZoneInitialState extends AddZoneStates {}

final class AddZoneLoadingState extends AddZoneStates {}

final class AddZoneSuccessState extends AddZoneStates {
  final String message;

  AddZoneSuccessState(this.message);
}

final class AddZoneErrorState extends AddZoneStates {
  final String error;

  AddZoneErrorState(this.error);
}


