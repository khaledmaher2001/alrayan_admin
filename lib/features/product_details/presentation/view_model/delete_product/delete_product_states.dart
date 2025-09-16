
abstract class DeleteProductStates{}

class DeleteProductInitState extends DeleteProductStates{}
class DeleteProductLoadingState extends DeleteProductStates{}
class DeleteProductSuccessState extends DeleteProductStates{
  final String message;

  DeleteProductSuccessState({required this.message});
}
class DeleteProductErrorState extends DeleteProductStates{
  final String error;

  DeleteProductErrorState({required this.error});
}