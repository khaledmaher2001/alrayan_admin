abstract class EditProductStates {}

class EditProductInitState extends EditProductStates {}

class EditProductLoadingState extends EditProductStates {}

class EditProductSuccessState extends EditProductStates {
  final String message;

  EditProductSuccessState({required this.message});
}

class EditProductErrorState extends EditProductStates {
  final String error;

  EditProductErrorState(this.error);
}
