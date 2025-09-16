
import '../../../data/models/register_model.dart';

abstract class RegisterStates {}

final class RegisterInitialState extends RegisterStates {}

final class RegisterLoadingState extends RegisterStates {}

final class RegisterSuccessState extends RegisterStates {
  final RegisterModel registerModel;

  RegisterSuccessState(this.registerModel);
}

final class RegisterErrorState extends RegisterStates {
  final String errorMessage;

  RegisterErrorState(this.errorMessage);
}
