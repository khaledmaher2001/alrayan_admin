sealed class EditZoneStates {}

final class EditZoneInitialState extends EditZoneStates {}

final class EditZoneLoadingState extends EditZoneStates {}

final class EditZoneSuccessState extends EditZoneStates {
  final String message;

  EditZoneSuccessState(this.message);
}

final class EditZoneErrorState extends EditZoneStates {
  final String error;

  EditZoneErrorState(this.error);
}


