import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:flutter/material.dart';

/// Pink-circle, red-icon round button used across the "الدليفري" screens'
/// headers (back/forward, filter, edit) — the design language every
/// delivery screen shares, distinct from the app-wide grey [CustomBackButton].
class DeliveryRoundIconButton extends StatelessWidget {
  const DeliveryRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Convenience constructor for the header's back button — pops the
  /// current screen, same navigation as [CustomBackButton].
  factory DeliveryRoundIconButton.back(BuildContext context) {
    return DeliveryRoundIconButton(
      icon: Icons.arrow_back,
      onTap: () => NavigationUtils.navigateBack(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 20),
      ),
    );
  }
}
