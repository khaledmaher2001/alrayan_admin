abstract class EditCategoryStates {}

class EditCategoryInitState extends EditCategoryStates {}

class EditCategoryLoadingState extends EditCategoryStates {}

class EditCategorySuccessState extends EditCategoryStates {
  final String message;

  EditCategorySuccessState({required this.message});
}

class EditCategoryErrorState extends EditCategoryStates {
  final String error;

  EditCategoryErrorState({required this.error});
}
