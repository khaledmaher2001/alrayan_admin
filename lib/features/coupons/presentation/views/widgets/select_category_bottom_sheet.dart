import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/shared_widgets/empty_widget.dart';
import '../../../../../../core/utils/assets/assets.dart';
import '../../../../../../core/utils/colors/colors.dart';
import '../../../../../../core/utils/constants.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../view_model/create_coupon_assets/create_coupon_assets_cubit.dart';

class SelectCategoriesBottomSheet extends StatefulWidget {
  const SelectCategoriesBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      useSafeArea: true,
      builder: (context) {
        return SelectCategoriesBottomSheet();
      },
    );
  }

  @override
  State<SelectCategoriesBottomSheet> createState() =>
      _SelectCategoriesBottomSheetState();
}

class _SelectCategoriesBottomSheetState
    extends State<SelectCategoriesBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
                    height: AppConstants.height5(context),
                    width: MediaQuery.sizeOf(context).width * .45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.width20(context),
                      ),
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    "أختر الاقسام",
                    style: Styles.inter16400white(
                      context,
                    ).copyWith(color: Colors.black),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CreateCouponAssetsCubit, CreateCouponAssetsState>(
                builder: (context, assetState) {
                  return BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                    builder: (context, state) {
                      if (state is GetCategoriesSuccessState) {
                        return context
                            .read<GetCategoriesCubit>()
                            .categoriesModel!
                            .data!
                            .isNotEmpty
                            ? GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width20(context),
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppConstants.width10(context),
                            mainAxisSpacing: AppConstants.height10(context),
                            childAspectRatio: 0.75,
                          ),
                          itemCount: context
                              .read<GetCategoriesCubit>()
                              .categoriesModel!
                              .data!
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            final category = context
                                .read<GetCategoriesCubit>()
                                .categoriesModel!
                                .data![index];
                            final isSelected = context
                                .read<CreateCouponAssetsCubit>()
                                .selectedCategories
                                .contains(category);

                            return InkWell(
                              onTap: () {
                                if (isSelected) {
                                  context
                                      .read<CreateCouponAssetsCubit>()
                                      .removeCategories(instance: category);
                                } else {
                                  context
                                      .read<CreateCouponAssetsCubit>()
                                      .selectCategories(instance: category);
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 6,
                                          spreadRadius: 0,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.sp10(context),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(AppConstants.sp10(context))),
                                          child: DefaultCachedNetworkImage(
                                            imageUrl: category.icon ?? '',
                                            imageHeight: MediaQuery.of(context).size.height * .1,
                                            imageWidth: MediaQuery.of(context).size.width,
                                          ),
                                        ),
                                        SizedBox(height: AppConstants.height10(context)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
                                          child: Text(
                                            category.name!.ar ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Styles.inter14500black(context),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: AppConstants.height5(context)),

                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(AppConstants.sp5(context)),
                                    child: Container(
                                      padding: EdgeInsets.all(AppConstants.sp5(context)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isSelected
                                          ? SvgPicture.asset(
                                        AssetData.checked,
                                        color: AppColors.primaryColor,
                                        width: MediaQuery.of(context).size.width*.06,
                                      )
                                          : SvgPicture.asset(
                                        AssetData.uncheck,
                                        color: AppColors.gray,
                                        width: MediaQuery.of(context).size.width*.06,

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                            : EmptyWidget(
                          icon: AssetData.search,
                          title: "لا يوجد اقسام",
                          description: "ابدأ في اضافة الاقسام اولا",
                        );

                      } else {
                        return ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.width20(context),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.sp10(context),
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[200]!,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        .11,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.sp5(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: AppConstants.height10(context),
                            );
                          },
                          itemCount: 5,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
