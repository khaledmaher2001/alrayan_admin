import '../../../data/models/remittance_model.dart';

abstract class GetRemittancesStates {}

class GetRemittancesInitState extends GetRemittancesStates {}

class GetRemittancesLoadingState extends GetRemittancesStates {}

class GetRemittancesSuccessState extends GetRemittancesStates {
  final RemittancesModel model;

  GetRemittancesSuccessState({required this.model});
}

class GetRemittancesErrorState extends GetRemittancesStates {
  final String message;

  GetRemittancesErrorState(this.message);
}
