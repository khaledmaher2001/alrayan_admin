import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product_attachments/delete_product_attachments_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product_attachments/delete_product_attachments_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_states.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductPhotosList extends StatefulWidget {
  const ProductPhotosList({super.key, required this.images});

  final List<Images> images;

  @override
  State<ProductPhotosList> createState() => _ProductPhotosListState();
}

class _ProductPhotosListState extends State<ProductPhotosList> {
  late SelectProductPhotosCubit photoCubit;

  @override
  void initState() {
    photoCubit = context.read<SelectProductPhotosCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectProductPhotosCubit, SelectProductPhotosStates>(
      builder: (context, photoState) {
        return Column(
          children: [
            BlocConsumer<DeleteProductAttachmentsCubit, DeleteProductAttachmentsStates>(
              listener: (context, deleteAttachments) {
                if (deleteAttachments is DeleteProductAttachmentsSuccessState) {
                  widget.images.removeAt(photoCubit.photoIndex);
                  photoCubit.removeProductPhotos();
                  context.read<GetProductsCubit>().getProducts(
                    categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
                    subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
                  );
                } else if (deleteAttachments is DeleteProductAttachmentsErrorState) {
                  cherryToast(text: deleteAttachments.error, context: context, isSuccess: false);
                }
              },
              builder: (context, deleteAttachments) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppConstants.width10(context),
                    mainAxisSpacing: AppConstants.height10(context),
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(AppConstants.sp10(context)),
                    child: Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        DefaultCachedNetworkImage(
                          imageUrl: widget.images[index].attach ?? "",
                          imageHeight: MediaQuery.of(context).size.height,
                          imageWidth: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                        if(widget.images.length>1)
                        IconButton(
                          onPressed: () {
                            photoCubit.selectPhotoIndex(index);
                            context.read<DeleteProductAttachmentsCubit>().deleteProductAttachments(
                              id: widget.images[index].id!,
                            );
                          },
                          icon: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redColor),
                            padding: EdgeInsets.all(AppConstants.sp5(context)),
                            width: AppConstants.sp30(context),
                            height: AppConstants.sp30(context),
                            child:
                                deleteAttachments is DeleteProductAttachmentsLoadingState &&
                                    photoCubit.photoIndex == index
                                ? CustomLoadingItem(color: Colors.white, size: AppConstants.sp15(context))
                                : Icon(Icons.close, color: Colors.white, size: AppConstants.sp20(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: AppConstants.height15(context)),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: photoCubit.productPhotos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppConstants.width10(context),
                mainAxisSpacing: AppConstants.height10(context),
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(AppConstants.sp10(context)),
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    Image.file(
                      photoCubit.productPhotos[index],
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      onPressed: () {
                        photoCubit.productPhotos.removeAt(index);
                        photoCubit.removeProductPhotos();
                      },
                      icon: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redColor),
                        padding: EdgeInsets.all(AppConstants.sp5(context)),
                        child: Icon(Icons.close, color: Colors.white, size: AppConstants.sp20(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
