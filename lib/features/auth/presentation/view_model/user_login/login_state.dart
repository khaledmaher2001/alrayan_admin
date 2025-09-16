import 'package:alrayan_admin/features/auth/data/models/login_model.dart';

abstract class LoginStates {}

final class LoginInitialState extends LoginStates {}

final class LoginLoadingState extends LoginStates {}

final class LoginSuccessState extends LoginStates {
  final LoginModel loginModel;

  LoginSuccessState(this.loginModel);
}

final class LoginErrorState extends LoginStates {
  final String errorMessage;

  LoginErrorState(this.errorMessage);
}
