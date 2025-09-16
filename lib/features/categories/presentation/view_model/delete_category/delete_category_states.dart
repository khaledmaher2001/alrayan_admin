abstract class DeleteCategoryStates {}

class DeleteCategoryInitState extends DeleteCategoryStates {}

class DeleteCategoryLoadingState extends DeleteCategoryStates {}

class DeleteCategorySuccessState extends DeleteCategoryStates {
  final String message;

  DeleteCategorySuccessState({required this.message});
}

class DeleteCategoryErrorState extends DeleteCategoryStates {
  final String error;

  DeleteCategoryErrorState({required this.error});
}
