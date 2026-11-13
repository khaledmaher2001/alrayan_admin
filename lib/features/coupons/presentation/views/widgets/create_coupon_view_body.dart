import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo_impl.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon/create_coupon_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon/create_coupon_states.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/edit_coupon/edit_coupon_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/edit_coupon/edit_coupon_states.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/get_coupons/get_coupons_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/custom_coupon_field.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_category_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_product_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_users_bottom_sheet.dart';
import 'package:alrayan_admin/features/all_users/data/models/all_users_model.dart' as user;
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart' as cat;
import 'package:alrayan_admin/features/products/data/models/products_model.dart' as prod;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/shared_widgets/custom_dropdown_formfield.dart';
import '../../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../../core/utils/colors/colors.dart';
import '../../../../../../core/utils/constants.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../view_model/create_coupon_assets/create_coupon_assets_cubit.dart';

class CreateCouponViewBody extends StatefulWidget {
  const CreateCouponViewBody({super.key, this.editingCoupon});

  final Items? editingCoupon;

  @override
  State<CreateCouponViewBody> createState() => _CreateCouponViewBodyState();
}

class _CreateCouponViewBodyState extends State<CreateCouponViewBody> {
  late CreateCouponAssetsCubit couponAssetsCubit;

  bool get isEditing => widget.editingCoupon != null;

  @override
  void initState() {
    couponAssetsCubit = context.read<CreateCouponAssetsCubit>();
    if (isEditing) {
      _prefillFromCoupon(widget.editingCoupon!);
      final userIds = widget.editingCoupon!.applicableUserGroups ?? [];
      if (userIds.isNotEmpty) {
        _loadSelectedUsers(userIds);
      }
    } else {
      couponAssetsCubit.clearAllData();
    }
    super.initState();
  }

  Future<void> _loadSelectedUsers(List<int> ids) async {
    final repo = getIt<AllUsersRepoImpl>();
    final results = await Future.wait(ids.map((id) => repo.getUserById(id)));
    final users = <user.Items>[];
    for (final result in results) {
      result.fold((_) {}, (detail) => users.add(
        user.Items(
          id: detail.id,
          fullName: detail.fullName,
          email: detail.email,
          gender: detail.gender,
          phoneNumber: detail.phoneNumber,
          isEmailVerified: detail.isEmailVerified,
          role: detail.role,
          createdAt: detail.createdAt,
        ),
      ));
    }
    if (!mounted) return;
    couponAssetsCubit.setSelectedUsers(users);
  }

  void _prefillFromCoupon(Items coupon) {
    couponAssetsCubit.clearAllData();
    couponAssetsCubit.codeController.text = coupon.code ?? "";
    couponAssetsCubit.descriptionArController.text = coupon.description?.ar ?? "";
    couponAssetsCubit.descriptionEnController.text = coupon.description?.en ?? "";
    couponAssetsCubit.discountValueController.text = coupon.discountValue?.toString() ?? "";
    couponAssetsCubit.maxDiscountAmountController.text = coupon.maxDiscountAmount?.toString() ?? "";
    couponAssetsCubit.minOrderAmountController.text = coupon.minOrderAmount?.toString() ?? "";
    couponAssetsCubit.usageLimitController.text = coupon.usageLimit?.toString() ?? "";
    couponAssetsCubit.usageLimitPerUserController.text = coupon.usageLimitPerUser?.toString() ?? "";
    couponAssetsCubit.splitValueController.text = coupon.splitValue?.toString() ?? "";
    if (coupon.validFrom != null) {
      couponAssetsCubit.startDateController.text = coupon.validFrom!;
      couponAssetsCubit.selectedStartDate = DateTime.tryParse(coupon.validFrom!);
    }
    if (coupon.validTo != null) {
      couponAssetsCubit.endDateController.text = coupon.validTo!;
      couponAssetsCubit.selectedEndDate = DateTime.tryParse(coupon.validTo!);
    }
    couponAssetsCubit.couponType = coupon.isSplitCoupon == true ? "fixed_split" : coupon.discountType;
    couponAssetsCubit.selectedProducts = (coupon.products ?? []).map(_productFromCouponProduct).toList();
    couponAssetsCubit.selectedCategories = (coupon.categories ?? []).map(_categoryFromCouponCategory).toList();
    // selectedUsers is filled in separately by _loadSelectedUsers, since it
    // needs an async lookup (the coupon only carries user ids, not names).
    couponAssetsCubit.usersType =
        (coupon.applicableUserGroups ?? []).isNotEmpty ? "specific_users" : "all";
    couponAssetsCubit.isHidden = coupon.isHidden ?? false;
  }

