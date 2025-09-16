abstract class CreateSubCategoryStates {}

class CreateSubCategoryInitState extends CreateSubCategoryStates {}

class CreateSubCategoryLoadingState extends CreateSubCategoryStates {}

class CreateSubCategorySuccessState extends CreateSubCategoryStates {
  final String message;

  CreateSubCategorySuccessState({required this.message});
}

class CreateSubCategoryErrorState extends CreateSubCategoryStates {
  final String error;

  CreateSubCategoryErrorState({required this.error});
}

class SelectSubCategoryIconState extends CreateSubCategoryStates {}
