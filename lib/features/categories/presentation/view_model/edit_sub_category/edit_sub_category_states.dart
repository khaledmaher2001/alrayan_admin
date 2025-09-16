abstract class EditSubCategoryStates {}

class EditSubCategoryInitState extends EditSubCategoryStates {}

class EditSubCategoryLoadingState extends EditSubCategoryStates {}

class EditSubCategorySuccessState extends EditSubCategoryStates {
  final String message;

  EditSubCategorySuccessState({required this.message});
}

class EditSubCategoryErrorState extends EditSubCategoryStates {
  final String error;

  EditSubCategoryErrorState({required this.error});
}
