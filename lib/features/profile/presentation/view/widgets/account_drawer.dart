import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/ads_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_state.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/coupons_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_management_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/lucky_wheel_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/change_password_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/features/system_settings/presentation/views/system_settings_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/zones_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

/// Everything that used to live behind the "الحساب" bottom-nav tab, now
/// reachable as a side drawer from the home page instead — the tab was
/// dropped so the bottom nav focuses on the four things admins hit every
/// day (home/orders/products/categories), and account-level management
/// moved here.
///
/// Navy profile header + a thin red accent line under it; white body.
/// The item you're on/just tapped gets a light red-tinted fill with a red
/// accent stripe on its leading edge and red text — "تسجيل الخروج" reuses
/// that exact same treatment permanently, since it's styled as "another
/// list row" rather than a standalone button. Deliberately no drawer
/// corner radius (`Drawer.shape`) — square edges only.
///
/// Ordering within "إعدادات التشغيل" is deliberately priority-sorted by how
/// often an admin actually opens each one: إدارة الدليفري (a whole daily
/// sub-system — couriers, orders, wallets) first, مناطق التوصيل next
/// (occasional edits), اعدادات النظام last (rarely-touched configuration).
class AccountDrawer extends StatefulWidget {
  const AccountDrawer({super.key});

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

enum _DrawerSection {
  home,
  delivery,
  zones,
  systemSettings,
  coupons,
  ads,
  wheel,
  password,
}

class _AccountDrawerState extends State<AccountDrawer> {
  _DrawerSection _selected = _DrawerSection.home;

  void _select(_DrawerSection section, VoidCallback action) {
    setState(() => _selected = section);
    action();
  }

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
                  child: Icon(
                    Icons.logout,
                    color: AppColors.redColor,
                    size: MediaQuery.of(context).size.width * .08,
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
    return Drawer(
      width: MediaQuery.of(context).size.width * .82,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.secondaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.height15(context),
                ),
                child: BlocBuilder<GetProfileCubit, GetProfileStates>(
                  builder: (context, state) {
                    final profile = state is GetProfileSuccessState
                        ? state.model.data
                        : null;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .15,
                                height: MediaQuery.of(context).size.width * .15,
                                padding: EdgeInsets.all(
                                  AppConstants.width5(context),
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  AssetData.logo,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              SizedBox(width: AppConstants.width10(context)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.fullName ?? "...",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.inter18500Black(
                                        context,
                                      ).copyWith(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: AppConstants.height5(context) / 2,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppConstants.width10(
                                          context,
                                        ),
                                        vertical:
                                            AppConstants.height5(context) / 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.sp30(context),
                                        ),
                                      ),
                                      child: Text(
                                        "s_store_manager".tr(),
                                        style: Styles.inter10400grey(context)
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppConstants.height5(context) / 2,
                                    ),
                                    Text(
                                      profile?.email ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.inter12500Black(
                                        context,
                                      ).copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppConstants.sp30(context),
                            ),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: EdgeInsets.all(AppConstants.sp5(context)),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: AppConstants.sp20(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(height: 3, color: AppColors.primaryColor),

          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width15(context),
                        vertical: AppConstants.height10(context),
                      ),
                      children: [
                        _DrawerItem(
                          icon: Icons.home_outlined,
                          label: "home".tr(),
                          selected: _selected == _DrawerSection.home,
                          onTap: () => _select(
                            _DrawerSection.home,
                            () => Navigator.of(context).pop(),
                          ),
                        ),
                        _DrawerItem(
                          icon: Icons.moped_outlined,
                          label: "delivery_management".tr(),
                          selected: _selected == _DrawerSection.delivery,
                          onTap: () => _select(
                            _DrawerSection.delivery,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: const DeliveryManagementView(),
                            ),
                          ),
                        ),
                        _DrawerItem(
                          icon: Icons.location_on_outlined,
                          label: "s_delivery_zones".tr(),
                          selected: _selected == _DrawerSection.zones,
                          onTap: () => _select(
                            _DrawerSection.zones,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: ZonesView(),
                            ),
                          ),
                        ),
                        _DrawerItem(
                          icon: Icons.settings_outlined,
                          label: "s_system_settings".tr(),
                          selected: _selected == _DrawerSection.systemSettings,
                          onTap: () => _select(
                            _DrawerSection.systemSettings,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: const SystemSettingsView(),
                            ),
                          ),
                        ),

                        _DrawerDivider(),
                        _DrawerSectionLabel("s_marketing_offers".tr()),
                        _DrawerItem(
                          icon: Icons.confirmation_number_outlined,
                          label: "my_coupons".tr(),
                          selected: _selected == _DrawerSection.coupons,
                          onTap: () => _select(
                            _DrawerSection.coupons,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: const CouponsView(),
                            ),
                          ),
                        ),
                        _DrawerItem(
                          icon: Icons.campaign_outlined,
                          label: "s_ads_management".tr(),
                          selected: _selected == _DrawerSection.ads,
                          onTap: () => _select(
                            _DrawerSection.ads,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: const AdsView(),
                            ),
                          ),
                        ),
                        _DrawerItem(
                          icon: Icons.casino_outlined,
                          label: "s_lucky_wheel".tr(),
                          selected: _selected == _DrawerSection.wheel,
                          onTap: () => _select(
                            _DrawerSection.wheel,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: const LuckyWheelView(),
                            ),
                          ),
                        ),

