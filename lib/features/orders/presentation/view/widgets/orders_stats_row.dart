import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';

class OrdersStatsRow extends StatelessWidget {
  const OrdersStatsRow({super.key, required this.totalDisplayed, required this.todayCount});

  final int totalDisplayed;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height15(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.shopping_bag_rounded,
              iconColor: AppColors.primaryColor,
              iconBg: AppColors.primaryColor.shade50,
              label: "إجمالي المعروض",
              value: "$totalDisplayed",
            ),
          ),
          Container(width: 1, height: AppConstants.height30(context), color: const Color(0xffE3E7EC)),
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today_rounded,
              iconColor: Colors.blue.shade700,
              iconBg: Colors.blue.withValues(alpha: 0.1),
              label: "طلبات اليوم",
              value: "$todayCount",
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), fontSize: 12),
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              value,
              style: Styles.inter18500Black(context).copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        SizedBox(width: AppConstants.width10(context)),
        Container(
          padding: EdgeInsets.all(AppConstants.sp10(context)),
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ],
    );
  }
}
