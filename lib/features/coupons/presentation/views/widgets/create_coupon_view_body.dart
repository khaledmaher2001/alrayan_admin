import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_category_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_product_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_users_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/shared_widgets/custom_dropdown_formfield.dart';
import '../../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../../core/utils/colors/colors.dart';
import '../../../../../../core/utils/constants.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../all_users/presentation/view_models/get_all_users/get_all_users_cubit.dart';
import '../view_model/create_coupon_assets/create_coupon_assets_cubit.dart';

class CreateCouponViewBody extends StatefulWidget {
  const CreateCouponViewBody({super.key});

  @override
  State<CreateCouponViewBody> createState() => _CreateCouponViewBodyState();
}

class _CreateCouponViewBodyState extends State<CreateCouponViewBody> {
  @override
  void initState() {
    context.read<CreateCouponAssetsCubit>().clearAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          CustomAppBar(title: "انشاء كوبون خصم", hasBack: true),
          SizedBox(height: AppConstants.height10(context)),
          BlocBuilder<CreateCouponAssetsCubit, CreateCouponAssetsState>(
            builder: (context, state) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: context
                              .read<CreateCouponAssetsCubit>()
                              .createCouponFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "مستخدمين الكوبون",
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
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  CustomDropDownButton(
                                    hintText: "اختر المستخدمين",
                                    items: ['كل المستخدمين', 'مستخدمين محددين'],
                                    borderRadius: AppConstants.sp10(context),
                                    hasBorder: true,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        .06,
                                    onChanged: (v) {
                                      switch (v) {
                                        case 'كل المستخدمين':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectUsersType(type: "all");
                                          break;
                                        case 'مستخدمين محددين':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectUsersType(
                                                type: "specific_users",
                                              );
                                          break;
                                      }
                                    },
                                    validator: (String? value) {
                                      if (value == null) {
                                        return "من فضلك اختر المستخدمين";
                                      }
                                      return null;
                                    },
                                    value: null,
                                  ),
                                ],
                              ),
                              if (context
                                      .read<CreateCouponAssetsCubit>()
                                      .usersType ==
                                  "specific_users")
                                Column(
                                  children: [
                                    SizedBox(
                                      height: AppConstants.height15(context),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "المستخدمين التي تم اختيارها",
                                            style: Styles.inter14600black(
                                              context,
                                            ),
                                          ),
                                        ),
                                        if (context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedUsers
                                            .isNotEmpty) ...[
                                          SizedBox(
                                            width: AppConstants.width20(
                                              context,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              SelectUsersBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp5(context),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp5(context),
                                                    ),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(
                                      height: AppConstants.height10(context),
                                    ),
                                    context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedUsers
                                            .isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectUsersBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp20(context),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffF7F7F8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp10(
                                                        context,
                                                      ),
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
                                                    "اضافة المستخدمين",
                                                    style:
                                                        Styles.inter14600gray(
                                                          context,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: context
                                                  .read<
                                                    CreateCouponAssetsCubit
                                                  >()
                                                  .selectedUsers
                                                  .length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.065,
                                                      // نصف عرض الصورة القديمة
                                                      backgroundColor:
                                                          Colors
                                                              .primaries[index %
                                                              Colors
                                                                  .primaries
                                                                  .length],
                                                      // لون عشوائي لكل يوزر
                                                      child: Text(
                                                        (context
                                                                    .read<
                                                                      CreateCouponAssetsCubit
                                                                    >()
                                                                    .selectedUsers[index]
                                                                    .fullName ??
                                                                '')
                                                            .split(' ')
                                                            .take(2)
                                                            .map(
                                                              (e) =>
                                                                  e.isNotEmpty
                                                                  ? e[0]
                                                                  : '',
                                                            )
                                                            .join()
                                                            .toUpperCase(),
                                                        // أول حرفين من الاسم
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          AppConstants.height5(
                                                            context,
                                                          ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          context
                                                              .read<
                                                                CreateCouponAssetsCubit
                                                              >()
                                                              .selectedUsers[index]
                                                              .fullName!,
                                                          style:
                                                              Styles.inter16500black(
                                                                context,
                                                              ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                  context,
                                                                ),
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                    CreateCouponAssetsCubit
                                                                  >()
                                                                  .removeUser(
                                                                    instance: context
                                                                        .read<
                                                                          CreateCouponAssetsCubit
                                                                        >()
                                                                        .selectedUsers[index],
                                                                  );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                      context,
                                                                    ) /
                                                                    2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .redColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      AppConstants.sp5(
                                                                        context,
                                                                      ),
                                                                    ),
                                                              ),
                                                              child:
                                                                  SvgPicture.asset(
                                                                    AssetData
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return SizedBox(
                                                      width:
                                                          AppConstants.width10(
                                                            context,
                                                          ),
                                                    );
                                                  },
                                            ),
                                          ),
                                  ],
                                ),
                              SizedBox(height: AppConstants.height15(context)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "نوع الكوبون",
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
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  CustomDropDownButton(
                                    hintText: "نوع كوبون الخصم",
                                    items: [
                                      'شحن مجاني',
                                      'خصم نسبة مئوية',
                                      'خصم قيمة ثابتة بالجنية',
                                      'خصم علي منتج معين',
                                      'خصم علي قسم معين',
                                    ],
                                    borderRadius: AppConstants.sp10(context),
                                    hasBorder: true,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        .06,
                                    onChanged: (v) {
                                      switch (v) {
                                        case 'شحن مجاني':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectCouponType(
                                                type: "free_shipping",
                                              );
                                          break;
                                        case 'خصم نسبة مئوية':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectCouponType(
                                                type: "percentage",
                                              );
                                          break;
                                        case 'خصم قيمة ثابتة بالجنية':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectCouponType(
                                                type: "fixed_amount",
                                              );
                                          break;
                                        case 'خصم علي منتج معين':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectCouponType(
                                                type: "product_specific",
                                              );
                                          break;
                                        case 'خصم علي قسم معين':
                                          context
                                              .read<CreateCouponAssetsCubit>()
                                              .selectCouponType(
                                                type: "category_specific",
                                              );
                                          break;
                                      }
                                    },
                                    validator: (String? value) {
                                      if (value == null) {
                                        return "من فضلك اختر نوع الكوبون";
                                      }
                                      return null;
                                    },
                                    value: null,
                                  ),
                                ],
                              ),
                              if (context
                                      .read<CreateCouponAssetsCubit>()
                                      .couponType ==
                                  "product_specific")
                                Column(
                                  children: [
                                    SizedBox(
                                      height: AppConstants.height15(context),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "المنتجات التي تم اختيارها",
                                            style: Styles.inter14600black(
                                              context,
                                            ),
                                          ),
                                        ),
                                        if (context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedProducts
                                            .isNotEmpty) ...[
                                          SizedBox(
                                            width: AppConstants.width20(
                                              context,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              SelectProductBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp5(context),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp5(context),
                                                    ),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(
                                      height: AppConstants.height10(context),
                                    ),
                                    context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedProducts
                                            .isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectProductBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp20(context),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffF7F7F8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp10(
                                                        context,
                                                      ),
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
                                                    "اضافة المنتجات",
                                                    style:
                                                        Styles.inter14600gray(
                                                          context,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: context
                                                  .read<
                                                    CreateCouponAssetsCubit
                                                  >()
                                                  .selectedProducts
                                                  .length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                  context,
                                                                ),
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .gray
                                                                .withOpacity(
                                                                  .3,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  AppConstants.sp10(
                                                                    context,
                                                                  ),
                                                                ),
                                                          ),
                                                          child: DefaultCachedNetworkImage(
                                                            imageUrl: context
                                                                .read<
                                                                  CreateCouponAssetsCubit
                                                                >()
                                                                .selectedProducts[index]
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
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                  context,
                                                                ),
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                    CreateCouponAssetsCubit
                                                                  >()
                                                                  .removeProduct(
                                                                    instance: context
                                                                        .read<
                                                                          CreateCouponAssetsCubit
                                                                        >()
                                                                        .selectedProducts[index],
                                                                  );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                      context,
                                                                    ) /
                                                                    2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      AppConstants.sp5(
                                                                        context,
                                                                      ),
                                                                    ),
                                                              ),
                                                              child:
                                                                  SvgPicture.asset(
                                                                    AssetData
                                                                        .delete,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          AppConstants.height5(
                                                            context,
                                                          ),
                                                    ),
                                                    Text(
                                                      context
                                                              .read<
                                                                CreateCouponAssetsCubit
                                                              >()
                                                              .selectedProducts[index]
                                                              .name!
                                                              .ar ??
                                                          '',
                                                      style:
                                                          Styles.inter16500black(
                                                            context,
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return SizedBox(
                                                      width:
                                                          AppConstants.width10(
                                                            context,
                                                          ),
                                                    );
                                                  },
                                            ),
                                          ),
                                  ],
                                ),
                              if (context
                                      .read<CreateCouponAssetsCubit>()
                                      .couponType ==
                                  "category_specific")
                                Column(
                                  children: [
                                    SizedBox(
                                      height: AppConstants.height15(context),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "الاقسام التي تم اختيارها",
                                            style: Styles.inter14600black(
                                              context,
                                            ),
                                          ),
                                        ),
                                        if (context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedCategories
                                            .isNotEmpty) ...[
                                          SizedBox(
                                            width: AppConstants.width20(
                                              context,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              SelectCategoriesBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp5(context),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp5(context),
                                                    ),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(
                                      height: AppConstants.height10(context),
                                    ),
                                    context
                                            .read<CreateCouponAssetsCubit>()
                                            .selectedCategories
                                            .isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectCategoriesBottomSheet.show(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp20(context),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffF7F7F8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppConstants.sp10(
                                                        context,
                                                      ),
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
                                                    "اضافة الاقسام",
                                                    style:
                                                        Styles.inter14600gray(
                                                          context,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: context
                                                  .read<
                                                    CreateCouponAssetsCubit
                                                  >()
                                                  .selectedCategories
                                                  .length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                  context,
                                                                ),
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .gray
                                                                .withOpacity(
                                                                  .3,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  AppConstants.sp10(
                                                                    context,
                                                                  ),
                                                                ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  AppConstants.sp10(
                                                                    context,
                                                                  ),
                                                                ),
                                                            child: DefaultCachedNetworkImage(
                                                              imageUrl: context
                                                                  .read<
                                                                    CreateCouponAssetsCubit
                                                                  >()
                                                                  .selectedCategories[index]
                                                                  .icon,
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
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                  context,
                                                                ),
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                    CreateCouponAssetsCubit
                                                                  >()
                                                                  .removeCategories(
                                                                    instance: context
                                                                        .read<
                                                                          CreateCouponAssetsCubit
                                                                        >()
                                                                        .selectedCategories[index],
                                                                  );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                AppConstants.sp5(
                                                                      context,
                                                                    ) /
                                                                    2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      AppConstants.sp5(
                                                                        context,
                                                                      ),
                                                                    ),
                                                              ),
                                                              child:
                                                                  SvgPicture.asset(
                                                                    AssetData
                                                                        .delete,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          AppConstants.height5(
                                                            context,
                                                          ),
                                                    ),
                                                    Text(
                                                      context
                                                              .read<
                                                                CreateCouponAssetsCubit
                                                              >()
                                                              .selectedCategories[index]
                                                              .name!
                                                              .ar ??
                                                          '',
                                                      style:
                                                          Styles.inter16500black(
                                                            context,
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return SizedBox(
                                                      width:
                                                          AppConstants.width10(
                                                            context,
                                                          ),
                                                    );
                                                  },
                                            ),
                                          ),
                                  ],
                                ),
                              SizedBox(height: AppConstants.height15(context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "تاريخ البداية",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                              Styles.inter14600black(
                                                context,
                                              ).copyWith(
                                                color: AppColors.redColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: AppConstants.height5(context),),
                                        DefaultTextFormField(
                                          textInputType: TextInputType.text,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .dateController,
                                          readOnly: true,
                                          fillColor: const Color(0xffF7F7F8),
                                          hintText: "تاريخ البداية",
                                          suffixIcon: GestureDetector(
                                            child: Icon(
                                              Icons.calendar_month,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          validation: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return "يجب ادخال هذا الحقل";
                                            }
                                            return null;
                                          },
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      context
                                                          .read<
                                                            CreateCouponAssetsCubit
                                                          >()
                                                          .selectedDate ??
                                                      DateTime.now(),
                                                  firstDate: DateTime(1920),
                                                  lastDate: DateTime.now(),
                                                );
                                            if (picked != null &&
                                                picked !=
                                                    context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .selectedDate) {
                                              setState(() {
                                                context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .selectedDate =
                                                    picked;
                                                context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .dateController
                                                        .text =
                                                    '${context.read<CreateCouponAssetsCubit>().selectedDate!.year} / ${context.read<CreateCouponAssetsCubit>().selectedDate!.month} / ${context.read<CreateCouponAssetsCubit>().selectedDate!.day}';
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.width20(context),),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "تاريخ الانتهاء",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                              Styles.inter14600black(
                                                context,
                                              ).copyWith(
                                                color: AppColors.redColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppConstants.height5(context),
                                        ),
                                        DefaultTextFormField(
                                          textInputType: TextInputType.text,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .dateController,
                                          readOnly: true,
                                          fillColor: const Color(0xffF7F7F8),
                                          hintText: "تاريخ الانتهاء",
                                          suffixIcon: GestureDetector(
                                            child: Icon(
                                              Icons.calendar_month,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          validation: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return "يجب ادخال هذا الحقل";
                                            }
                                            return null;
                                          },
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      context
                                                          .read<
                                                            CreateCouponAssetsCubit
                                                          >()
                                                          .selectedDate ??
                                                      DateTime.now(),
                                                  firstDate: DateTime(1920),
                                                  lastDate: DateTime.now(),
                                                );
                                            if (picked != null &&
                                                picked !=
                                                    context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .selectedDate) {
                                              setState(() {
                                                context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .selectedDate =
                                                    picked;
                                                context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .dateController
                                                        .text =
                                                    '${context.read<CreateCouponAssetsCubit>().selectedDate!.year} / ${context.read<CreateCouponAssetsCubit>().selectedDate!.month} / ${context.read<CreateCouponAssetsCubit>().selectedDate!.day}';
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "قيمة الخصم",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                                  Styles.inter14600black(
                                                    context,
                                                  ).copyWith(
                                                    color: AppColors.redColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppConstants.height5(context),
                                        ),
                                        DefaultTextFormField(
                                          validation: (String? value) {
                                            if (value!.isEmpty) {
                                              return "من فضلك ادخل قيمة الخصم";
                                            }
                                            return null;
                                          },
                                          style: Styles.inter14600black(
                                            context,
                                          ),
                                          fillColor: const Color(0xffF7F7F8),
                                          contentPaddingHorizontal:
                                              AppConstants.width15(context),
                                          hintText: "قيمة الخصم",
                                          textInputType: TextInputType.number,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .discountPercentageValueController,
                                          contentPaddingVertical:
                                              AppConstants.height15(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppConstants.width20(context),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "مرات الاستخدام",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                                  Styles.inter14600black(
                                                    context,
                                                  ).copyWith(
                                                    color: AppColors.redColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppConstants.height5(context),
                                        ),
                                        DefaultTextFormField(
                                          validation: (String? value) {
                                            if (value!.isEmpty) {
                                              return "من فضلك ادخل مرات الاستخدام";
                                            }
                                            return null;
                                          },
                                          style: Styles.inter14600black(
                                            context,
                                          ),
                                          fillColor: const Color(0xffF7F7F8),
                                          contentPaddingHorizontal:
                                              AppConstants.width15(context),
                                          hintText: "مرات الاستخدام",
                                          textInputType: TextInputType.number,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .usageLimitController,
                                          contentPaddingVertical:
                                              AppConstants.height15(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "كود الخصم",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                                  Styles.inter14600black(
                                                    context,
                                                  ).copyWith(
                                                    color: AppColors.redColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppConstants.height5(context),
                                        ),
                                        DefaultTextFormField(
                                          validation: (String? value) {
                                            if (value!.isEmpty) {
                                              return "من فضلك ادخل كود الخصم";
                                            }
                                            return null;
                                          },
                                          style: Styles.inter14600black(
                                            context,
                                          ),
                                          fillColor: const Color(0xffF7F7F8),
                                          contentPaddingHorizontal:
                                              AppConstants.width15(context),
                                          hintText: "كود الخصم",
                                          textInputType: TextInputType.text,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .codeController,
                                          contentPaddingVertical:
                                              AppConstants.height15(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppConstants.width20(context),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "اسم الكوبون",
                                              style: Styles.inter14600black(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              "*",
                                              style:
                                                  Styles.inter14600black(
                                                    context,
                                                  ).copyWith(
                                                    color: AppColors.redColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: AppConstants.height5(context),
                                        ),
                                        DefaultTextFormField(
                                          validation: (String? value) {
                                            if (value!.isEmpty) {
                                              return "من فضلك ادخل اسم للكوبون";
                                            }
                                            return null;
                                          },
                                          style: Styles.inter14600black(
                                            context,
                                          ),
                                          fillColor: const Color(0xffF7F7F8),
                                          contentPaddingHorizontal:
                                              AppConstants.width15(context),
                                          hintText: "اسم الكوبون",
                                          textInputType: TextInputType.text,
                                          controller: context
                                              .read<CreateCouponAssetsCubit>()
                                              .nameController,
                                          contentPaddingVertical:
                                              AppConstants.height15(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "وصف الكوبون",
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
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  DefaultTextFormField(
                                    validation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "من فضلك ادخل وصف الكوبون";
                                      }
                                      return null;
                                    },
                                    style: Styles.inter14600black(context),
                                    fillColor: const Color(0xffF7F7F8),
                                    contentPaddingHorizontal:
                                        AppConstants.width15(context),
                                    hintText: "وصف الكوبون",
                                    textInputType: TextInputType.text,
                                    controller: context
                                        .read<CreateCouponAssetsCubit>()
                                        .descriptionController,
                                    contentPaddingVertical:
                                        AppConstants.height15(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppConstants.height20(context)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width10(context),
            ),
            child: DefaultButton(
              onPress: () {},
              text: "انشاء الكوبون",
              borderRadius: AppConstants.sp10(context),
              height: AppConstants.height15(context),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}