                        _DrawerDivider(),
                        _DrawerSectionLabel("s_security".tr()),
                        _DrawerItem(
                          icon: Icons.lock_outline,
                          label: "change_password".tr(),
                          selected: _selected == _DrawerSection.password,
                          onTap: () => _select(
                            _DrawerSection.password,
                            () => NavigationUtils.navigateTo(
                              context: context,
                              destinationScreen: ChangePasswordView(),
                            ),
                          ),
                        ),

                        _DrawerDivider(),
                        _LogoutDrawerItem(onTap: () => _confirmLogout(context)),
                      ],
                    ),
                  ),
                  const _AppVersionFooter(),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One icon+label row. Unselected: dark text on white. Selected (the
/// section you're currently on, or just tapped): light red-tinted fill +
/// a red accent stripe on the leading edge + red text — the stripe's
/// width is always reserved so labels don't shift between the two states.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tint = DsColor.text2;
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height5(context)),
      child: Material(
        color:  DsColor.border,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          splashColor: AppColors.primaryColor.withOpacity(.08),
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppConstants.height10(context),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: tint,
                          size: AppConstants.sp20(context),
                        ),
                        SizedBox(width: AppConstants.width15(context)),
                        Expanded(
                          child: Text(
                            label,
                            style: Styles.inter16500black(
                              context,
                            ).copyWith(color: tint),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Icon(
                  Icons.arrow_forward_ios,
                  color:DsColor.textMuted,
                  size: AppConstants.sp15(context),
                ),
                SizedBox(width: AppConstants.width10(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Same row layout as [_DrawerItem]'s selected state — permanently, since
/// logout isn't a "you are here" destination — with its icon swapped for
/// a spinner while `LogoutCubit` is working.
class _LogoutDrawerItem extends StatelessWidget {
  const _LogoutDrawerItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          GoRouter.of(context).go("/loginView");
        } else if (state is LogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: DsColor.danger),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LogoutLoading;
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.height5(context)),
          child: Material(
            color: AppColors.primaryColor.withOpacity(.08),
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              onTap: isLoading ? null : onTap,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      margin: EdgeInsetsDirectional.only(
                        end: AppConstants.width15(context) - 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.redColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppConstants.height10(context),
                        ),
                        child: Row(
                          children: [
                            isLoading
                                ? SizedBox(
                                    width: AppConstants.sp20(context),
                                    height: AppConstants.sp20(context),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.redColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.logout,
                                    color: AppColors.redColor,
                                    size: AppConstants.sp20(context),
                                  ),
                            SizedBox(width: AppConstants.width15(context)),
                            Expanded(
                              child: Text(
                                "logout".tr(),
                                style: Styles.inter16500black(
                                  context,
                                ).copyWith(color: AppColors.redColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height5(context),
      ),
      child: Text(
        text,
        style: Styles.inter10400grey(context).copyWith(
          color: DsColor.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
      child: Divider(color: DsColor.border, height: 1),
    );
  }
}

/// "الإصدار x.x.x" centered at the very bottom, read from the installed
/// build itself (not a server value) via `package_info_plus`.
class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppConstants.height5(context),
          ),
          child: Center(
            child: Text(
              "i_version_x_85".tr(namedArgs: {"a": "${version}"}),
              style: Styles.inter10400grey(
                context,
              ).copyWith(color: DsColor.textSubtle),
            ),
          ),
        );
      },
    );
  }
}