  // coupon.products/categories (coupons_model) and the product/category pickers'
  // Items/Data (products_model/categories_model) are separate generated models
  // for the same shape; this remaps one into the other so an existing
  // product-specific or category-specific coupon shows its selections when edited.
  prod.Items _productFromCouponProduct(Products product) {
    return prod.Items.fromJson({
      'id': product.id,
      'name': {'ar': product.name, 'en': product.name},
      'price': product.price,
      'images': product.images?.map((img) => {'id': img.id, 'attach': img.attach}).toList(),
    });
  }

  cat.Data _categoryFromCouponCategory(Categories category) {
    return cat.Data.fromJson({
      'id': category.id,
      'icon': null,
      'name': {'ar': category.name, 'en': category.name},
    });
  }

  Map<String, dynamic> _buildCouponPayload() {
    return {
      "code": couponAssetsCubit.codeController.text.trim(),
      "description": {
        "en": couponAssetsCubit.descriptionEnController.text.trim(),
        "ar": couponAssetsCubit.descriptionArController.text.trim(),
      },
      "discountType": couponAssetsCubit.couponType == "fixed_split" ? "fixed_amount" : couponAssetsCubit.couponType,
      "discountValue":
          couponAssetsCubit.couponType == "free_shipping" ? "0" : couponAssetsCubit.discountValueController.text.trim(),
      if (couponAssetsCubit.couponType != "free_shipping")
        "maxDiscountAmount": couponAssetsCubit.maxDiscountAmountController.text.trim(),
      if (couponAssetsCubit.couponType != "free_shipping")
        "minOrderAmount": couponAssetsCubit.minOrderAmountController.text.trim(),
      "status": "active",
      "validFrom": couponAssetsCubit.startDateController.text.trim(),
      "validTo": couponAssetsCubit.endDateController.text.trim(),
      "usageLimit": couponAssetsCubit.usageLimitController.text.trim(),
      "usageLimitPerUser": couponAssetsCubit.usageLimitPerUserController.text.trim(),
      "applicableCategories": couponAssetsCubit.selectedCategories.map((e) => e.id).toList(),
      "applicableProducts": couponAssetsCubit.selectedProducts.map((e) => e.id).toList(),
      "applicableUserGroups": couponAssetsCubit.usersType == "specific_users"
          ? couponAssetsCubit.selectedUsers.map((e) => e.id).toList()
          : <int?>[],
      "isStackable": false,
      "splitValue": couponAssetsCubit.couponType == "fixed_split" ? couponAssetsCubit.splitValueController.text.trim() : null,
      "isHidden": couponAssetsCubit.usersType == "all" ? couponAssetsCubit.isHidden : false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CustomAppBar(title: isEditing ? "s_edit_coupon".tr() : "s_create_discount_coupon".tr(), hasBack: true,textColor: Colors.black,withNotifications: false,),
          SizedBox(height: AppConstants.height10(context)),
          BlocBuilder<CreateCouponAssetsCubit, CreateCouponAssetsState>(
            builder: (context, state) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: couponAssetsCubit.createCouponFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("s_coupon_users".tr(), style: Styles.inter14600black(context)),
                                      Text(
                                        "*",
                                        style: Styles.inter14600black(context).copyWith(color: AppColors.redColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
                                  CustomDropDownButton(
                                    hintText: "s_choose_users".tr(),
                                    items: ['لكل العملاء', 'عملاء محددين'],
                                    borderRadius: AppConstants.sp10(context),
                                    hasBorder: true,
                                    height: MediaQuery.of(context).size.height * .06,
                                    onChanged: (v) {
                                      switch (v) {
                                        case 'لكل العملاء':
                                          couponAssetsCubit.selectUsersType(type: "all");
                                          break;
                                        case 'عملاء محددين':
                                          couponAssetsCubit.selectUsersType(type: "specific_users");
                                          break;
                                      }
                                    },
                                    validator: (String? value) {
                                      if (value == null) {
                                        return "s_please_choose_the_users".tr();
                                      }
                                      return null;
                                    },
                                    value: couponAssetsCubit.usersType == "all"
                                        ? 'لكل العملاء'
                                        : couponAssetsCubit.usersType == "specific_users"
                                            ? 'عملاء محددين'
                                            : null,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.sp20(context),
                                  vertical: AppConstants.sp10(context),
                                ),
                                decoration: BoxDecoration(
                                  color: couponAssetsCubit.usersType != "all"
                                      ? DsColor.fill
                                      : couponAssetsCubit.isHidden
                                          ? DsColor.warningBg
                                          : const Color(0xffF7F7F8),
                                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                  border: Border.all(
                                    color: couponAssetsCubit.usersType != "all"
                                        ? DsColor.border
                                        : couponAssetsCubit.isHidden
                                            ? DsColor.warning
                                            : DsColor.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("s_hide_coupon".tr(), style: Styles.inter14600black(context)),
                                          SizedBox(height: AppConstants.height5(context) / 2),
                                          Text(
                                            couponAssetsCubit.usersType != "all"
                                                ? "s_not_available_a_coupon_for_specific_".tr()
                                                : couponAssetsCubit.isHidden
                                                    ? "s_the_coupon_is_hidden_and_only_shows_".tr()
                                                    : "s_the_coupon_is_visible_to_all_users".tr(),
                                            style: Styles.inter12500Black(context).copyWith(
                                              color: couponAssetsCubit.usersType != "all"
                                                  ? DsColor.textMuted
                                                  : couponAssetsCubit.isHidden
                                                      ? DsColor.warning
                                                      : DsColor.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: couponAssetsCubit.usersType == "all" ? couponAssetsCubit.isHidden : false,
                                      activeThumbColor: DsColor.warning,
                                      onChanged: couponAssetsCubit.usersType == "all"
                                          ? (value) => couponAssetsCubit.toggleIsHidden(value)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              if (context.read<CreateCouponAssetsCubit>().usersType == "specific_users")
                                Column(
                                  children: [
                                    SizedBox(height: AppConstants.height15(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "s_selected_users".tr(),
                                            style: Styles.inter14600black(context),
                                          ),
                                        ),
                                        if (context.read<CreateCouponAssetsCubit>().selectedUsers.isNotEmpty) ...[
                                          SizedBox(width: AppConstants.width20(context)),
                                          InkWell(
                                            onTap: () {
                                              SelectUsersBottomSheet.show(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(AppConstants.sp5(context)),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width: MediaQuery.of(context).size.width * .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: AppConstants.height10(context)),
                                    couponAssetsCubit.selectedUsers.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectUsersBottomSheet.show(context);
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
                                                  Text("s_add_users".tr(), style: Styles.inter14600gray(context)),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context).size.height * .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: couponAssetsCubit.selectedUsers.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: MediaQuery.of(context).size.width * 0.065,
                                                      // نصف عرض الصورة القديمة
                                                      backgroundColor:
                                                          DsColor.primarySoft, // initials avatar: one neutral brand tint, not a random colour
                                                      child: Text(
                                                        (context
                                                                    .read<CreateCouponAssetsCubit>()
                                                                    .selectedUsers[index]
                                                                    .fullName ??
                                                                '')
                                                            .split(' ')
                                                            .take(2)
                                                            .map((e) => e.isNotEmpty ? e[0] : '')
                                                            .join()
                                                            .toUpperCase(),
                                                        // أول حرفين من الاسم
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: AppConstants.height5(context)),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          context
                                                              .read<CreateCouponAssetsCubit>()
                                                              .selectedUsers[index]
                                                              .fullName ??
                                                              context.read<CreateCouponAssetsCubit>().selectedUsers[index].phoneNumber ??
                                                              '',
                                                          style: Styles.inter16500black(context),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              couponAssetsCubit.removeUser(
                                                                instance: context
                                                                    .read<CreateCouponAssetsCubit>()
                                                                    .selectedUsers[index],
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(AppConstants.sp5(context) / 2),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.redColor,
                                                                borderRadius: BorderRadius.circular(
                                                                  AppConstants.sp5(context),
                                                                ),
                                                              ),
                                                              child: SvgPicture.asset(
                                                                AssetData.delete,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder: (BuildContext context, int index) {
                                                return SizedBox(width: AppConstants.width10(context));
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
                                      Text("s_coupon_type".tr(), style: Styles.inter14600black(context)),
                                      Text(
                                        "*",
                                        style: Styles.inter14600black(context).copyWith(color: AppColors.redColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
                                  CustomDropDownButton(
                                    hintText: "s_discount_coupon_type".tr(),
                                    items: [
                                      'كوبون مجزئ',
                                      'شحن مجاني',
                                      'خصم نسبة مئوية',
                                      'خصم قيمة ثابتة بالجنية',
                                      'خصم علي منتج معين',
                                      'خصم علي قسم معين',
                                    ],
                                    borderRadius: AppConstants.sp10(context),
                                    hasBorder: true,
                                    height: MediaQuery.of(context).size.height * .06,
                                    onChanged: (v) {
                                      switch (v) {
                                        case 'كوبون مجزئ':
                                          couponAssetsCubit.selectCouponType(type: "fixed_split");
                                          break;
                                          case 'شحن مجاني':
                                          couponAssetsCubit.selectCouponType(type: "free_shipping");
                                          break;
                                        case 'خصم نسبة مئوية':
                                          couponAssetsCubit.selectCouponType(type: "percentage");
                                          break;
                                        case 'خصم قيمة ثابتة بالجنية':
                                          couponAssetsCubit.selectCouponType(type: "fixed_amount");
                                          break;
                                        case 'خصم علي منتج معين':
                                          couponAssetsCubit.selectCouponType(type: "product_specific");
                                          break;
                                        case 'خصم علي قسم معين':
                                          couponAssetsCubit.selectCouponType(type: "category_specific");
                                          break;
                                      }
                                    },
                                    validator: (String? value) {
                                      if (value == null) {
                                        return "s_please_choose_the_coupon_type".tr();
                                      }
                                      return null;
                                    },
                                    value: const {
                                      "fixed_split": 'كوبون مجزئ',
                                      "free_shipping": 'شحن مجاني',
                                      "percentage": 'خصم نسبة مئوية',
                                      "fixed_amount": 'خصم قيمة ثابتة بالجنية',
                                      "product_specific": 'خصم علي منتج معين',
                                      "category_specific": 'خصم علي قسم معين',
                                    }[couponAssetsCubit.couponType],
                                  ),
                                ],
                              ),
                              if (context.read<CreateCouponAssetsCubit>().couponType == "product_specific")
                                Column(
                                  children: [
                                    SizedBox(height: AppConstants.height15(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "s_selected_products".tr(),
                                            style: Styles.inter14600black(context),
                                          ),
                                        ),
                                        if (context.read<CreateCouponAssetsCubit>().selectedProducts.isNotEmpty) ...[
                                          SizedBox(width: AppConstants.width20(context)),
                                          InkWell(
                                            onTap: () {
                                              SelectProductBottomSheet.show(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(AppConstants.sp5(context)),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width: MediaQuery.of(context).size.width * .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: AppConstants.height10(context)),
                                    couponAssetsCubit.selectedProducts.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectProductBottomSheet.show(context);
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
                                                  Text("s_add_products".tr(), style: Styles.inter14600gray(context)),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context).size.height * .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: context
                                                  .read<CreateCouponAssetsCubit>()
                                                  .selectedProducts
                                                  .length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.gray.withOpacity(.3),
                                                            borderRadius: BorderRadius.circular(
                                                              AppConstants.sp10(context),
                                                            ),
                                                          ),
                                                          child: DefaultCachedNetworkImage(
                                                            imageUrl: context
                                                                .read<CreateCouponAssetsCubit>()
                                                                .selectedProducts[index]
                                                                .images!
                                                                .first
                                                                .attach,
                                                            imageWidth: MediaQuery.of(context).size.width * .15,
                                                            imageHeight: MediaQuery.of(context).size.width * .15,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              couponAssetsCubit.removeProduct(
                                                                instance: context
                                                                    .read<CreateCouponAssetsCubit>()
                                                                    .selectedProducts[index],
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(AppConstants.sp5(context) / 2),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(
                                                                  AppConstants.sp5(context),
                                                                ),
                                                              ),
                                                              child: SvgPicture.asset(AssetData.delete),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: AppConstants.height5(context)),
                                                    Text(
                                                      context
                                                              .read<CreateCouponAssetsCubit>()
                                                              .selectedProducts[index]
                                                              .name!
                                                              .ar ??
                                                          '',
                                                      style: Styles.inter16500black(context),
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder: (BuildContext context, int index) {
                                                return SizedBox(width: AppConstants.width10(context));
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                              if (context.read<CreateCouponAssetsCubit>().couponType == "category_specific")
                                Column(
                                  children: [
                                    SizedBox(height: AppConstants.height15(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "s_selected_categories".tr(),
                                            style: Styles.inter14600black(context),
                                          ),
                                        ),
                                        if (context.read<CreateCouponAssetsCubit>().selectedCategories.isNotEmpty) ...[
                                          SizedBox(width: AppConstants.width20(context)),
                                          InkWell(
                                            onTap: () {
                                              SelectCategoriesBottomSheet.show(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(AppConstants.sp5(context)),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                                color: AppColors.secondaryColor,
                                              ),
                                              child: SvgPicture.asset(
                                                AssetData.addCircle,
                                                width: MediaQuery.of(context).size.width * .06,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: AppConstants.height10(context)),
                                    couponAssetsCubit.selectedCategories.isEmpty
                                        ? InkWell(
                                            onTap: () {
                                              SelectCategoriesBottomSheet.show(context);
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
                                                  Text("s_add_categories".tr(), style: Styles.inter14600gray(context)),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context).size.height * .12,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: context
                                                  .read<CreateCouponAssetsCubit>()
                                                  .selectedCategories
                                                  .length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.gray.withOpacity(.3),
                                                            borderRadius: BorderRadius.circular(
                                                              AppConstants.sp10(context),
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(
                                                              AppConstants.sp10(context),
                                                            ),
                                                            child: DefaultCachedNetworkImage(
                                                              imageUrl: context
                                                                  .read<CreateCouponAssetsCubit>()
                                                                  .selectedCategories[index]
                                                                  .icon,
                                                              imageWidth: MediaQuery.of(context).size.width * .15,
                                                              imageHeight: MediaQuery.of(context).size.width * .15,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(AppConstants.sp5(context)),
                                                          child: InkWell(
                                                            onTap: () {
                                                              couponAssetsCubit.removeCategories(
                                                                instance: context
                                                                    .read<CreateCouponAssetsCubit>()
                                                                    .selectedCategories[index],
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(AppConstants.sp5(context) / 2),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(
                                                                  AppConstants.sp5(context),
                                                                ),
                                                              ),
                                                              child: SvgPicture.asset(AssetData.delete),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: AppConstants.height5(context)),
                                                    Text(
                                                      context
                                                              .read<CreateCouponAssetsCubit>()
                                                              .selectedCategories[index]
                                                              .name!
                                                              .ar ??
                                                          '',
                                                      style: Styles.inter16500black(context),
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder: (BuildContext context, int index) {
                                                return SizedBox(width: AppConstants.width10(context));
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                              SizedBox(height: AppConstants.height15(context)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child:  CustomCouponField(
                                      title: "s_discount_code".tr(),
                                      hint: "s_discount_code".tr(),
                                      controller: couponAssetsCubit.codeController,
                                      keyboardType: TextInputType.text,
                                      validationText: "s_please_enter_the_discount_code".tr(),
                                    ),
                                  ),
                                  if(couponAssetsCubit.couponType!= "free_shipping")...[SizedBox(width: AppConstants.width20(context)),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("s_discount_value".tr(), style: Styles.inter14600black(context)),
                                              Text("*", style: Styles.inter14600black(context).copyWith(color: AppColors.redColor)),
                                            ],
                                          ),
                                          SizedBox(height: AppConstants.height5(context)),
                                          DefaultTextFormField(
                                            onTap: (){},
                                            validation: (String? value) {
                                              if (value == null || value.isEmpty) {
                                                return "s_please_enter_the_discount_value".tr();
                                              }else if(couponAssetsCubit.couponType== "percentage")
                                                {
                                                  if(int.parse(value)>100)
                                                    {
                                                      return "s_maximum_discount_is_100".tr();
                                                    }
                                                }
                                              return null;
                                            },
                                            style: Styles.inter14600black(context),
                                            fillColor: const Color(0xffF7F7F8),
                                            contentPaddingHorizontal: AppConstants.width15(context),
                                            hintText: "s_discount_value".tr(),
                                            textInputType: TextInputType.number,
                                            controller: couponAssetsCubit.discountValueController,
                                            readOnly: false,
                                            contentPaddingVertical: AppConstants.height15(context),
                                          ),
                                        ],
                                      ),
                                    )
                                   ,]
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                             if(couponAssetsCubit.couponType!= "free_shipping")...[
                               if(couponAssetsCubit.couponType!= "fixed_amount"&&couponAssetsCubit.couponType!="fixed_split")...[CustomCouponField(
                                title: "s_maximum_discount".tr(),
                                hint: "s_maximum_discount".tr(),
                                controller: couponAssetsCubit.maxDiscountAmountController,
                                keyboardType: TextInputType.text,
                                validationText: "s_please_enter_the_maximum_discount".tr(),
                              ),
                              SizedBox(height: AppConstants.height15(context)),],
                              CustomCouponField(
                                title: "s_minimum_order_value".tr(),
                                hint: "s_minimum_order_value".tr(),
                                controller: couponAssetsCubit.minOrderAmountController,
                                keyboardType: TextInputType.number,
                                validationText: "s_please_enter_the_minimum_order_value".tr(),
                              ),
                              SizedBox(height: AppConstants.height15(context)),],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: CustomCouponField(
                                      title: "s_start_date".tr(),
                                      hint: "s_start_date".tr(),
                                      readOnly: true,
                                      controller: couponAssetsCubit.startDateController,
                                      keyboardType: TextInputType.number,
                                      validationText: "s_this_field_is_required".tr(),
                                      onTap: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: couponAssetsCubit.selectedStartDate ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(3000),
                                        );
                                        if (picked != null) {
                                          showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                                            if (time != null) {
                                              couponAssetsCubit.selectedStartDate = picked;
                                              couponAssetsCubit.startDateController.text =
                                              "${DateFormat("yyyy-MM-dd", "en").format(picked)}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00.000Z";
                                            }
                                          });
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.width20(context)),
                                  Expanded(
                                    child: CustomCouponField(
                                      title: "s_end_date".tr(),
                                      hint: "s_end_date".tr(),
                                      readOnly: true,
                                      controller: couponAssetsCubit.endDateController,
                                      keyboardType: TextInputType.number,
                                      validationText: "s_this_field_is_required".tr(),
                                      onTap: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: couponAssetsCubit.selectedEndDate ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(3000),
                                        );
                                        if (picked != null) {
                                          showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                                            if (time != null) {
                                              couponAssetsCubit.selectedEndDate = picked;
                                              couponAssetsCubit.endDateController.text =
                                              "${DateFormat("yyyy-MM-dd", "en").format(picked)}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00.000Z";
                                            }
                                          });
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "s_total_uses".tr(),
                                hint: "s_total_uses".tr(),
                                controller: couponAssetsCubit.usageLimitController,
                                keyboardType: TextInputType.number,
                                validationText: "s_please_enter_the_total_uses".tr(),
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "s_uses_per_user".tr(),
                                hint: "s_uses_per_user".tr(),
                                controller: couponAssetsCubit.usageLimitPerUserController,
                                onChange: (value){
                                 setState(() {
                                   if(couponAssetsCubit.discountValueController.text!=null&&couponAssetsCubit.discountValueController.text.isNotEmpty)
                                   {
                                     final discount =
                                         double.tryParse(couponAssetsCubit.discountValueController.text.trim()) ?? 0;

                                     final usageLimit =
                                         double.tryParse(couponAssetsCubit.usageLimitPerUserController.text.trim()) ?? 0;

                                     if (usageLimit == 0) {
                                       couponAssetsCubit.splitValueController.text = "0";
                                     } else {
                                       couponAssetsCubit.splitValueController.text =
                                           (discount / usageLimit).toString();
                                     }
                                   }
                                 });
                                },
                                keyboardType: TextInputType.number,
                                validationText: "s_please_enter_the_uses_per_user".tr(),
                              ),
                             if(couponAssetsCubit.couponType=="fixed_split")...[ SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "s_discount_per_use".tr(),
                                hint: "s_discount_per_use".tr(),
                                controller: couponAssetsCubit.splitValueController,
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                validationText: "s_please_enter_the_discount_per_use".tr(),
                              ),],
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "s_coupon_description_ar".tr(),
                                hint: "s_coupon_description_ar".tr(),
                                controller: couponAssetsCubit.descriptionArController,
                                keyboardType: TextInputType.text,
                                validationText: "s_please_enter_the_coupon_description".tr(),
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "s_coupon_description_en".tr(),
                                hint: "s_coupon_description_en".tr(),
                                controller: couponAssetsCubit.descriptionEnController,
                                keyboardType: TextInputType.text,
                                validationText: "s_please_enter_the_coupon_description".tr(),
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
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
            child: isEditing
                ? BlocProvider(
                    create: (context) => EditCouponCubit(getIt<CouponsRepoImpl>()),
                    child: BlocConsumer<EditCouponCubit, EditCouponStates>(
                      listener: (context, state) {
                        if (state is EditCouponSuccessState) {
                          toast(text: state.message, color: DsColor.success);
                          couponAssetsCubit.clearAllData();
                          context.read<GetCouponsCubit>().getCoupons();
                          NavigationUtils.navigateBack(context: context);
                        } else if (state is EditCouponErrorState) {
                          toast(text: state.error, color: AppColors.redColor);
                        }
                      },
                      builder: (context, state) {
                        return state is EditCouponLoadingState
                            ? const CustomLoadingItem()
                            : DefaultButton(
                                onPress: () {
                                  if (couponAssetsCubit.createCouponFormKey.currentState!.validate()) {
                                    context.read<EditCouponCubit>().updateCoupon(
                                      couponId: widget.editingCoupon!.id!,
                                      data: _buildCouponPayload(),
                                    );
                                  }
                                },
                                text: "s_save_changes".tr(),
                                borderRadius: AppConstants.sp10(context),
                                height: AppConstants.height15(context),
                              );
                      },
                    ),
                  )
                : BlocProvider(
                    create: (context) => CreateCouponCubit(getIt<CouponsRepoImpl>()),
                    child: BlocConsumer<CreateCouponCubit, CreateCouponStates>(
                      listener: (context, state) {
                        if (state is CreateCouponSuccessState) {
                          toast(text: state.message, color: DsColor.success);
                          couponAssetsCubit.clearAllData();
                          context.read<GetCouponsCubit>().getCoupons();
                          NavigationUtils.navigateBack(context: context);
                        } else if (state is CreateCouponErrorState) {
                          toast(text: state.error, color: AppColors.redColor);
                        }
                      },
                      builder: (context, state) {
                        return state is CreateCouponLoadingState
                            ? const CustomLoadingItem()
                            : DefaultButton(
                                onPress: () {
                                  if (couponAssetsCubit.createCouponFormKey.currentState!.validate()) {
                                    context.read<CreateCouponCubit>().createCoupon(
                                      data: _buildCouponPayload(),
                                    );
                                  }
                                },
                                text: "s_create_the_coupon".tr(),
                                borderRadius: AppConstants.sp10(context),
                                height: AppConstants.height15(context),
                              );
                      },
                    ),
                  ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}
