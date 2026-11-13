import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../create_coupon_view.dart';
import '../view_model/delete_coupon/delete_coupon_cubit.dart';

/// Coupon card. Hierarchy: the discount itself (what the customer gets) →
/// name → copyable code → scope → usage/expiry footer. State is a badge,
/// never a tinted card; edit/delete live in the ⋯ menu.
class CouponItem extends StatelessWidget {
  const CouponItem({super.key, required this.couponData, required this.index});

  final Items couponData;
  final int index;

  static const _typeIcons = {
    'free_shipping': Icons.local_shipping_outlined,
    'product_specific': Icons.inventory_2_outlined,
    'category_specific': Icons.category_outlined,
    'fixed_amount': Icons.payments_outlined,
    'percentage': Icons.percent_rounded,
  };

  String _typeLabel(String type) => switch (type) {
        'free_shipping' => 'شحن مجاني'.tr(),
        'product_specific' => "s_product_discount".tr(),
        'category_specific' => "s_category_discount".tr(),
        'fixed_amount' => "ds_fixed_amount".tr(),
        'percentage' => 'نسبة مئوية'.tr(),
        _ => '',
      };

  String _value(String type) {
    final v = couponData.discountValue;
    return switch (type) {
      'free_shipping' => "s_delivery_fee_discount".tr(),
      'fixed_amount' => v != null ? DsFormat.money(v) : '-',
      'percentage' || 'product_specific' || 'category_specific' => v != null ? '${dsLatin(v.toString())}%' : '-',
      _ => v?.toString() ?? '',
    };
  }

  bool get _isExpired {
    final validTo = DateTime.tryParse(couponData.validTo ?? "");
    return validTo != null && validTo.isBefore(DateTime.now());
  }

