import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'brand.dart';

export 'brand.dart';

/// "Quiet operations" design system (see docs/audit/ux-2026-10-09/admin-delivery-full-redesign.md).
///
/// - Neutral canvas, white surfaces separated by 1px lines (no heavy shadows).
/// - Brand colour only for the primary action, the current navigation item and selection.
/// - Status = dot + text on a faint tint, from one palette ([DsStatus]).
/// - Fixed type scale in logical units (respects the system font size).

class DsSpace {
  DsSpace._();
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32;
  static const double page = 16, section = 24;
}

class DsRadius {
  DsRadius._();
  static const double sm = 8, md = 12, lg = 16, pill = 999;
}

class DsSize {
  DsSize._();
  static const double button = 48, buttonLg = 56, input = 52, touch = 48, row = 56, icon = 22, iconSm = 18;
}

class DsColor {
  DsColor._();
  // Canvas & surfaces
  static const page = DsBrand.background;
  static const surface = Colors.white;
  static const fill = Color(0xffF3F4F6);
  // Lines
  static const border = Color(0xffE5E7EB);
  static const divider = Color(0xffF0F1F3);
  // Ink
  static const text = Color(0xff111827);
  static const text2 = Color(0xff4B5563);
  static const textMuted = Color(0xff6B7280);
  static const textSubtle = Color(0xff9CA3AF);
  // Meaning
  static const success = Color(0xff15803D);
  static const successBg = Color(0xffE8F5EC);
  static const warning = Color(0xffB45309);
  static const warningBg = Color(0xffFDF3E3);
  static const danger = Color(0xffB91C1C);
  static const dangerBg = Color(0xffFDECEC);
  static const info = Color(0xff1D4ED8);
  static const infoBg = Color(0xffEAF0FD);
  // Brand
  static const primary = DsBrand.primary;
  static const primaryPressed = DsBrand.primaryPressed;
  static const primarySoft = DsBrand.primaryContainer;
  static const onPrimarySoft = DsBrand.onPrimaryContainer;
  static const accent = DsBrand.accent;
}

/// Order status palette shared by every screen (text colour, faint background).
class DsStatus {
  DsStatus._();
  static const _map = {
    'pending': (Color(0xff92400E), Color(0xffFEF3C7)),
    'confirmed': (Color(0xff1D4ED8), Color(0xffEAF0FD)),
    'processing': (Color(0xff1D4ED8), Color(0xffEAF0FD)),
    'shipped': (Color(0xff6D28D9), Color(0xffF1EBFD)),
    'delivered': (Color(0xff15803D), Color(0xffE8F5EC)),
    'cancelled': (Color(0xffB91C1C), Color(0xffFDECEC)),
    'refunded': (Color(0xff4B5563), Color(0xffF3F4F6)),
  };
  static Color fg(String? s) => (_map[s] ?? (DsColor.text2, DsColor.fill)).$1;
  static Color bg(String? s) => (_map[s] ?? (DsColor.text2, DsColor.fill)).$2;
}

class DsText {
  DsText._();
  static const _base = TextStyle(fontFamily: 'Inter', color: DsColor.text, height: 1.4);
  static const display = TextStyle(fontFamily: 'Inter', color: DsColor.text, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, fontFeatures: [FontFeature.tabularFigures()]);
  static final title = _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
  static final heading = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3);
  static final subheading = _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  static final body = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  static final bodyStrong = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w700);
  static final label = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  static final caption = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: DsColor.textMuted);
  static final number = _base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]);
}

/// 0-9 digits everywhere (the app shows prices/numbers in Latin digits).
String dsLatin(String s) => s.replaceAllMapped(
      RegExp('[٠-٩]'),
      (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x0660 + 0x30),
    );

class DsFormat {
  DsFormat._();
  static String money(num? v) => '${NumberFormat('#,##0.##', 'en').format(v ?? 0)} ${"s_egp".tr()}';
  static String count(num? v) => NumberFormat('#,##0', 'en').format(v ?? 0);

  /// "11 Oct · 1:55 PM" in the current language, Latin digits.
  static String dateTime(BuildContext context, String? iso) {
    final d = DateTime.tryParse(iso ?? '')?.toLocal();
    if (d == null) return '';
    final lang = context.locale.languageCode;
    return dsLatin('${DateFormat('d MMM', lang).format(d)} · ${DateFormat('h:mm a', lang).format(d)}');
  }

