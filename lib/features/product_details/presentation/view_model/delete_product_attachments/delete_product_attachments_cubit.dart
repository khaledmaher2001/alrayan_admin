import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product/delete_product_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product_attachments/delete_product_attachments_states.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:bloc/bloc.dart';

class DeleteProductAttachmentsCubit extends Cubit<DeleteProductAttachmentsStates> {
  DeleteProductAttachmentsCubit(this.productsRepo) : super(DeleteProductAttachmentsInitState());
  ProductsRepo? productsRepo;

  Future<void> deleteProductAttachments({required int id}) async {
    emit(DeleteProductAttachmentsLoadingState());

    var result = await productsRepo!.deleteProductAttachments(id: id);
    return result.fold(
      (failure) {
        emit(DeleteProductAttachmentsErrorState(failure.errMessage));
      },
      (data) {
        emit(DeleteProductAttachmentsSuccessState(message: data));
      },
    );
  }
}
