abstract class UpdateRemittanceStatusStates {}

class UpdateRemittanceStatusInitState extends UpdateRemittanceStatusStates {}

class UpdateRemittanceStatusLoadingState extends UpdateRemittanceStatusStates {}

class UpdateRemittanceStatusSuccessState extends UpdateRemittanceStatusStates {
  final int id;
  final String status;
  final String message;

  UpdateRemittanceStatusSuccessState({
    required this.id,
    required this.status,
    required this.message,
  });
}

class UpdateRemittanceStatusErrorState extends UpdateRemittanceStatusStates {
  final String errMessage;

  UpdateRemittanceStatusErrorState(this.errMessage);
}
