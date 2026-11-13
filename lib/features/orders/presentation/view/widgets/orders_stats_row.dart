import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter/material.dart';

/// One quiet line above the list: how many orders are shown and how many
/// arrived today (the status chips already carry the per-status counts).
class OrdersStatsRow extends StatelessWidget {
  const OrdersStatsRow({super.key, required this.totalDisplayed, required this.todayCount});

  final int totalDisplayed;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsSpace.page),
      child: Row(
        children: [
          Text(
            "ord_shown".tr(namedArgs: {"n": DsFormat.count(totalDisplayed)}),
            style: DsText.caption.copyWith(fontSize: 13, color: DsColor.text, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.today_outlined, size: 16, color: DsColor.textMuted),
          const SizedBox(width: 4),
          Text("ord_today".tr(namedArgs: {"n": DsFormat.count(todayCount)}), style: DsText.caption.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
