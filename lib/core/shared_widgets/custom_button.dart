import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final void Function()? onPress;
  final String text;
  final Widget? icon;
  final double? borderRadius;
  final double? height;
  final double? fontSize;
  final String? fontFamily;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final bool hasBorder;
  final double? elevation;

  const DefaultButton({
    super.key,
    required this.onPress,
    required this.text,
    this.icon,
    this.borderRadius,
    this.height,
    this.fontFamily,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.hasBorder = false,
    this.borderColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor
  });

  @override
  Widget build(BuildContext context) {
    // Design system geometry for every button in the app: 48dp, radius 12, no shadow.
    // Colours/border/icon passed by a screen are kept; radius/height/elevation are unified.
    final bg = backgroundColor ?? DsColor.primary;
    final fg = textColor ?? Colors.white;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: DsColor.fill,
        disabledForegroundColor: DsColor.textSubtle,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        minimumSize: const Size(64, DsSize.button),
        padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
          side: BorderSide(color: hasBorder ? (borderColor ?? DsColor.primary) : Colors.transparent),
        ),
      ),
      onPressed: onPress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: DsSpace.sm)],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: onPress == null ? DsColor.textSubtle : fg, fontWeight: FontWeight.w700, fontSize: 15, height: 1.3, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }
}
