import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/delivery_settings/presentation/views/delivery_settings_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/low_stock_settings_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/market_status_toggle.dart';
import 'package:alrayan_admin/features/loyalty_settings/presentation/views/loyalty_settings_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/widgets/maintenance_mode_toggle.dart';
import 'package:alrayan_admin/features/version_settings/presentation/views/version_settings_view.dart';
import 'package:flutter/material.dart';

/// Store-wide settings: live switches first (what customers feel right now),
/// then the configuration pages, as two grouped lists.
class SystemSettingsView extends StatelessWidget {
  const SystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    void go(Widget w) => NavigationUtils.navigateTo(context: context, destinationScreen: w);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DsTopBar(title: "s_system_settings".tr()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(DsSpace.page, 0, DsSpace.page, DsSpace.xxxl),
                children: [
                  DsSectionHeader(title: "ds_live_status".tr()),
                  const DsGroup(children: [MarketStatusToggle(), MaintenanceModeToggle()]),
                  DsSectionHeader(title: "ds_configuration".tr()),
                  DsGroup(
                    children: [
                      DsRow(
                        icon: Icons.loyalty_outlined,
                        title: "s_loyalty_points_settings".tr(),
                        subtitle: "s_control_the_points_earning_rate_and_".tr(),
                        onTap: () => go(const LoyaltySettingsView()),
                      ),
                      DsRow(
                        icon: Icons.local_shipping_outlined,
                        title: "s_delivery_settings".tr(),
                        subtitle: "s_turn_delivery_on_or_off_and_set_the_".tr(),
                        onTap: () => go(const DeliverySettingsView()),
                      ),
                      DsRow(
                        icon: Icons.inventory_outlined,
                        title: "s_low_stock_settings".tr(),
                        subtitle: "s_set_the_stock_level_at_which_a_produ".tr(),
                        onTap: () => go(const LowStockSettingsView()),
                      ),
                      DsRow(
                        icon: Icons.system_update_outlined,
                        title: "s_current_version_settings".tr(),
                        subtitle: "s_control_the_app_version_and_force_us".tr(),
                        onTap: () => go(const VersionSettingsView()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
