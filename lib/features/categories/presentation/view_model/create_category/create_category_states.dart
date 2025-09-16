abstract class CreateCategoryStates {}

class CreateCategoryInitState extends CreateCategoryStates {}

class CreateCategoryLoadingState extends CreateCategoryStates {}

class CreateCategorySuccessState extends CreateCategoryStates {
  final String message;

  CreateCategorySuccessState({required this.message});
}

class CreateCategoryErrorState extends CreateCategoryStates {
  final String error;

  CreateCategoryErrorState({required this.error});
}

class SelectCategoryIconState extends CreateCategoryStates {}
