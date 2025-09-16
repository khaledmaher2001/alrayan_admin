abstract class DeleteSubCategoryStates {}

class DeleteSubCategoryInitState extends DeleteSubCategoryStates {}

class DeleteSubCategoryLoadingState extends DeleteSubCategoryStates {}

class DeleteSubCategorySuccessState extends DeleteSubCategoryStates {
  final String message;

  DeleteSubCategorySuccessState({required this.message});
}

class DeleteSubCategoryErrorState extends DeleteSubCategoryStates {
  final String error;

  DeleteSubCategoryErrorState({required this.error});
}
