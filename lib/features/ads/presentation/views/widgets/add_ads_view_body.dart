import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart' as banner_model;
import 'package:alrayan_admin/features/ads/presentation/view_models/edit_banner/edit_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/select_ads_product_bottom_sheet.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/shared_widgets/custom_dropdown_formfield.dart';
import '../../../../../core/shared_widgets/custom_snackbar.dart';
import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/add_new_ads_model/add_ads_cubit.dart';
import '../../view_models/ads_assets/ads_assets_cubit.dart';

class AddAdsViewBody extends StatefulWidget {
  const AddAdsViewBody({super.key, this.editingBanner});

  final banner_model.Data? editingBanner;

  @override
  State<AddAdsViewBody> createState() => _AddAdsViewBodyState();
}

class _AddAdsViewBodyState extends State<AddAdsViewBody> {
  var formNewKey = GlobalKey<FormState>();

  TextEditingController link = TextEditingController();
  TextEditingController newTitle = TextEditingController();
  TextEditingController newDescription = TextEditingController();

  bool get isEditing => widget.editingBanner != null;

  @override
  void initState() {
    if (isEditing) {
      final banner = widget.editingBanner!;
      newTitle.text = banner.title ?? "";
      newDescription.text = banner.description ?? "";
      link.text = banner.link ?? "";
      context.read<AdsAssetsCubit>().prefillFromBanner(
        type: banner.type,
        product: _productFromBannerProduct(banner.product),
        imageUrl: banner.imagePath,
      );
    } else {
      context.read<AdsAssetsCubit>().reset();
    }
    super.initState();
  }

  // banner.product (offer_banner_model) and the product picker's Items (products_model)
  // are separate generated models for the same shape; this remaps one into the other
  // so an existing "discount" banner shows its linked product when edited.
  Items? _productFromBannerProduct(banner_model.Product? product) {
    if (product == null) return null;
    return Items.fromJson({
      'id': product.id,
      'name': {'ar': product.name, 'en': product.name},
      'description': {'ar': product.description, 'en': product.description},
      'price': product.price,
      'supplier_price': product.supplierPrice,
      'discount': product.discount,
      'discount_type': product.discountType,
      'price_after_discount': product.priceAfterDiscount,
      'main_category_id': product.mainCategoryId,
      'sub_category_id': product.subCategoryId,
      'stock': product.stock,
      'unit': product.unit,
      'images': product.images?.map((img) => {'id': img.id, 'attach': img.attach}).toList(),
      'isRecommended': product.isRecommended,
      'isHidden': product.isHidden,
      'mainCategory': product.mainCategory == null
          ? null
          : {'id': product.mainCategory!.id, 'name': product.mainCategory!.name},
      'subCategory': product.subCategory == null
          ? null
          : {'id': product.subCategory!.id, 'name': product.subCategory!.name},
    });
  }

