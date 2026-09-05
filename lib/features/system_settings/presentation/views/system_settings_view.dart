import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery_settings/presentation/views/delivery_settings_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/low_stock_settings_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/market_status_toggle.dart';
import 'package:alrayan_admin/features/loyalty_settings/presentation/views/loyalty_settings_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view/widgets/maintenance_mode_toggle.dart';
import 'package:alrayan_admin/features/version_settings/presentation/views/version_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Hub screen collecting every store-wide setting in one place: open/close
/// status, maintenance mode, loyalty points, and delivery — previously
/// scattered across the profile menu and the delivery management hub.
class SystemSettingsView extends StatelessWidget {
  const SystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppConstants.height10(context)),
            CustomAppBar(
              title: "اعدادات النظام",
              textColor: Colors.black,
              hasBack: true,
              withNotifications: false,
            ),
            SizedBox(height: AppConstants.height20(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context),
                ),
                children: [
                  const MarketStatusToggle(),
                  SizedBox(height: AppConstants.height15(context)),
                  const MaintenanceModeToggle(),
                  SizedBox(height: AppConstants.height15(context)),
                  _SettingsMenuCard(
                    icon: AssetData.loyaltyPoints,
                    title: "اعدادات نقاط الولاء",
                    subtitle: "التحكم في نسبة اكتساب النقاط وقيمة استبدالها",
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const LoyaltySettingsView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _SettingsMenuCard(
                    icon: AssetData.delivery,
                    title: "اعدادات الدليفري",
                    subtitle: "تفعيل أو إيقاف الدليفري وتحديد أقصى عدد طلبات للمندوب",
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const DeliverySettingsView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _SettingsMenuCard(
                    icon: AssetData.version,
                    title: "اعدادات النسخة الحالية",
                    subtitle: "التحكم في إصدار التطبيق وإجبار المستخدمين على التحديث",
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const VersionSettingsView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _SettingsMenuCard(
                    icon: AssetData.settings,
                    title: "اعدادات المخزون المنخفض",
                    subtitle: "تحديد حد المخزون الذي يعتبر عنده المنتج منخفض المخزون",
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const LowStockSettingsView(),
                    ),
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

class _SettingsMenuCard extends StatelessWidget {
  const _SettingsMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp15(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .15,
              height: MediaQuery.of(context).size.width * .15,
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(.08),
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: SvgPicture.asset(
                icon,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Styles.inter16500black(context)),
                  SizedBox(height: AppConstants.height5(context) / 2),
                  Text(
                    subtitle,
                    style: Styles.inter12500Black(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: AppConstants.sp30(context),
            ),
          ],
        ),
      ),
    );
  }
}
