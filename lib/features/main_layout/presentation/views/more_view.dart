import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/ads/presentation/views/ads_view.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/all_users_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/logout/logout_state.dart';
import 'package:alrayan_admin/features/auth/presentation/view/widgets/auth_ui.dart' show rebuildWholeApp;
import 'package:alrayan_admin/features/categories/presentation/view/categories_view.dart';
import 'package:alrayan_admin/features/complaints/presentation/admin_complaints_view.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/coupons_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_management_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/inventory_analytics_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/low_stock_products_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/lucky_wheel_view.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/notifications_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/change_password_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/features/reviews/presentation/view/reviews_view.dart';
import 'package:alrayan_admin/features/scheduled_notifications/presentation/views/scheduled_notifications_view.dart';
import 'package:alrayan_admin/features/system_settings/presentation/views/system_settings_view.dart';
import 'package:alrayan_admin/features/top_products/presentation/views/top_products_view.dart';
import 'package:alrayan_admin/features/top_users/presentation/views/top_users_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/zones_view.dart';

/// "المزيد": every admin area in one place, grouped like the web dashboard.
/// Replaces the side drawer and the scattered shortcuts on the home page.
/// A section is shown only when the signed-in employee has its permission
/// (full administrators see everything).
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  static List<_Section> _sections() => [
        _Section('more_sec_sales', 'customers', [
          _Item('more_complaints', Icons.forum_outlined, () => const AdminComplaintsView()),
          _Item('more_customers', Icons.people_alt_outlined, () => const AllUsersView()),
          _Item('more_top_customers', Icons.emoji_events_outlined, () => const TopUsersView(), permission: 'reports'),
          _Item('more_reviews', Icons.star_outline_rounded, () => const ReviewsView()),
        ]),
        _Section('more_sec_catalog', 'products', [
          _Item('more_categories', Icons.category_outlined, () => const CategoriesView(asPage: true)),
          _Item('more_top_products', Icons.trending_up_rounded, () => const TopProductsView(), permission: 'reports'),
          _Item('more_inventory', Icons.inventory_2_outlined, () => const InventoryAnalyticsView()),
          _Item('more_low_stock', Icons.warning_amber_rounded, () => const LowStockProductsView()),
        ]),
        _Section('more_sec_marketing', 'marketing', [
          _Item('more_coupons', Icons.local_offer_outlined, () => const CouponsView()),
          _Item('more_ads', Icons.campaign_outlined, () => const AdsView()),
          _Item('more_wheel', Icons.casino_outlined, () => const LuckyWheelView()),
          _Item('more_push_notifications', Icons.campaign_rounded, () => const ScheduledNotificationsView(), permission: 'notifications.view'),
        ]),
        _Section('more_sec_delivery', 'delivery', [
          _Item('more_couriers', Icons.delivery_dining_outlined, () => const DeliveryManagementView()),
          _Item('more_remittances', Icons.payments_outlined, () => const RemittancesView()),
        ]),
        _Section('more_sec_settings', 'settings', [
          _Item('more_zones', Icons.map_outlined, () => ZonesView()),
          _Item('more_settings', Icons.settings_outlined, () => const SystemSettingsView()),
        ]),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<GetProfileCubit, GetProfileStates>(
          builder: (context, state) {
            final profile = state is GetProfileSuccessState ? state.model.data : null;
            // Until the profile loads, show nothing restricted.
            bool can(String p) => profile != null && profile.can(p);
            final sections = [
              for (final s in _sections())
                if (can(s.permission))
                  _Section(s.titleKey, s.permission, [
                    for (final i in s.items)
                      if (i.permission == null || can(i.permission!)) i,
                  ]),
            ];
            return ListView(
              padding: EdgeInsets.fromLTRB(
                AppConstants.width20(context),
                AppConstants.height15(context),
                AppConstants.width20(context),
                AppConstants.height30(context),
              ),
              children: [
                Text('more_title'.tr(), style: Styles.inter18500Black(context).copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: AppConstants.height15(context)),
                _ProfileCard(
                  name: profile?.fullName,
                  email: profile?.email ?? profile?.phoneNumber,
                  fullAdmin: profile?.isFullAdmin ?? true,
                ),
                for (final s in sections) ...[
                  _SectionTitle(s.titleKey.tr()),
                  _Group(children: [
                    for (final i in s.items)
                      _Tile(
                        icon: i.icon,
                        title: i.titleKey.tr(),
                        onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: i.builder()),
                      ),
                  ]),
                ],
                _SectionTitle('more_sec_account'.tr()),
                _Group(children: [
                  _Tile(
                    icon: Icons.notifications_none_rounded,
                    title: 'more_notifications'.tr(),
                    onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: const NotificationsView()),
                  ),
                  _Tile(
                    icon: Icons.language_rounded,
                    title: 'more_language'.tr(),
                    trailing: context.locale.languageCode == 'ar' ? "s_arabic".tr() : 'English',
                    onTap: () => _pickLanguage(context),
                  ),
                  _Tile(
                    icon: Icons.lock_outline_rounded,
                    title: 'more_password'.tr(),
                    onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: const ChangePasswordView()),
                  ),
                ]),
                SizedBox(height: AppConstants.height15(context)),
                const _LogoutTile(),
                const _Version(),
              ],
            );
          },
        ),
      ),
    );
  }

  static Future<void> _pickLanguage(BuildContext context) async {
    final current = context.locale.languageCode;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.width20(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('more_language'.tr(), style: Styles.inter16500black(context)),
              SizedBox(height: AppConstants.height15(context)),
              for (final (code, name) in [('ar', "s_arabic".tr()), ('en', 'English')])
                ListTile(
                  minTileHeight: 56,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: code == current ? AppColors.primaryColor.withValues(alpha: .08) : null,
                  title: Text(name, style: Styles.inter14600black(context)),
                  trailing: code == current ? Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
                  onTap: () => Navigator.of(sheet).pop(code),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || picked == current || !context.mounted) return;
    await CacheHelper.saveData(key: 'language', value: picked);
    if (context.mounted) await context.setLocale(Locale(picked));
    rebuildWholeApp();
  }
}