  static String date(BuildContext context, String? iso) {
    final d = DateTime.tryParse(iso ?? '')?.toLocal();
    if (d == null) return '';
    return dsLatin(DateFormat('d MMM yyyy', context.locale.languageCode).format(d));
  }

  /// Order numbers stay left-to-right inside Arabic text.
  static String orderNo(String? n) => '${String.fromCharCode(0x2066)}#${n ?? ''}${String.fromCharCode(0x2069)}';
}

// ───────────────────────────── Page structure ─────────────────────────────

/// Top of a main (tab) screen: large title at the start, optional subtitle,
/// up to two 48dp actions at the end. No logo, no centred title.
class DsPageHeader extends StatelessWidget {
  const DsPageHeader({super.key, required this.title, this.subtitle, this.actions = const []});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.page, DsSpace.md, DsSpace.page, DsSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.title),
                  if (subtitle != null) Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
            for (final a in actions) ...[const SizedBox(width: DsSpace.sm), a],
          ],
        ),
      );
}

/// Top bar of a pushed (detail/form) screen: back, title, actions.
class DsTopBar extends StatelessWidget {
  const DsTopBar({super.key, required this.title, this.subtitle, this.actions = const [], this.onBack});
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Container(
        // Sits on the page canvas like every other top bar (no fill, no line).
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, DsSpace.sm, 4),
        child: Row(
          children: [
            IconButton(
              tooltip: "a11y_back".tr(),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              constraints: const BoxConstraints.tightFor(width: DsSize.touch, height: DsSize.touch),
              icon: const Icon(Icons.arrow_back_rounded, color: DsColor.text),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.heading),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      );
}

/// Sticky bottom area for the screen's primary action(s).
class DsBottomBar extends StatelessWidget {
  const DsBottomBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: DsColor.surface,
          border: Border(top: BorderSide(color: DsColor.border)),
        ),
        padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.md, DsSpace.page, DsSpace.md),
        child: SafeArea(top: false, child: child),
      );
}

class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({super.key, required this.title, this.trailing, this.padding});
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? const EdgeInsetsDirectional.only(top: DsSpace.section, bottom: DsSpace.sm, start: 4, end: 4),
        child: Row(
          children: [
            Expanded(child: Text(title, style: DsText.label.copyWith(color: DsColor.text2))),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

// ───────────────────────────── Surfaces ─────────────────────────────

/// Entity card (an order, a product, a coupon…): white, 16 radius, 1px line.
class DsCard extends StatelessWidget {
  const DsCard({super.key, required this.child, this.onTap, this.padding, this.highlight});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DsRadius.lg);
    return Material(
      color: DsColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: highlight ?? DsColor.border, width: highlight != null ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding ?? const EdgeInsets.all(DsSpace.lg), child: child),
      ),
    );
  }
}

/// Grouped list: one white surface holding rows separated by hairlines.
class DsGroup extends StatelessWidget {
  const DsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: DsColor.surface,
          borderRadius: BorderRadius.circular(DsRadius.lg),
          border: Border.all(color: DsColor.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1, indent: DsSpace.lg, endIndent: DsSpace.lg, color: DsColor.divider),
              children[i],
            ],
          ],
        ),
      );
}

