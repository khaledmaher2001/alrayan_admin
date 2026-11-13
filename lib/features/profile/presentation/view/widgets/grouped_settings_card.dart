import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// White rounded card grouping several [GroupedSettingsItem] rows with a
/// thin divider between each — used for "إعدادات التشغيل" and "الأمان".
class GroupedSettingsCard extends StatelessWidget {
  const GroupedSettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0) Divider(height: 1, color: DsColor.fill),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One row inside a [GroupedSettingsCard]: title + subtitle on the right,
/// icon in a light square on the far right, chevron on the far left (RTL).
class GroupedSettingsItem extends StatelessWidget {
  const GroupedSettingsItem({
    super.key,
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.height15(context)),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: DsColor.textSubtle,
              size: AppConstants.sp20(context),
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
                    style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Container(
              width: AppConstants.width20(context) * 2,
              height: AppConstants.width20(context) * 2,
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: DsColor.fill,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: SvgPicture.asset(
                icon,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Color(0xff0F0F0E), BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three "التسويق والعروض" cards: a plain icon over a label,
/// no icon-box background.
class MarketingActionCard extends StatelessWidget {
  const MarketingActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppConstants.height20(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          border: Border.all(color: DsColor.border),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              width: AppConstants.width30(context),
              colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Styles.inter12500Black(context),
            ),
          ],
        ),
      ),
    );
  }
}
