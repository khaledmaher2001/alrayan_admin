import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/ads_view.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/coupons_view.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/create_coupon_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/lucky_wheel_view.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view/change_password_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/features/version_settings/presentation/views/version_settings_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/add_zone_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/zones_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/local_services/cache_helper.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import 'account_item.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            SizedBox(height: AppConstants.height10(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
              child: BlocBuilder<GetProfileCubit, GetProfileStates>(
                builder: (context, state) {
                  if (state is GetProfileSuccessState) {
                    final profile = state.model;

                    return Row(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width*.15,
                            height: MediaQuery.of(context).size.width*.15,
                            decoration: BoxDecoration(
                                color: Color(0xff1e1d2f),
                                shape: BoxShape.circle
                            ),child: Padding(
                          padding: EdgeInsets.all(AppConstants.sp10(context)),
                          child: Image.asset(AssetData.logoBackSecondry,fit: BoxFit.contain,),
                        )),

                        SizedBox(width: AppConstants.width10(context)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.data!.fullName ?? "",
                              style: Styles.inter18500Black(context).copyWith(color: Colors.black),
                            ),
                            Text(
                              profile.data!.email ?? "",
                              style: Styles.inter14500black(context).copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    );

                  }  else {
                    return Skeletonizer(
                      enabled: true,
                      child: Row(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width*.15,
                              height: MediaQuery.of(context).size.width*.15,
                              decoration: BoxDecoration(
                                  color: Color(0xff1e1d2f),
                                  shape: BoxShape.circle
                              ),child: Padding(
                            padding: EdgeInsets.all(AppConstants.sp10(context)),
                            child: Image.asset(AssetData.logoBackSecondry,fit: BoxFit.contain,),
                          )),
                          SizedBox(width: AppConstants.width10(context)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("", style: Styles.inter18500Black(context).copyWith(color: Colors.white)),
                              Text("", style: Styles.inter14500black(context).copyWith(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.height20(context)),

        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen:  ZonesView(),
                        );
                      },
                      title: "مناطق التوصيل",
                      icon: AssetData.accountAddresses,
                    ),
                    SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(2);
                      },
                      title: "orders".tr(),
                      icon: AssetData.orders,
                    ),
                    SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const CouponsView(),
                        );
                      },
                      title: "my_coupons".tr(),
                      icon: AssetData.accountCoupons,
                    ),
                    SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const LuckyWheelView(),
                        );
                      },
                      title: "عجلة الحظ".tr(),
                      icon: AssetData.wheel,
                    ),SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const VersionSettingsView(),
                        );
                      },
                      title: "اعدادات النسخة الحالية".tr(),
                      icon: AssetData.version,
                    ),SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const LuckyWheelView(),
                        );
                      },
                      title: "طلبات الدعم الفني".tr(),
                      icon: AssetData.support,
                    ),SizedBox(height: AppConstants.height20(context)),
                    AccountItem(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const AdsView(),
                        );
                      },
                      title: "ادارة الاعلانات".tr(),
                      icon: AssetData.ads,
                    ),
                    SizedBox(height: AppConstants.height20(context)),
                    Text("الحماية", style: Styles.inter12400Primary(context)),
                    SizedBox(height: AppConstants.height10(context)),
                    AccountItem(
                      onTap: () {
                    NavigationUtils.navigateTo(context: context, destinationScreen: ChangePasswordView());
                      },
                      title: "change_password".tr(),
                      icon: AssetData.accountPassword,
                    ),

                    SizedBox(height: AppConstants.height20(context)),

                    DefaultButton(
                      onPress: () async {
                        await CacheHelper.removeData(key: "token");
                        await CacheHelper.removeData(key: "guestUser");
                        GoRouter.of(context).go("/loginView");
                      },
                      text: "logout".tr(),
                      borderRadius: AppConstants.sp30(context) * 3,
                      height: AppConstants.height15(context),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      hasBorder: true,
                      textColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