/// Row inside a [DsGroup]: optional leading icon, title/subtitle, trailing value or control.
class DsRow extends StatelessWidget {
  const DsRow({super.key, required this.title, this.subtitle, this.icon, this.trailing, this.value, this.onTap, this.danger = false, this.showChevron});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? DsColor.danger : DsColor.text;
    final chevron = showChevron ?? (onTap != null && trailing == null);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DsSize.row),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, 10, DsSpace.md, 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: DsSize.icon, color: danger ? DsColor.danger : DsColor.textMuted),
                const SizedBox(width: DsSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: DsText.body.copyWith(color: fg, fontWeight: FontWeight.w600)),
                    if (subtitle != null && subtitle!.isNotEmpty) Text(subtitle!, style: DsText.caption),
                  ],
                ),
              ),
              if (value != null) Padding(padding: const EdgeInsetsDirectional.only(start: DsSpace.sm), child: Text(value!, style: DsText.body.copyWith(color: DsColor.text2))),
              if (trailing != null) Padding(padding: const EdgeInsetsDirectional.only(start: DsSpace.sm), child: trailing!),
              if (chevron) const Padding(padding: EdgeInsetsDirectional.only(start: 4), child: Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to four figures on one white strip, separated by hairlines — no coloured tiles.
class DsMetricStrip extends StatelessWidget {
  const DsMetricStrip({super.key, required this.items});
  final List<DsMetric> items;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: DsColor.surface,
          borderRadius: BorderRadius.circular(DsRadius.lg),
          border: Border.all(color: DsColor.border),
        ),
        padding: const EdgeInsets.symmetric(vertical: DsSpace.md),
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const VerticalDivider(width: 1, thickness: 1, color: DsColor.divider),
                Expanded(child: items[i]),
              ],
            ],
          ),
        ),
      );
}

class DsMetric extends StatelessWidget {
  const DsMetric({super.key, required this.label, required this.value, this.color, this.onTap});
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsSpace.md, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, maxLines: 1, style: DsText.number.copyWith(color: color ?? DsColor.text)),
              ),
              const SizedBox(height: 2),
              Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: DsText.caption),
            ],
          ),
        ),
      );
}

// ───────────────────────────── Status & chips ─────────────────────────────

/// Status pill: coloured dot + text on a faint tint (never colour alone).
class DsStatusBadge extends StatelessWidget {
  const DsStatusBadge({super.key, required this.status, required this.label, this.icon, this.fg, this.bg});
  final String? status;
  final String label;
  final IconData? icon;
  final Color? fg;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final f = fg ?? DsStatus.fg(status);
    final b = bg ?? DsStatus.bg(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(DsRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: f)
          else
            Container(width: 7, height: 7, decoration: BoxDecoration(color: f, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: DsText.caption.copyWith(color: f, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Filter chip: selected = brand fill; others white with a line. Optional count.
class DsChip extends StatelessWidget {
  const DsChip({super.key, required this.label, required this.selected, required this.onTap, this.count});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : DsColor.text;
    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? label : '$label $count',
      excludeSemantics: true,
      child: Material(
        color: selected ? DsColor.primary : DsColor.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? DsColor.primary : DsColor.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: DsText.label.copyWith(color: fg)),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text(DsFormat.count(count), style: DsText.label.copyWith(color: selected ? Colors.white.withValues(alpha: .8) : DsColor.textMuted)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Actions ─────────────────────────────

enum DsButtonKind { primary, secondary, tertiary, destructive }

class DsButton extends StatelessWidget {
  const DsButton({super.key, required this.label, required this.onPressed, this.kind = DsButtonKind.primary, this.icon, this.loading = false, this.expand = true, this.large = false});
  final String label;
  final VoidCallback? onPressed;
  final DsButtonKind kind;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      DsButtonKind.primary => (DsColor.primary, Colors.white, Colors.transparent),
      DsButtonKind.secondary => (DsColor.primarySoft, DsColor.onPrimarySoft, Colors.transparent),
      DsButtonKind.tertiary => (Colors.transparent, DsColor.primary, Colors.transparent),
      DsButtonKind.destructive => (Colors.white, DsColor.danger, DsColor.danger.withValues(alpha: .35)),
    };
    final child = loading
        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: DsSpace.sm)],
              Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong.copyWith(color: fg, fontSize: 15, height: 1.3))),
            ],
          );
    final button = TextButton(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: kind == DsButtonKind.tertiary ? Colors.transparent : DsColor.fill,
        disabledForegroundColor: DsColor.textSubtle,
        minimumSize: Size(64, large ? DsSize.buttonLg : DsSize.button),
        padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.md), side: BorderSide(color: border)),
      ),
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 48dp icon button with a screen-reader label.
class DsIconButton extends StatelessWidget {
  const DsIconButton({super.key, required this.icon, required this.label, required this.onPressed, this.filled = false, this.badge = false});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  /// Small accent dot (e.g. unread notifications).
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: label,
            onPressed: onPressed,
            constraints: const BoxConstraints.tightFor(width: DsSize.touch, height: DsSize.touch),
            style: IconButton.styleFrom(
              backgroundColor: filled ? DsColor.primarySoft : DsColor.surface,
              side: filled ? null : const BorderSide(color: DsColor.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.md)),
            ),
            icon: Icon(icon, size: DsSize.icon, color: filled ? DsColor.primary : DsColor.text),
          ),
          if (badge)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: DsColor.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
        ],
      );
}

