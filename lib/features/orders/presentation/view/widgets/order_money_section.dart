import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/order_finance_repo.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_finance/order_finance_cubit.dart';

double _n(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
String _money(double v) => '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)} ${"s_egp".tr()}';

// A getter so the labels follow the current language.
Map<String, String> get _refundLabels => {
  'pending': "s_refund_pending".tr(),
  'completed': "s_refunded_2".tr(),
  'failed': "s_refund_failed".tr(),
  'not_required': "s_nothing_to_refund".tr(),
};

/// Cash collected / outstanding, returns and refunds of one order — same
/// server records as the web dashboard. [onChanged] reloads the order.
class OrderMoneySection extends StatelessWidget {
  const OrderMoneySection({super.key, required this.order, required this.onChanged});

  final Items order;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey('money-${order.id}-${order.updatedAt}-${order.paymentStatus}'),
      create: (_) => OrderFinanceCubit(getIt<OrderFinanceRepo>(), order.id!, onChanged: onChanged)..load(),
      child: BlocConsumer<OrderFinanceCubit, OrderFinanceState>(
        listener: (context, state) {
          if (state is OrderFinanceReady && state.message != null) cherryToast(text: state.message!, context: context);
          if (state is OrderFinanceReady && state.error != null) cherryToast(text: state.error!, isSuccess: false, context: context);
        },
        builder: (context, state) {
          final cubit = context.read<OrderFinanceCubit>();
          final returns = state is OrderFinanceReady ? state.returns : <OrderReturnModel>[];
          final busy = state is OrderFinanceReady && state.busy;
          final total = _n(order.totalAmount);
          final collected = _n(order.amountCollected);
          final refunded = _n(order.amountRefunded);
          final outstanding = (total - collected).clamp(0, double.infinity).toDouble();
          final owed = returns.where((r) => r.refundStatus == 'pending' || r.refundStatus == 'failed').fold<double>(0, (s, r) => s + r.refundAmount);
          final active = order.status == 'shipped' || order.status == 'delivered';
          final canReturn = active && (order.orderItems ?? []).any((i) => (i.quantity ?? 0) > (i.returnedQuantity ?? 0));

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffE3E7EC)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.payments_rounded, color: AppColors.primarySwatchColor, size: 20),
                  const SizedBox(width: 6),
                  Text("s_collection_returns".tr(), style: Styles.inter16500black(context)),
                  if (busy) ...[const Spacer(), const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))],
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _fig(context, "s_collected".tr(), _money(collected)),
                  _fig(context, "s_left_to_collect".tr(), _money(outstanding), warn: outstanding > 0 && order.status == 'delivered'),
                  _fig(context, "s_refunded_3".tr(), _money(refunded)),
                  _fig(context, "s_owed_to_the_customer".tr(), _money(owed), warn: owed > 0),
                ]),
                if (order.status == 'delivered' && outstanding > 0) ...[
                  const SizedBox(height: 8),
                  Text("s_the_order_is_delivered_but_its_cash_".tr(), style: Styles.inter14500black(context).copyWith(color: DsColor.warning)),
                ],
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (active && outstanding > 0)
                    ElevatedButton.icon(
                      onPressed: busy ? null : () => _confirmCollect(context, cubit, outstanding),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text("s_confirm_cash_collection".tr()),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primarySwatchColor, foregroundColor: Colors.white),
                    ),
                  if (canReturn)
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => _openReturnSheet(context, cubit, collected - refunded - owed),
                      icon: const Icon(Icons.assignment_return_outlined, size: 18),
                      label: Text("s_record_return".tr()),
                    ),
                ]),
                if (returns.isNotEmpty) ...[
                  const Divider(height: 24),
                  for (final r in returns) _returnTile(context, cubit, r, busy),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fig(BuildContext context, String label, String value, {bool warn = false}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: warn ? DsColor.warning.withValues(alpha: 0.1) : const Color(0xffF6F7F5),
        border: Border.all(color: warn ? DsColor.warning : const Color(0xffE3E7EC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _returnTile(BuildContext context, OrderFinanceCubit cubit, OrderReturnModel r, bool busy) {
    final lines = r.items.map((i) {
      final line = (order.orderItems ?? []).where((x) => x.id == i.orderItemId).firstOrNull;
      return '${i.quantity} × ${line?.productName ?? '#${i.orderItemId}'} — ${i.restock ? 'عاد للمخزون' : 'تالف'}';
    }).join('\n');
    final open = r.refundStatus == 'pending' || r.refundStatus == 'failed';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (r.refundStatus == 'completed' ? DsColor.success : open ? DsColor.warning : DsColor.textMuted).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_refundLabels[r.refundStatus] ?? r.refundStatus, style: Styles.inter12500Black(context)),
          ),
          const Spacer(),
          Text(_money(r.refundAmount), style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text(lines, style: Styles.inter12500Black(context).copyWith(color: DsColor.text2)),
        if (r.refundStatus == 'failed' && r.refundFailureReason != null)
          Text(r.refundFailureReason!, style: Styles.inter12500Black(context).copyWith(color: AppColors.redColor)),
        if (open)
          Wrap(spacing: 8, children: [
            TextButton(onPressed: busy ? null : () => _confirmRefund(context, cubit, r), child: Text("s_refunded_to_the_customer".tr())),
            TextButton(onPressed: busy ? null : () => _failRefund(context, cubit, r), child: Text("s_refund_failed_2".tr(), style: TextStyle(color: DsColor.text2))),
          ]),
      ]),
    );
  }

  Future<void> _confirmCollect(BuildContext context, OrderFinanceCubit cubit, double outstanding) async {
    final ctrl = TextEditingController(text: outstanding.toStringAsFixed(outstanding == outstanding.roundToDouble() ? 0 : 2));
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text("s_confirm_cash_collection".tr()),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("s_record_only_the_amount_you_actually_".tr()),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "s_amount_received".tr(), suffixText: "s_egp".tr())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text("s_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text("s_confirm".tr())),
        ],
      ),
    );
    if (ok != true) return;
    final amount = double.tryParse(ctrl.text.trim());
    if (amount == null || amount <= 0 || amount > outstanding + 0.001) {
      if (context.mounted) cherryToast(text: "i_the_amount_must_be_between_0_01_an_76".tr(namedArgs: {"a": "${_money(outstanding)}"}), isSuccess: false, context: context);
      return;
    }
    await cubit.collect(amount: amount);
  }

  Future<void> _confirmRefund(BuildContext context, OrderFinanceCubit cubit, OrderReturnModel r) async {
    final ref = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text("i_refund_x_to_the_customer_77".tr(namedArgs: {"a": "${_money(r.refundAmount)}"})),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("s_make_sure_you_actually_gave_the_amou".tr()),
          TextField(controller: ref, decoration: InputDecoration(labelText: "s_receipt_reference_number_optional".tr())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text("s_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text("s_refunded_4".tr())),
        ],
      ),
    );
    if (ok == true) await cubit.confirmRefund(r.id, reference: ref.text);
  }

  Future<void> _failRefund(BuildContext context, OrderFinanceCubit cubit, OrderReturnModel r) async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text("s_couldn_t_refund".tr()),
        content: TextField(controller: reason, maxLines: 2, decoration: InputDecoration(labelText: "s_reason".tr())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text("s_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(d, true), child: Text("s_record".tr())),
        ],
      ),
    );
    if (ok == true && reason.text.trim().isNotEmpty) await cubit.failRefund(r.id, reason.text.trim());
  }

  Future<void> _openReturnSheet(BuildContext context, OrderFinanceCubit cubit, double refundable) async {
    final lines = (order.orderItems ?? []).where((i) => (i.quantity ?? 0) > (i.returnedQuantity ?? 0)).toList();
    final qty = {for (final l in lines) l.id!: 0};
    final restock = {for (final l in lines) l.id!: true};
    var refundCash = true;
    var fee = false;
    final note = TextEditingController();

    final submit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => StatefulBuilder(builder: (sheet, setState) {
        final value = lines.fold<double>(0, (s, l) => s + _n(l.totalPrice) / (l.quantity ?? 1) * (qty[l.id] ?? 0)) + (fee ? _n(order.shippingAmount) : 0);
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(sheet).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text("s_record_return_goods_are_back_at_the_".tr(), style: Styles.inter16500black(sheet)),
              const SizedBox(height: 4),
              Text("s_choose_the_quantities_you_actually_r".tr(), style: Styles.inter12500Black(sheet).copyWith(color: DsColor.text2)),
              const SizedBox(height: 12),
              for (final l in lines)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.productName ?? '#${l.id}', style: Styles.inter14500black(sheet)),
                      Text("i_returned_x_of_x_78".tr(namedArgs: {"a": "${l.returnedQuantity ?? 0}", "b": "${l.quantity}"}), style: Styles.inter12500Black(sheet).copyWith(color: DsColor.textMuted)),
                      Row(children: [
                        IconButton(onPressed: (qty[l.id]! > 0) ? () => setState(() => qty[l.id!] = qty[l.id]! - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
                        Text('${qty[l.id]}', style: Styles.inter16500black(sheet)),
                        IconButton(
                          onPressed: (qty[l.id]! < (l.quantity ?? 0) - (l.returnedQuantity ?? 0)) ? () => setState(() => qty[l.id!] = qty[l.id]! + 1) : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        const Spacer(),
                        Text("s_sellable".tr()),
                        Switch(value: restock[l.id]!, onChanged: (v) => setState(() => restock[l.id!] = v)),
                      ]),
                    ]),
                  ),
                ),
              if (_n(order.shippingAmount) > 0)
                CheckboxListTile(contentPadding: EdgeInsets.zero, value: fee, onChanged: (v) => setState(() => fee = v ?? false), title: Text("s_also_refund_the_delivery_fee".tr())),
              SwitchListTile(contentPadding: EdgeInsets.zero, value: refundCash, onChanged: (v) => setState(() => refundCash = v), title: Text("s_cash_refund_to_the_customer".tr()), subtitle: Text("s_turn_it_off_for_an_exchange_without_".tr())),
              TextField(controller: note, decoration: InputDecoration(labelText: "s_note_optional".tr())),
              const SizedBox(height: 12),
              Text("i_returned_goods_value_x_79".tr(namedArgs: {"a": "${_money(value)}"}), style: Styles.inter14500black(sheet).copyWith(fontWeight: FontWeight.w700)),
              Text(
                !refundCash ? "s_no_refund_amount_will_be_recorded".tr() : refundable > 0 ? "s_the_amount_will_be_recorded_as_owed_".tr() : "s_nothing_was_collected_for_this_order".tr(),
                style: Styles.inter12500Black(sheet).copyWith(color: DsColor.text2),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primarySwatchColor, foregroundColor: Colors.white),
                  onPressed: qty.values.any((q) => q > 0) ? () => Navigator.pop(sheet, true) : null,
                  child: Text("s_record_the_return".tr()),
                ),
              ),
            ]),
          ),
        );
      }),
    );
    if (submit != true) return;
    await cubit.createReturn(
      items: [for (final l in lines) if ((qty[l.id] ?? 0) > 0) {'orderItemId': l.id, 'quantity': qty[l.id], 'restock': restock[l.id]}],
      refundCash: refundCash,
      includeDeliveryFee: fee,
      note: note.text,
    );
  }
}