class _Section {
  const _Section(this.titleKey, this.permission, this.items);
  final String titleKey;
  final String permission;
  final List<_Item> items;
}

class _Item {
  const _Item(this.titleKey, this.icon, this.builder, {this.permission});
  final String titleKey;
  final IconData icon;
  final Widget Function() builder;

  /// Extra permission the server checks for this screen (e.g. reports for rankings).
  final String? permission;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({this.name, this.email, required this.fullAdmin});
  final String? name;
  final String? email;
  final bool fullAdmin;

  @override
  Widget build(BuildContext context) {
    final initial = (name ?? '').trim().isEmpty ? '؟' : name!.trim().characters.first;
    // Identity card: white surface like every other card; brand only in the avatar tint.
    return DsCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: DsColor.primarySoft,
            child: Text(initial, style: DsText.heading.copyWith(color: DsColor.onPrimarySoft)),
          ),
          const SizedBox(width: DsSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: DsText.subheading.copyWith(fontWeight: FontWeight.w700)),
                if ((email ?? '').isNotEmpty)
                  Text(email!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: DsText.caption),
                const SizedBox(height: 6),
                DsStatusBadge(
                  status: null,
                  icon: fullAdmin ? Icons.verified_user_outlined : Icons.badge_outlined,
                  label: fullAdmin ? 'more_role_admin'.tr() : 'more_role_staff'.tr(),
                  fg: DsColor.onPrimarySoft,
                  bg: DsColor.primarySoft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: 4,
          top: AppConstants.height20(context),
          bottom: AppConstants.height10(context),
        ),
        child: Text(text, style: DsText.label.copyWith(color: DsColor.text2)),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DsRadius.lg),
          border: Border.all(color: DsColor.border),
        ),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 52, endIndent: DsSpace.lg, color: DsColor.divider),
              children[i],
            ],
          ],
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap, this.trailing});
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, 8, DsSpace.md, 8),
          child: Row(
            children: [
              // Plain muted icon — same as every grouped list (settings, delivery hub).
              Icon(icon, color: DsColor.textMuted, size: DsSize.icon),
              const SizedBox(width: DsSpace.md),
              Expanded(child: Text(title, style: DsText.body.copyWith(fontWeight: FontWeight.w600))),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Text(trailing!, style: DsText.caption),
                ),
              const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  Future<void> _confirm(BuildContext context) async {
    final ok = await dsConfirm(
      context,
      title: 'more_logout'.tr(),
      message: 'more_logout_confirm'.tr(),
      confirmLabel: 'more_logout'.tr(),
      destructive: true,
    );
    if (ok && context.mounted) context.read<LogoutCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          GoRouter.of(context).go('/loginView');
        } else if (state is LogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.redColor));
        }
      },
      builder: (context, state) {
        final loading = state is LogoutLoading;
        return Material(
          color: AppColors.redColor.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
            onTap: loading ? null : () => _confirm(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.redColor))
                      : Icon(Icons.logout_rounded, color: AppColors.redColor),
                  const SizedBox(width: 10),
                  Text('more_logout'.tr(), style: Styles.inter14600black(context).copyWith(color: AppColors.redColor)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Version extends StatelessWidget {
  const _Version();

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) => snap.data == null
            ? const SizedBox(height: 16)
            : Padding(
                padding: EdgeInsets.only(top: AppConstants.height15(context)),
                child: Center(
                  child: Text('more_version'.tr(namedArgs: {'v': snap.data!.version}),
                      style: Styles.inter10400grey(context)),
                ),
              ),
      );
}