  /// A "discount" banner must point at a product (the dropdown/image are form validators).
  bool _productChosen(BuildContext context) {
    final assets = context.read<AdsAssetsCubit>();
    if (assets.adsType == "discount" && assets.selectedProduct == null) {
      toast(text: "s_please_select_the_ad_product".tr(), color: DsColor.danger);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CustomAppBar(title: isEditing ? "s_edit_ad".tr() : "s_add_an_ad_or_offer".tr(), textColor: Colors.black, hasBack: true, withNotifications: false),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: Form(
                  key: formNewKey,
                  child: BlocBuilder<AdsAssetsCubit, AdsAssetsState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("s_ad_type".tr(), style: Styles.inter14600black(context)),
                                  Text("*", style: Styles.inter14600black(context).copyWith(color: AppColors.redColor)),
                                ],
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              CustomDropDownButton(
                                hintText: "s_choose_the_ad_type".tr(),
                                items: ['إعلان عادي', 'عرض على منتج'],
                                borderRadius: AppConstants.sp10(context),
                                hasBorder: true,
                                height: MediaQuery.of(context).size.height * .06,
                                onChanged: (v) {
                                  switch (v) {
                                    case 'عرض على منتج':
                                      context.read<AdsAssetsCubit>().selectAdsType(type: "discount");
                                      break;
                                    case 'إعلان عادي':
                                      context.read<AdsAssetsCubit>().selectAdsType(type: "new");
                                      break;
                                  }
                                },
                                validator: (String? value) {
                                  if (value == null) {
                                    return "s_please_choose_the_ad_type".tr();
                                  }
                                  return null;
                                },
                                value: context.read<AdsAssetsCubit>().adsType == "discount"
                                    ? 'عرض على منتج'
                                    : context.read<AdsAssetsCubit>().adsType == "new"
                                        ? 'إعلان عادي'
                                        : null,
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          if (context.read<AdsAssetsCubit>().adsType == "discount") ...[
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text("s_selected_product".tr(), style: Styles.inter14600black(context))),
                                    if (context.read<AdsAssetsCubit>().selectedProduct != null)
                                      InkWell(
                                        onTap: () {
                                          SelectAdsProductBottomSheet.show(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                            color: AppColors.secondaryColor,
                                          ),
                                          child: SvgPicture.asset(
                                            AssetData.edit,
                                            color: Colors.white,
                                            width: MediaQuery.of(context).size.width * .06,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: AppConstants.height10(context)),
                                context.read<AdsAssetsCubit>().selectedProduct == null
                                    ? InkWell(
                                        onTap: () {
                                          SelectAdsProductBottomSheet.show(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(AppConstants.sp20(context)),
                                          decoration: BoxDecoration(
                                            color: Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(AssetData.addCircle, color: AppColors.gray),
                                              Text("s_add_product".tr(), style: Styles.inter14600gray(context)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(AppConstants.sp20(context)),
                                        decoration: BoxDecoration(
                                          color: Color(0xffF7F7F8),
                                          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                          border: Border.all(color: DsColor.border),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(AppConstants.sp5(context)),
                                              decoration: BoxDecoration(
                                                color: AppColors.gray.withOpacity(.3),
                                                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                              ),
                                              child: DefaultCachedNetworkImage(
                                                imageUrl: context
                                                    .read<AdsAssetsCubit>()
                                                    .selectedProduct!
                                                    .images!
                                                    .first
                                                    .attach,
                                                imageWidth: MediaQuery.of(context).size.width * .15,
                                                imageHeight: MediaQuery.of(context).size.width * .15,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            SizedBox(width: AppConstants.width10(context)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context
                                                            .read<AdsAssetsCubit>()
                                                            .selectedProduct!
                                                            .mainCategory!
                                                            .name ??
                                                        '',
                                                    style: Styles.inter14600gray(context),
                                                  ),
                                                  SizedBox(height: AppConstants.height5(context)),
                                                  Text(
                                                    context.read<AdsAssetsCubit>().selectedProduct!.name!.ar ?? '',
                                                    style: Styles.inter16500black(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text("s_price".tr(), style: Styles.inter16500black(context)),
                                                Text(
                                                  "${context.read<AdsAssetsCubit>().selectedProduct!.price ?? ''} ${"s_egp".tr()}",
                                                  style: Styles.inter16500black(
                                                    context,
                                                  ).copyWith(color: AppColors.primaryColor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                          ],
                          Text("s_ad_title".tr(), style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return "s_this_field_is_required".tr();
                              }
                            },
                            hintText: "s_add_the_ad_title".tr(),
                            borderRadius: AppConstants.sp10(context),
                            hasBorder: true,
                            borderSideColor: AppColors.gray,
                            borderSideWidth: 1,
                            contentPaddingHorizontal: AppConstants.width20(context),
                            contentPaddingVertical: AppConstants.height20(context),
                            textInputType: TextInputType.emailAddress,
                            controller: newTitle,
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          // Optional on the server (create and update); an empty value on edit clears it.
                          Text("s_ad_description_optional".tr(), style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              return null;
                            },
                            hintText: "s_add_the_ad_description".tr(),
                            borderRadius: AppConstants.sp10(context),
                            hasBorder: true,
                            borderSideColor: AppColors.gray,
                            borderSideWidth: 1,
                            maxLines: 4,
                            contentPaddingHorizontal: AppConstants.width20(context),
                            contentPaddingVertical: AppConstants.height20(context),
                            textInputType: TextInputType.emailAddress,
                            controller: newDescription,
                          ),
                         if(context.read<AdsAssetsCubit>().adsType == "new")...[ SizedBox(height: AppConstants.height20(context)),
                          Text("s_ad_link_optional".tr(), style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            hintText: "s_add_the_ad_link".tr(),
                            borderRadius: AppConstants.sp10(context),
                            hasBorder: true,
                            validation: (value) {
                              return null;
                            },
                            borderSideColor: AppColors.gray,
                            borderSideWidth: 1,
                            maxLines: 1,
                            contentPaddingHorizontal: AppConstants.width20(context),
                            contentPaddingVertical: AppConstants.height20(context),
                            textInputType: TextInputType.url,
                            controller: link,
                          ),],
                          SizedBox(height: AppConstants.height20(context)),
                          BlocBuilder<AdsAssetsCubit, AdsAssetsState>(
                            builder: (context, frontIdState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("s_add_an_image_or_attachment".tr(), style: Styles.inter14500black(context)),
                                  SizedBox(height: AppConstants.height10(context)),
                                  FormField(
                                    validator: (value) {
                                      final assets = context.read<AdsAssetsCubit>();
                                      if (assets.newImage == null && assets.existingImageUrl == null) {
                                        return "s_an_image_or_attachment_is_required".tr();
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState<String> state) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: Radius.circular(AppConstants.sp10(context)),
                                            color: AppColors.gray,

                                            dashPattern: const [5, 5],
                                            strokeWidth: 1.5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                              ),
                                              height: MediaQuery.of(context).size.height * .17,
                                              child: InkWell(
                                                onTap: () {
                                                  context.read<AdsAssetsCubit>().selectNewImage(context);
                                                },
                                                child: context.read<AdsAssetsCubit>().newImage != null
                                                    ? Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(
                                                            AppConstants.sp10(context),
                                                          ),
                                                          color: DsColor.border,
                                                        ),
                                                        child: ClipRRect(
                                                          clipBehavior: Clip.hardEdge,
                                                          borderRadius: BorderRadius.circular(
                                                            AppConstants.sp10(context),
                                                          ),
                                                          child: Image.file(
                                                            context.read<AdsAssetsCubit>().newImage!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      )
                                                    : context.read<AdsAssetsCubit>().existingImageUrl != null
                                                    ? Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(
                                                            AppConstants.sp10(context),
                                                          ),
                                                          color: DsColor.border,
                                                        ),
                                                        child: ClipRRect(
                                                          clipBehavior: Clip.hardEdge,
                                                          borderRadius: BorderRadius.circular(
                                                            AppConstants.sp10(context),
                                                          ),
                                                          child: DefaultCachedNetworkImage(
                                                            imageUrl: context.read<AdsAssetsCubit>().existingImageUrl,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      )
                                                    : Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                AssetData.uploadImage,
                                                                width: MediaQuery.of(context).size.height * .11,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                          if (state.errorText != null)
                                            Padding(
                                              padding: EdgeInsets.only(top: AppConstants.height10(context)),
                                              child: Text(
                                                state.errorText!,
                                                style: Styles.inter16500black(context).copyWith(
                                                  fontWeight: FontWeight.w100,
                                                  color: DsColor.danger,
                                                  fontSize: MediaQuery.of(context).size.height * .012,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
            child: isEditing
                ? BlocConsumer<EditBannerCubit, EditBannerState>(
                    builder: (context, state) {
                      return state is EditBannerLoading
                          ? DefaultButton(
                              onPress: () {},
                              text: "s_saving_changes".tr(),
                              backgroundColor: AppColors.gray,
                              borderRadius: AppConstants.sp10(context),
                            )
                          : DefaultButton(
                              onPress: () async {
                                if (formNewKey.currentState!.validate() && _productChosen(context)) {
                                  final assets = context.read<AdsAssetsCubit>();
                                  context.read<EditBannerCubit>().updateBanner(
                                    id: widget.editingBanner!.id!,
                                    data: {
                                      "title": newTitle.text.trim(),
                                      "description": newDescription.text.trim(),
                                      "type": assets.adsType,
                                      // "" clears the field that no longer applies when the type changes.
                                      "link": assets.adsType == "new" ? link.text.trim() : "",
                                      "productId": assets.adsType == "discount" ? assets.selectedProduct!.id : "",
                                      // PATCH /banners/:id reads the upload from the "file" field (POST uses "imagePath").
                                      if (assets.newImage != null)
                                        "file": await MultipartFile.fromFile(assets.newImage!.path),
                                    },
                                  );
                                }
                              },
                              text: "s_save_changes".tr(),
                              borderRadius: AppConstants.sp10(context),
                            );
                    },
                    listener: (BuildContext context, EditBannerState state) {
                      if (state is EditBannerSuccess) {
                        context.read<AdsAssetsCubit>().newImage = null;
                        context.read<OfferBannerCubit>().fetchOfferBanners();
                        toast(text: "s_ad_updated".tr(), color: DsColor.success);
                        NavigationUtils.navigateBack(context: context);
                      } else if (state is EditBannerError) {
                        customSnackBar(message: state.error, color: AppColors.redColor, context: context);
                      }
                    },
                  )
                : BlocConsumer<AddAdsCubit, AddAdsState>(
                    builder: (context, state) {
                      return state is AddAdsLoading
                          ? DefaultButton(
                              onPress: () {},
                              text: "s_adding_the_ad".tr(),
                              backgroundColor: AppColors.gray,
                              borderRadius: AppConstants.sp10(context),
                            )
                          : DefaultButton(
                              onPress: () async {
                                if (formNewKey.currentState!.validate() && _productChosen(context)) {
                                  final assets = context.read<AdsAssetsCubit>();
                                  final addCubit = context.read<AddAdsCubit>();
                                  addCubit.addAds(
                                    data: {
                                      "title": newTitle.text.trim(),
                                      if (newDescription.text.trim().isNotEmpty)
                                        "description": newDescription.text.trim(),
                                      "type": assets.adsType,
                                      if (assets.adsType == "new") "link": link.text.trim(),
                                      if (assets.adsType == "discount") "productId": assets.selectedProduct!.id,
                                      // The image FormField above guarantees one was picked.
                                      "imagePath": await MultipartFile.fromFile(assets.newImage!.path),
                                    },
                                  );
                                }
                              },
                              text: "s_add_ad".tr(),
                              borderRadius: AppConstants.sp10(context),
                            );
                    },
                    listener: (BuildContext context, AddAdsState state) {
                      if (state is AddAdsSuccess) {
                        context.read<AdsAssetsCubit>().newImage = null;
                        context.read<OfferBannerCubit>().fetchOfferBanners();
                        toast(text: "s_ad_added".tr(), color: DsColor.success);
                        NavigationUtils.navigateBack(context: context);
                      } else if (state is AddAdsError) {
                        customSnackBar(message: state.error, color: AppColors.redColor, context: context);
                      }
                    },
                  ),
          ),
          SizedBox(height: AppConstants.height20(context),),
        ],
      ),
    );
  }
}
