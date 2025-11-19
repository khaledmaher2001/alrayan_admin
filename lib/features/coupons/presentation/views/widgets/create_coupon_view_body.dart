import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo_impl.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon/create_coupon_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon/create_coupon_states.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/custom_coupon_field.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_category_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_product_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_users_bottom_sheet.dart';
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
  const CreateCouponViewBody({super.key});

  @override
  State<CreateCouponViewBody> createState() => _CreateCouponViewBodyState();
}

class _CreateCouponViewBodyState extends State<CreateCouponViewBody> {
  late CreateCouponAssetsCubit couponAssetsCubit;

  @override
  void initState() {
    couponAssetsCubit = context.read<CreateCouponAssetsCubit>();
    couponAssetsCubit.clearAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          CustomAppBar(title: "انشاء كوبون خصم", hasBack: true,textColor: Colors.black,),
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
                                      Text("مستخدمين الكوبون", style: Styles.inter14600black(context)),
                                      Text(
                                        "*",
                                        style: Styles.inter14600black(context).copyWith(color: AppColors.redColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
                                  CustomDropDownButton(
                                    hintText: "اختر المستخدمين",
                                    items: ['كل المستخدمين', 'مستخدمين محددين'],
                                    borderRadius: AppConstants.sp10(context),
                                    hasBorder: true,
                                    height: MediaQuery.of(context).size.height * .06,
                                    onChanged: (v) {
                                      switch (v) {
                                        case 'كل المستخدمين':
                                          couponAssetsCubit.selectUsersType(type: "all");
                                          break;
                                        case 'مستخدمين محددين':
                                          couponAssetsCubit.selectUsersType(type: "specific_users");
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
                              if (context.read<CreateCouponAssetsCubit>().usersType == "specific_users")
                                Column(
                                  children: [
                                    SizedBox(height: AppConstants.height15(context)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "المستخدمين التي تم اختيارها",
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
                                                  Text("اضافة المستخدمين", style: Styles.inter14600gray(context)),
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
                                                          Colors.primaries[index % Colors.primaries.length],
                                                      // لون عشوائي لكل يوزر
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
                                                              .fullName!,
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
                                      Text("نوع الكوبون", style: Styles.inter14600black(context)),
                                      Text(
                                        "*",
                                        style: Styles.inter14600black(context).copyWith(color: AppColors.redColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
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
                                    height: MediaQuery.of(context).size.height * .06,
                                    onChanged: (v) {
                                      switch (v) {
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
                                        return "من فضلك اختر نوع الكوبون";
                                      }
                                      return null;
                                    },
                                    value: null,
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
                                            "المنتجات التي تم اختيارها",
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
                                                  Text("اضافة المنتجات", style: Styles.inter14600gray(context)),
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
                                            "الاقسام التي تم اختيارها",
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
                                                  Text("اضافة الاقسام", style: Styles.inter14600gray(context)),
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
                                      title: "كود الخصم",
                                      hint: "كود الخصم",
                                      controller: couponAssetsCubit.codeController,
                                      keyboardType: TextInputType.text,
                                      validationText: "من فضلك ادخل كود الخصم",
                                    ),
                                  ),
                                  if(couponAssetsCubit.couponType!= "free_shipping")...[SizedBox(width: AppConstants.width20(context)),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("قيمة الخصم", style: Styles.inter14600black(context)),
                                              Text("*", style: Styles.inter14600black(context).copyWith(color: AppColors.redColor)),
                                            ],
                                          ),
                                          SizedBox(height: AppConstants.height5(context)),
                                          DefaultTextFormField(
                                            onTap: (){},
                                            validation: (String? value) {
                                              if (value == null || value.isEmpty) {
                                                return "من فضلك ادخل قيمة الخصم";
                                              }else if(couponAssetsCubit.couponType== "percentage")
                                                {
                                                  if(int.parse(value)>100)
                                                    {
                                                      return "اقصي قيمة للخصم 100%";
                                                    }
                                                }
                                              return null;
                                            },
                                            style: Styles.inter14600black(context),
                                            fillColor: const Color(0xffF7F7F8),
                                            contentPaddingHorizontal: AppConstants.width15(context),
                                            hintText: "قيمة الخصم",
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
                             if(couponAssetsCubit.couponType!= "free_shipping")...[ CustomCouponField(
                                title: "الحد الاقصي للخصم",
                                hint: "الحد الاقصي للخصم",
                                controller: couponAssetsCubit.maxDiscountAmountController,
                                keyboardType: TextInputType.text,
                                validationText: "من فضلك ادخل الحد الاقصي للخصم",
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "الحد الادني لقيمة الطلب",
                                hint: "الحد الادني لقيمة الطلب",
                                controller: couponAssetsCubit.minOrderAmountController,
                                keyboardType: TextInputType.number,
                                validationText: "من فضلك ادخل الحد الادني لقيمة الطلب",
                              ),
                              SizedBox(height: AppConstants.height15(context)),],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: CustomCouponField(
                                      title: "تاريخ البداية",
                                      hint: "تاريخ البداية",
                                      readOnly: true,
                                      controller: couponAssetsCubit.startDateController,
                                      keyboardType: TextInputType.number,
                                      validationText: "يجب ادخال هذا الحقل",
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
                                                  "${DateFormat("yyyy-MM-dd", "en").format(picked)}T${time.hour}:${time.minute}:00.000";
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
                                      title: "تاريخ الانتهاء",
                                      hint: "تاريخ الانتهاء",
                                      readOnly: true,
                                      controller: couponAssetsCubit.endDateController,
                                      keyboardType: TextInputType.number,
                                      validationText: "يجب ادخال هذا الحقل",
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
                                                  "${DateFormat("yyyy-MM-dd", "en").format(picked)}T${time.hour}:${time.minute}:00.000";
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
                                title: "مرات الاستخدام الكلية",
                                hint: "مرات الاستخدام الكلية",
                                controller: couponAssetsCubit.usageLimitController,
                                keyboardType: TextInputType.number,
                                validationText: "من فضلك ادخل مرات الاستخدام الكلية",
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "مرات الاستخدام للمستخدم الواحد",
                                hint: "مرات الاستخدام للمستخدم الواحد",
                                controller: couponAssetsCubit.usageLimitPerUserController,
                                keyboardType: TextInputType.number,
                                validationText: "من فضلك ادخل مرات الاستخدام للمستخدم الواحد",
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "وصف الكوبون (AR) ",
                                hint: "وصف الكوبون (AR) ",
                                controller: couponAssetsCubit.descriptionArController,
                                keyboardType: TextInputType.text,
                                validationText: "من فضلك ادخل وصف الكوبون",
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              CustomCouponField(
                                title: "وصف الكوبون (EN) ",
                                hint: "وصف الكوبون (EN) ",
                                controller: couponAssetsCubit.descriptionEnController,
                                keyboardType: TextInputType.text,
                                validationText: "من فضلك ادخل وصف الكوبون",
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
            child: BlocProvider(
              create: (context) => CreateCouponCubit(getIt<CouponsRepoImpl>()),
              child: BlocConsumer<CreateCouponCubit, CreateCouponStates>(
                listener: (context, state) {
                  if (state is CreateCouponSuccessState) {
                    toast(text: state.message, color: Colors.green);
                    couponAssetsCubit.clearAllData();
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
                                data: {
                                  "code": couponAssetsCubit.codeController.text.trim(),
                                  "description": {
                                    "en": couponAssetsCubit.descriptionEnController.text.trim(),
                                    "ar": couponAssetsCubit.descriptionArController.text.trim(),
                                  },
                                  "discountType": couponAssetsCubit.couponType,
                                  "discountValue": couponAssetsCubit.couponType=="free_shipping"?"100":couponAssetsCubit.discountValueController.text.trim(),
                                  if(couponAssetsCubit.couponType!="free_shipping")
                                  "maxDiscountAmount":couponAssetsCubit.maxDiscountAmountController.text.trim(),
                                  if(couponAssetsCubit.couponType!="free_shipping")
                                  "minOrderAmount": couponAssetsCubit.minOrderAmountController.text.trim(),
                                  "status": "active",
                                  "validFrom":couponAssetsCubit.startDateController.text.trim(),
                                  "validTo":couponAssetsCubit.endDateController.text.trim(),
                                  "usageLimit": couponAssetsCubit.usageLimitController.text.trim(),
                                  "usageLimitPerUser": couponAssetsCubit.usageLimitPerUserController.text.trim(),
                                  "applicableCategories": couponAssetsCubit.selectedCategories.map((e)=>e.id).toList(),
                                  "applicableProducts": couponAssetsCubit.selectedProducts.map((e)=>e.id).toList(),
                                  "applicableUserGroups": couponAssetsCubit.selectedUsers.map((e)=>e.id).toList(),
                                  "isStackable": false,
                                  "splitValue": 0,
                                },
                              );
                            }
                          },
                          text: "انشاء الكوبون",
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
