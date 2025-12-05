import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/select_ads_product_bottom_sheet.dart';
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
  const AddAdsViewBody({super.key});

  @override
  State<AddAdsViewBody> createState() => _AddAdsViewBodyState();
}

class _AddAdsViewBodyState extends State<AddAdsViewBody> {
  var formNewKey = GlobalKey<FormState>();

  TextEditingController newTitle = TextEditingController();
  TextEditingController newDescription = TextEditingController();

  @override
  void initState() {
    context.read<AdsAssetsCubit>().newImage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "اضافة اعلان او عرض",
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context),
                ),
                child: Form(
                  key: formNewKey,
                  child: BlocBuilder<AdsAssetsCubit, AdsAssetsState>(
                    builder: (context,state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "نوع الاعلان",
                                    style: Styles.inter14600black(context),
                                  ),
                                  Text(
                                    "*",
                                    style: Styles.inter14600black(
                                      context,
                                    ).copyWith(color: AppColors.redColor),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              CustomDropDownButton(
                                hintText: "اختر نوع الاعلان",
                                items: ['اعلان عادي', 'عرض علي منتج'],
                                borderRadius: AppConstants.sp10(context),
                                hasBorder: true,
                                height: MediaQuery.of(context).size.height * .06,
                                onChanged: (v) {
                                  switch (v) {
                                    case 'عرض علي منتج':
                                      context.read<AdsAssetsCubit>().selectAdsType(
                                        type: "discount",
                                      );
                                      break;
                                    case 'اعلان عادي':
                                      context.read<AdsAssetsCubit>().selectAdsType(
                                        type: "new",
                                      );
                                      break;
                                  }
                                },
                                validator: (String? value) {
                                  if (value == null) {
                                    return "من فضلك اختر نوع الاعلان";
                                  }
                                  return null;
                                },
                                value: null,
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          if(context.read<AdsAssetsCubit>().adsType == "discount")...[
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "المنتج المختار",
                                        style: Styles.inter14600black(context),
                                      ),
                                    ),
                                    if (context
                                        .read<AdsAssetsCubit>()
                                        .selectedProduct !=
                                        null)
                                      InkWell(
                                        onTap: () {
                                          SelectAdsProductBottomSheet.show(
                                            context,
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            AppConstants.sp5(context),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.sp5(context),
                                            ),
                                            color: AppColors.secondaryColor,
                                          ),
                                          child: SvgPicture.asset(
                                            AssetData.edit,
                                            color: Colors.white,
                                            width:
                                            MediaQuery.of(
                                              context,
                                            ).size.width *
                                                .06,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: AppConstants.height10(context)),
                                context.read<AdsAssetsCubit>().selectedProduct ==
                                    null
                                    ? InkWell(
                                  onTap: () {
                                    SelectAdsProductBottomSheet.show(
                                      context,
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      AppConstants.sp20(context),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xffF7F7F8),
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.sp10(context),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          AssetData.addCircle,
                                          color: AppColors.gray,
                                        ),
                                        Text(
                                          "اضافة المنتج",
                                          style: Styles.inter14600gray(
                                            context,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    : Container(
                                  padding: EdgeInsets.all(AppConstants.sp20(context)),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF7F7F8),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.sp10(context),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.black.withOpacity(.1),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          AppConstants.sp5(context),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gray
                                              .withOpacity(.3),
                                          borderRadius:
                                          BorderRadius.circular(
                                            AppConstants.sp10(
                                              context,
                                            ),
                                          ),
                                        ),
                                        child:
                                        DefaultCachedNetworkImage(
                                          imageUrl: context
                                              .read<
                                              AdsAssetsCubit
                                          >()
                                              .selectedProduct!
                                              .images!
                                              .first
                                              .attach,
                                          imageWidth:
                                          MediaQuery.of(
                                            context,
                                          ).size.width *
                                              .15,
                                          imageHeight:
                                          MediaQuery.of(
                                            context,
                                          ).size.width *
                                              .15,
                                        ),
                                      ),
                                      SizedBox(
                                        width: AppConstants.width10(
                                          context,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.read<AdsAssetsCubit>().selectedProduct!.mainCategory!.name ?? '',
                                              style: Styles.inter14600gray(
                                                context,
                                              ),
                                            ),
                                            SizedBox(height: AppConstants.height5(context),),
                                            Text(
                                              context
                                                  .read<AdsAssetsCubit>()
                                                  .selectedProduct!
                                                  .name!
                                                  .ar ??
                                                  '',
                                              style: Styles.inter16500black(
                                                context,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "السعر",
                                            style: Styles.inter16500black(
                                              context,
                                            ),
                                          ),
                                          Text(
                                            "${context.read<AdsAssetsCubit>().selectedProduct!.price ?? ''} جنيه",
                                            style: Styles.inter16500black(
                                              context,
                                            ).copyWith(
                                              color: AppColors.primaryColor
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: AppConstants.height20(context)),],
                          Text(
                            "عنوان الاعلان",
                            style: Styles.inter14500black(context),
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return "يجب ادخال هذا الحقل";
                              }
                            },
                            hintText: "اضافة عنوان الاعلان",
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
                          Text(
                            "وصف الاعلان",
                            style: Styles.inter14500black(context),
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return "يجب ادخال هذا الحقل";
                              }
                            },
                            hintText: "اضافة وصف الاعلان",
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
                          SizedBox(height: AppConstants.height20(context)),
                          BlocBuilder<AdsAssetsCubit, AdsAssetsState>(
                            builder: (context, frontIdState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "اضافة صورة او مرفق",
                                    style: Styles.inter14500black(context),
                                  ),
                                  SizedBox(height: AppConstants.height10(context)),
                                  FormField(
                                    validator: (value) {
                                      if (context.read<AdsAssetsCubit>().newImage ==
                                          null) {
                                        return "يجب اضافة صورة او مرفق";
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState<String> state) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: Radius.circular(
                                              AppConstants.sp10(context),
                                            ),
                                            color: AppColors.gray,

                                            dashPattern: const [5, 5],
                                            strokeWidth: 1.5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(
                                                  AppConstants.sp10(context),
                                                ),
                                              ),
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  .17,
                                              child: InkWell(
                                                onTap: () {
                                                  context
                                                      .read<AdsAssetsCubit>()
                                                      .selectNewImage(context);
                                                },
                                                child:
                                                    context
                                                            .read<AdsAssetsCubit>()
                                                            .newImage !=
                                                        null
                                                    ? Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                AppConstants.sp10(
                                                                  context,
                                                                ),
                                                              ),
                                                          color: Colors.grey[200],
                                                        ),
                                                        child: ClipRRect(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                AppConstants.sp10(
                                                                  context,
                                                                ),
                                                              ),
                                                          child: Image.file(
                                                            context
                                                                .read<
                                                                  AdsAssetsCubit
                                                                >()
                                                                .newImage!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      )
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                AssetData
                                                                    .uploadImage,
                                                                width:
                                                                    MediaQuery.of(
                                                                      context,
                                                                    ).size.height *
                                                                    .11,
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
                                              padding: EdgeInsets.only(
                                                top: AppConstants.height10(context),
                                              ),
                                              child: Text(
                                                state.errorText!,
                                                style:
                                                    Styles.inter16500black(
                                                      context,
                                                    ).copyWith(
                                                      fontWeight: FontWeight.w100,
                                                      color: Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          .012,
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
                    }
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width10(context),
            ),
            child: BlocConsumer<AddAdsCubit, AddAdsState>(
              builder: (context, state) {
                return state is AddAdsLoading
                    ? DefaultButton(
                        onPress: () {},
                        text: "جاري اضافة الاعلان....",
                        backgroundColor: AppColors.gray,
                        borderRadius: AppConstants.sp10(context),
                      )
                    : DefaultButton(
                        onPress: () async {
                          if (formNewKey.currentState!.validate()) {
                            context.read<AddAdsCubit>().addAds(
                              data: {
                                "title": newTitle.text.trim(),
                                "content": newDescription.text.trim(),
                                "image": await MultipartFile.fromFile(
                                  context
                                          .read<AdsAssetsCubit>()
                                          .newImage
                                          ?.path ??
                                      "",
                                ),
                              },
                            );
                          }
                        },
                        text: "اضافة الاعلان",
                        borderRadius: AppConstants.sp10(context),
                      );
              },
              listener: (BuildContext context, AddAdsState state) {
                if (state is AddAdsSuccess) {
                  context.read<AdsAssetsCubit>().newImage = null;
                  context.read<OfferBannerCubit>().fetchOfferBanners();
                  toast(text: "تم أضافة الاعلان بنجاح", color: Colors.green);
                } else if (state is AddAdsError) {
                  customSnackBar(
                    message: state.error,
                    color: AppColors.redColor,
                    context: context,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
