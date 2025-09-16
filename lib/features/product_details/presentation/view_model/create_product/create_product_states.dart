
abstract class CreateProductStates{}

class CreateProductInitState extends CreateProductStates{}
class CreateProductLoadingState extends CreateProductStates{}
class CreateProductSuccessState extends CreateProductStates{
  final String message;

  CreateProductSuccessState({required this.message});
}
class CreateProductErrorState extends CreateProductStates{
  final String error;

  CreateProductErrorState(this.error);
}