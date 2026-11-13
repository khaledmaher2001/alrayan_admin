import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:flutter/material.dart';

/// Header icon button used by the delivery screens (back, filter, edit).
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
    // Same neutral 48dp icon button as every other top bar.
    return IconButton(
      onPressed: onTap,
      constraints: const BoxConstraints.tightFor(width: DsSize.touch, height: DsSize.touch),
      icon: Icon(icon == Icons.arrow_back ? Icons.arrow_back_rounded : icon, color: DsColor.text),
    );
  }
}