// ───────────────────────────── Inputs ─────────────────────────────

class DsSearchField extends StatelessWidget {
  const DsSearchField({super.key, required this.hint, this.controller, this.onChanged, this.onSubmitted, this.autofocus = false});
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: DsText.body,
        decoration: dsInput(hint: hint).copyWith(prefixIcon: const Icon(Icons.search_rounded, color: DsColor.textMuted)),
      );
}

/// Standard field decoration: white, 1px line, brand outline on focus.
InputDecoration dsInput({String? hint, Widget? prefix, Widget? suffix}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(DsRadius.md),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: DsText.body.copyWith(color: DsColor.textSubtle),
    filled: true,
    fillColor: DsColor.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: 15),
    prefixIcon: prefix,
    suffixIcon: suffix,
    border: b(DsColor.border),
    enabledBorder: b(DsColor.border),
    disabledBorder: b(DsColor.divider),
    focusedBorder: b(DsColor.primary, 1.5),
    errorBorder: b(DsColor.danger),
    focusedErrorBorder: b(DsColor.danger, 1.5),
    errorStyle: DsText.caption.copyWith(color: DsColor.danger),
  );
}

/// Label above a field (13/600), with an optional "required" mark.
class DsField extends StatelessWidget {
  const DsField({super.key, required this.label, required this.child, this.required = false, this.help});
  final String label;
  final Widget child;
  final bool required;
  final String? help;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(text: label, children: [if (required) const TextSpan(text: ' *', style: TextStyle(color: DsColor.danger))]),
            style: DsText.label,
          ),
          const SizedBox(height: 6),
          child,
          if (help != null) ...[const SizedBox(height: 4), Text(help!, style: DsText.caption)],
        ],
      );
}

// ───────────────────────────── Feedback ─────────────────────────────

/// Empty / error state with an optional action.
class DsMessage extends StatelessWidget {
  const DsMessage({super.key, required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DsSpace.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: DsColor.fill, shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: DsColor.textMuted),
              ),
              const SizedBox(height: DsSpace.lg),
              Text(title, textAlign: TextAlign.center, style: DsText.subheading),
              if (subtitle != null) ...[
                const SizedBox(height: DsSpace.xs),
                Text(subtitle!, textAlign: TextAlign.center, style: DsText.body.copyWith(color: DsColor.textMuted)),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: DsSpace.lg),
                DsButton(label: actionLabel!, onPressed: onAction, kind: DsButtonKind.secondary, expand: false, icon: Icons.refresh_rounded),
              ],
            ],
          ),
        ),
      );
}

/// Grey placeholder block for loading skeletons.
class DsSkeleton extends StatelessWidget {
  const DsSkeleton({super.key, this.height = 16, this.width, this.radius = DsRadius.sm});
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: DsColor.fill, borderRadius: BorderRadius.circular(radius)),
      );
}

/// Asks before a consequential action; returns true when confirmed.
Future<bool> dsConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      backgroundColor: DsColor.surface,
      surfaceTintColor: DsColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg)),
      title: Text(title, style: DsText.heading),
      content: Text(message, style: DsText.body.copyWith(color: DsColor.text2)),
      actionsPadding: const EdgeInsets.fromLTRB(DsSpace.xxl, 0, DsSpace.xxl, DsSpace.xl),
      actions: [
        Row(
          children: [
            Expanded(child: DsButton(label: "s_cancel".tr(), kind: DsButtonKind.secondary, onPressed: () => Navigator.of(d).pop(false))),
            const SizedBox(width: DsSpace.sm),
            Expanded(
              child: DsButton(
                label: confirmLabel,
                kind: destructive ? DsButtonKind.destructive : DsButtonKind.primary,
                onPressed: () => Navigator.of(d).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return ok ?? false;
}
