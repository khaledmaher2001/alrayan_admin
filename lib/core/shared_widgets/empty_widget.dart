import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:alrayan_admin/core/design/ds.dart';

/// Empty state (design system): small illustration, title, one explanatory line.
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, required this.icon, this.title, this.description, this.iconColor});
  final String icon;
  final String? title;
  final Color? iconColor;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpace.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140, maxHeight: 140),
              child: SvgPicture.asset(icon, colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null),
            ),
            const SizedBox(height: DsSpace.xl),
            if (title != null) Text(title!, textAlign: TextAlign.center, style: DsText.subheading),
            if (description != null) ...[
              const SizedBox(height: DsSpace.xs),
              Text(description!, textAlign: TextAlign.center, style: DsText.body.copyWith(color: DsColor.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
