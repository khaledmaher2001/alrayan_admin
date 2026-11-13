import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:flutter/material.dart';

import 'notification_bell_button.dart';

/// Top bar of a pushed screen (design system: back + start-aligned title).
/// Kept under its old name and parameters so every existing screen adopts it.
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.hasBack = false,
    this.withNotifications = true,
    this.textColor,
  });

  final String title;
  final bool? hasBack;
  final bool? withNotifications;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    // Only an explicit non-white colour is honoured; the bar sits on light surfaces.
    final ink = textColor != null && textColor != Colors.white ? textColor! : DsColor.text;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: hasBack! ? 4 : DsSpace.page, end: DsSpace.sm),
        child: Row(
          children: [
            if (hasBack!) ...[
              IconButton(
                tooltip: "a11y_back".tr(),
                onPressed: () => NavigationUtils.navigateBack(context: context),
                constraints: const BoxConstraints.tightFor(width: DsSize.touch, height: DsSize.touch),
                icon: Icon(Icons.arrow_back_rounded, color: ink),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (hasBack! ? DsText.heading : DsText.title).copyWith(color: ink),
              ),
            ),
            if (withNotifications!) const NotificationBellButton(),
          ],
        ),
      ),
    );
  }
}