  void _copyCode() {
    final code = couponData.code ?? '';
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    toast(text: "s_coupon_code_copied".tr(), color: DsColor.success);
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await dsConfirm(
      context,
      title: "s_confirm_deletion".tr(),
      message: "s_are_you_sure_you_want_to_delete_this_5".tr(),
      confirmLabel: "s_delete".tr(),
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final cubit = context.read<DeleteCouponCubit>();
    cubit.selectedIndex = index;
    cubit.deleteCoupon(couponId: couponData.id!);
  }

  @override
  Widget build(BuildContext context) {
    final type = couponData.discountType ?? '';
    final split = couponData.isSplitCoupon == true;
    final expired = _isExpired;
    // Only a real name is shown; the type is already under the value.
    final title = couponData.name?.ar ?? couponData.name?.en ?? '';
    final description = couponData.description?.ar ?? couponData.description?.en ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsSpace.page),
      child: DsCard(
        padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.md, DsSpace.xs, DsSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount value + type, status, actions.
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: DsColor.primarySoft, borderRadius: BorderRadius.circular(DsRadius.md)),
                  child: Icon(split ? Icons.call_split_rounded : (_typeIcons[type] ?? Icons.local_offer_outlined), size: 20, color: DsColor.onPrimarySoft),
                ),
                const SizedBox(width: DsSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_value(type), maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.heading),
                      Text(split ? "كوبون مجزئ".tr() : _typeLabel(type), maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption),
                    ],
                  ),
                ),
                const SizedBox(width: DsSpace.sm),
                expired
                    ? DsStatusBadge(status: null, label: "s_ended".tr(), fg: DsColor.danger, bg: DsColor.dangerBg)
                    : DsStatusBadge(status: null, label: "s_active".tr(), fg: DsColor.success, bg: DsColor.successBg),
                _Menu(index: index, onEdit: () => NavigationUtils.navigateTo(context: context, destinationScreen: CreateCouponView(editingCoupon: couponData)), onDelete: () => _delete(context)),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DsSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpace.md),
                  if (title.isNotEmpty) Text(title, style: DsText.bodyStrong),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: DsText.caption),
                  ],
                  const SizedBox(height: DsSpace.md),
                  // Code: the thing staff read out / paste, so it is one tappable row.
                  Material(
                    color: DsColor.fill,
                    borderRadius: BorderRadius.circular(DsRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DsRadius.md),
                      onTap: _copyCode,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.md, DsSpace.sm, DsSpace.sm, DsSpace.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                couponData.code ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.start,
                                style: DsText.bodyStrong.copyWith(letterSpacing: 1),
                              ),
                            ),
                            if ((couponData.applicableUserGroups ?? []).isNotEmpty) ...[
                              DsStatusBadge(status: null, label: "i_x_customers_coupon".tr(namedArgs: {"a": "${couponData.applicableUserGroups!.length}"}), icon: Icons.group_outlined, fg: DsColor.primary, bg: DsColor.primarySoft),
                              const SizedBox(width: DsSpace.sm),
                            ] else ...[
                              DsStatusBadge(status: null, label: "لكل العملاء".tr(), icon: Icons.groups_outlined, fg: DsColor.textMuted, bg: DsColor.fill),
                              const SizedBox(width: DsSpace.sm),
                            ],
                            if (couponData.isHidden == true) ...[
                              DsStatusBadge(status: null, label: "s_hidden".tr(), icon: Icons.visibility_off_outlined, fg: DsColor.warning, bg: DsColor.warningBg),
                              const SizedBox(width: DsSpace.sm),
                            ],
                            Tooltip(message: "s_coupon_code_copied".tr(), child: const Icon(Icons.copy_rounded, size: 18, color: DsColor.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (split) ...[
                    const SizedBox(height: DsSpace.md),
                    Text(
                      type == "fixed_amount"
                          ? "i_egp_x_off_each_use_11".tr(namedArgs: {"a": "${couponData.splitValue}"})
                          : "i_x_off_each_use_12".tr(namedArgs: {"a": "${couponData.splitValue}"}),
                      style: DsText.label,
                    ),
                    Text("i_this_code_can_be_used_x_times_13".tr(namedArgs: {"a": "${couponData.totalSplits}"}), style: DsText.caption),
                  ],
                  if (type == "category_specific" && (couponData.categories?.isNotEmpty ?? false))
                    _Scope(
                      title: "s_applies_to_these_categories".tr(),
                      children: [for (final c in couponData.categories!) _ScopeChip(label: c.name ?? "")],
                    ),
                  if (type == "product_specific" && (couponData.products?.isNotEmpty ?? false))
                    _Scope(
                      title: "s_applies_to_these_products".tr(),
                      children: [
                        for (final p in couponData.products!)
                          _ScopeChip(
                            label: p.name ?? "",
                            trailing: p.price != null ? DsFormat.money(p.price) : null,
                            image: (p.images?.isNotEmpty ?? false) ? p.images!.first.attach : null,
                          ),
                      ],
                    ),
                  const SizedBox(height: DsSpace.md),
                  const Divider(height: 1),
                  const SizedBox(height: DsSpace.sm),
                  Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 16, color: DsColor.textMuted),
                      const SizedBox(width: DsSpace.xs),
                      Flexible(
                        child: Text(
                          "${"s_used".tr()}: ${"i_x_times_14".tr(namedArgs: {"a": DsFormat.count(couponData.usedCount ?? 0)})}",
                          style: DsText.caption,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.event_outlined, size: 16, color: expired ? DsColor.danger : DsColor.textMuted),
                      const SizedBox(width: DsSpace.xs),
                      Text(
                        DsFormat.date(context, couponData.validTo),
                        style: DsText.caption.copyWith(color: expired ? DsColor.danger : DsColor.text2, fontWeight: FontWeight.w600),
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

class _Menu extends StatelessWidget {
  const _Menu({required this.index, required this.onEdit, required this.onDelete});
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteCouponCubit, DeleteCouponState>(
      builder: (context, state) {
        final deleting = state is DeleteCouponLoadingState && context.read<DeleteCouponCubit>().selectedIndex == index;
        if (deleting) {
          return const SizedBox(width: DsSize.touch, height: DsSize.touch, child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))));
        }
        return PopupMenuButton<String>(
          tooltip: "s_edit".tr(),
          icon: const Icon(Icons.more_vert_rounded, color: DsColor.textMuted),
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [const Icon(Icons.edit_outlined, size: 20, color: DsColor.text2), const SizedBox(width: DsSpace.md), Text("s_edit".tr(), style: DsText.body)]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_outline_rounded, size: 20, color: DsColor.danger),
                const SizedBox(width: DsSpace.md),
                Text("s_delete".tr(), style: DsText.body.copyWith(color: DsColor.danger)),
              ]),
            ),
          ],
        );
      },
    );
  }
}

class _Scope extends StatelessWidget {
  const _Scope({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: DsSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsText.caption),
            const SizedBox(height: DsSpace.sm),
            Wrap(spacing: DsSpace.sm, runSpacing: DsSpace.sm, children: children),
          ],
        ),
      );
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.label, this.trailing, this.image});
  final String label;
  final String? trailing;
  final String? image;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsetsDirectional.fromSTEB(image != null ? 4 : DsSpace.md, 4, DsSpace.md, 4),
        decoration: BoxDecoration(
          color: DsColor.surface,
          border: Border.all(color: DsColor.border),
          borderRadius: BorderRadius.circular(DsRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              ClipOval(child: DefaultCachedNetworkImage(imageUrl: image!, imageHeight: 24, imageWidth: 24)),
              const SizedBox(width: DsSpace.sm),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.label),
            ),
            if (trailing != null) ...[
              const SizedBox(width: DsSpace.sm),
              Text(trailing!, style: DsText.caption.copyWith(color: DsColor.primary, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      );
}
