import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/create_product/create_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/create_product/create_product_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product/delete_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product/delete_product_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/edit_product/edit_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/edit_product/edit_product_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddEditProductItem extends StatelessWidget {
  const AddEditProductItem({
    super.key,
    this.productData,
    required this.formKey,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.price,
    required this.supplierPrice,
    required this.discountType,
    required this.discount,
    required this.stock,
    required this.categoryId,
    required this.subCategoryId,
    required this.isRecommended,
    required this.unit,
  });

  final Items? productData;
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController nameEn;
  final TextEditingController description;
  final TextEditingController descriptionEn;
  final TextEditingController price;
  final TextEditingController supplierPrice;
  final String discountType;
  final TextEditingController discount;
  final TextEditingController stock;
  final TextEditingController unit;
  final int categoryId;
  final int subCategoryId;
  final bool isRecommended;

  Map<String, dynamic> _buildProductData({
    required List<MultipartFile> attachments,
    required bool addImages,
  }) {
    final bool hasDiscountType = discountType.trim().isNotEmpty;

    final dynamic normalizedDiscount =
    hasDiscountType
        ? (discount.text.trim().isEmpty ? 0 : discount.text.trim())
        : 0;

    final String normalizedDiscountType =
    hasDiscountType ? discountType.trim() : "";

    final Map<String, dynamic> data = {
      "name": {
        "en": nameEn.text.trim(),
        "ar": name.text.trim(),
      },
      "description": {
        "en": descriptionEn.text.trim(),
        "ar": description.text.trim(),
      },
      "supplier_price": supplierPrice.text.trim(),
      "price": price.text.trim(),
      "stock": stock.text.trim(),
      "discount": normalizedDiscount,
      "discount_type": normalizedDiscountType,
      "main_category_id": categoryId,
      "sub_category_id": subCategoryId,
      "unit": unit.text.trim(),
      "isRecommended": isRecommended,
    };

    if (addImages) {
      data["images"] = attachments;
    }

    return data;
  }

  Future<List<MultipartFile>> _prepareAttachments(BuildContext context) async {
    final photos = context.read<SelectProductPhotosCubit>().productPhotos;

    return Future.wait(
      photos.map(
            (item) async => MultipartFile.fromFile(
          item.path,
          filename: item.path.split('/').last.replaceAll(' ', '_'),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("تأكيد الحذف",style: Styles.inter24600black(context),),
          content: Text("هل أنت متأكد أنك تريد حذف المنتج؟",style: Styles.font18500Grey900(context),),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.sp10(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text("إلغاء",style: Styles.inter18500Black(context),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                "حذف",
                style: Styles.inter16400white(context),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && productData != null) {
      context.read<DeleteProductCubit>().deleteProduct(
        id: productData!.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (productData == null)
          Expanded(
            child: BlocConsumer<CreateProductCubit, CreateProductStates>(
              listener: (context, createState) {
                if (createState is CreateProductSuccessState) {
                  cherryToast(text: createState.message, context: context);
                  context.read<GetProductsCubit>().getProducts();
                  NavigationUtils.navigateBack(context: context);
                } else if (createState is CreateProductErrorState) {
                  cherryToast(
                    text: createState.error,
                    context: context,
                    isSuccess: false,
                  );
                }
              },
              builder: (context, createState) {
                return createState is CreateProductLoadingState
                    ? CustomLoadingItem()
                    : DefaultButton(
                  onPress: () async {
                    if (!formKey.currentState!.validate()) return;

                    final photosCubit =
                    context.read<SelectProductPhotosCubit>();

                    if (photosCubit.productPhotos.isEmpty) {
                      cherryToast(
                        text: "يجب اختيار صور للمنتج اولا",
                        context: context,
                        isSuccess: false,
                      );
                      return;
                    }

                    final attachments =
                    await _prepareAttachments(context);

                    context.read<CreateProductCubit>().createProduct(
                      data: _buildProductData(
                        attachments: attachments,
                        addImages: attachments.isNotEmpty,
                      ),
                    );
                  },
                  text: "اضافة",
                  borderRadius: AppConstants.sp10(context),
                );
              },
            ),
          ),
        if (productData != null) ...[
          Expanded(
            child: BlocConsumer<EditProductCubit, EditProductStates>(
              listener: (context, editState) {
                if (editState is EditProductSuccessState) {
                  cherryToast(text: editState.message, context: context);
                  context.read<GetProductsCubit>().getProducts(
                    categoryId:
                    context.read<ChangeCategoryCubit>().mainCategoryId,
                    subCategoryId:
                    context.read<ChangeCategoryCubit>().subCategoryId,
                  );
                  NavigationUtils.navigateBack(context: context);
                } else if (editState is EditProductErrorState) {
                  cherryToast(
                    text: editState.error,
                    context: context,
                    isSuccess: false,
                  );
                }
              },
              builder: (context, editState) {
                return editState is EditProductLoadingState
                    ? CustomLoadingItem()
                    : DefaultButton(
                  onPress: () async {
                    if (!formKey.currentState!.validate()) return;

                    final photosCubit =
                    context.read<SelectProductPhotosCubit>();

                    final bool hasOldImages =
                        productData?.images?.isNotEmpty ?? false;
                    final bool hasNewImages =
                        photosCubit.productPhotos.isNotEmpty;

                    if (!hasOldImages && !hasNewImages) {
                      cherryToast(
                        text: "يجب اختيار صور للمنتج اولا",
                        context: context,
                        isSuccess: false,
                      );
                      return;
                    }

                    final attachments =
                    await _prepareAttachments(context);

                    context.read<EditProductCubit>().editProduct(
                      id: productData!.id!,
                      data: _buildProductData(
                        attachments: attachments,
                        addImages: attachments.isNotEmpty,
                      ),
                    );
                  },
                  text: "تعديل",
                  backgroundColor: Colors.green,
                  borderRadius: AppConstants.sp10(context),
                );
              },
            ),
          ),
          SizedBox(width: AppConstants.width15(context)),
          GestureDetector(
            onTap: () async {
              await _showDeleteConfirmationDialog(context);
            },
            child: Container(
              padding: EdgeInsets.all(AppConstants.width20(context)),
              decoration: BoxDecoration(
                color: AppColors.redColor,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: BlocConsumer<DeleteProductCubit, DeleteProductStates>(
                listener: (context, deleteState) {
                  if (deleteState is DeleteProductSuccessState) {
                    cherryToast(text: deleteState.message, context: context);
                    context.read<GetProductsCubit>().getProducts(
                      categoryId:
                      context.read<ChangeCategoryCubit>().mainCategoryId,
                      subCategoryId:
                      context.read<ChangeCategoryCubit>().subCategoryId,
                    );
                    NavigationUtils.navigateBack(context: context);
                  } else if (deleteState is DeleteProductErrorState) {
                    cherryToast(
                      text: deleteState.error,
                      context: context,
                      isSuccess: false,
                    );
                  }
                },
                builder: (context, deleteState) {
                  return deleteState is DeleteProductLoadingState
                      ? CustomLoadingItem(
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * .026,
                  )
                      : SvgPicture.asset(
                    AssetData.delete,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.height * .026,
                    height: MediaQuery.of(context).size.height * .026,
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}