import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/ads_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_state.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/coupons_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_management_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/lucky_wheel_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/change_password_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/widgets/grouped_settings_card.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/features/system_settings/presentation/views/system_settings_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/zones_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DsColor.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AssetData.logout,
                    width: MediaQuery.of(context).size.width * .08,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "s_log_out".tr(),
                    textAlign: TextAlign.center,
                    style: Styles.inter16500black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "s_are_you_sure_you_want_to_log_out".tr(),
              style: Styles.inter14500black(
                context,
              ).copyWith(color: DsColor.text2),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DsColor.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<LogoutCubit>().logout();
                    },
                    child: Text(
                      "s_log_out".tr(),
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "s_cancel".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppConstants.height10(context)),
        Text("s_account".tr(), style: Styles.inter18500Black(context)),
        SizedBox(height: AppConstants.height15(context)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: BlocBuilder<GetProfileCubit, GetProfileStates>(
            builder: (context, state) {
              final profile = state is GetProfileSuccessState ? state.model.data : null;
              return Skeletonizer(
                enabled: profile == null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppConstants.sp15(context)),
                  decoration: BoxDecoration(
                    color: const Color(0xff1e1d2f),
                    borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? "",
                              style: Styles.inter18500Black(
                                context,
                              ).copyWith(color: Colors.white),
                            ),
                            SizedBox(height: AppConstants.height5(context)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.width10(context),
                                vertical: AppConstants.height5(context) / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                              ),
                              child: Text(
                                "s_store_manager".tr(),
                                style: Styles.inter12500Black(
                                  context,
                                ).copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: AppConstants.height5(context)),
                            Text(
                              profile?.email ?? "",
                              style: Styles.inter14500black(
                                context,
                              ).copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Container(
                        width: MediaQuery.of(context).size.width * .15,
                        height: MediaQuery.of(context).size.width * .15,
                        decoration: const BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.sp10(context)),
                          child: Image.asset(
                            AssetData.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppConstants.height20(context)),

        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  context.read<GetProfileCubit>().getProfile(),
                  context.read<GetSettingsCubit>().getSettings(),
                ]);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text("s_operations_settings".tr(), style: Styles.inter12400Primary(context)),
                  SizedBox(height: AppConstants.height10(context)),
                  GroupedSettingsCard(
                    children: [
                      GroupedSettingsItem(
                        icon: AssetData.update,
                        title: "s_system_settings".tr(),
                        subtitle: "s_store_and_app_settings".tr(),
                        onTap: () => NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const SystemSettingsView(),
                        ),
                      ),
                      GroupedSettingsItem(
                        icon: AssetData.accountAddresses,
                        title: "s_delivery_zones".tr(),
                        subtitle: "s_manage_areas_and_delivery_fees".tr(),
                        onTap: () => NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: ZonesView(),
                        ),
                      ),
                      GroupedSettingsItem(
                        icon: AssetData.delivery,
                        title: "delivery_management".tr(),
                        subtitle: "s_couriers_and_delivery_status".tr(),
                        onTap: () => NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: const DeliveryManagementView(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),

                  Text("s_marketing_offers".tr(), style: Styles.inter12400Primary(context)),
                  SizedBox(height: AppConstants.height10(context)),
                  Row(
                    children: [
                      Expanded(
                        child: MarketingActionCard(
                          icon: AssetData.ads,
                          title: "s_ads_management".tr(),
                          onTap: () => NavigationUtils.navigateTo(
                            context: context,
                            destinationScreen: const AdsView(),
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Expanded(
                        child: MarketingActionCard(
                          icon: AssetData.wheel,
                          title: "s_lucky_wheel".tr(),
                          onTap: () => NavigationUtils.navigateTo(
                            context: context,
                            destinationScreen: const LuckyWheelView(),
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Expanded(
                        child: MarketingActionCard(
                          icon: AssetData.accountCoupons,
                          title: "my_coupons".tr(),
                          onTap: () => NavigationUtils.navigateTo(
                            context: context,
                            destinationScreen: const CouponsView(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),

                  Text("s_security".tr(), style: Styles.inter12400Primary(context)),
                  SizedBox(height: AppConstants.height10(context)),
                  GroupedSettingsCard(
                    children: [
                      GroupedSettingsItem(
                        icon: AssetData.accountPassword,
                        title: "change_password".tr(),
                        subtitle: "s_update_your_password".tr(),
                        onTap: () => NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: ChangePasswordView(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.height20(context)),

        BlocConsumer<LogoutCubit, LogoutState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              GoRouter.of(context).go("/loginView");
            } else if (state is LogoutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: DsColor.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LogoutLoading;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: DefaultButton(
                onPress: isLoading ? () {} : () => _confirmLogout(context),
                text: isLoading ? "" : "logout".tr(),
                borderRadius: AppConstants.sp30(context) * 3,
                height: AppConstants.height15(context),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                hasBorder: true,
                textColor: AppColors.primaryColor,
                icon: isLoading
                    ? SizedBox(
                        height: AppConstants.sp20(context),
                        width: AppConstants.sp20(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
        SizedBox(height: AppConstants.height20(context)),
      ],
    );
  }
}
