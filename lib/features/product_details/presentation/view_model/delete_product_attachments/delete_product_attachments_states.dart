
abstract class DeleteProductAttachmentsStates{}

class DeleteProductAttachmentsInitState extends DeleteProductAttachmentsStates{}
class DeleteProductAttachmentsLoadingState extends DeleteProductAttachmentsStates{}
class DeleteProductAttachmentsSuccessState extends DeleteProductAttachmentsStates{
  final String message;

  DeleteProductAttachmentsSuccessState({required this.message});
}
class DeleteProductAttachmentsErrorState extends DeleteProductAttachmentsStates{
  final String error;

  DeleteProductAttachmentsErrorState(this.error);
}