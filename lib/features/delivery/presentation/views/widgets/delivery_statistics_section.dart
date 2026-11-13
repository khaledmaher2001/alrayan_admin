import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_statistics_model.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// `GET /delivery/statistics` overview for the delivery hub, ordered by what
/// an admin acts on: cash waiting for review → team → money.
/// Every figure comes from the API; nothing is derived or invented.
class DeliveryStatisticsSection extends StatelessWidget {
  const DeliveryStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDeliveryStatisticsCubit, GetDeliveryStatisticsStates>(
      builder: (context, state) {
        if (state is GetDeliveryStatisticsErrorState) {
          return DsCard(
            child: DsMessage(
              icon: Icons.cloud_off_rounded,
              title: state.errMessage,
              actionLabel: "retry".tr(),
              onAction: () => context.read<GetDeliveryStatisticsCubit>().getStatistics(),
            ),
          );
        }
        if (state is! GetDeliveryStatisticsSuccessState) return const _Loading();
        final overview = state.model.overview;
        if (overview == null) return const SizedBox.shrink();
        return _Content(overview: overview);
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          SizedBox(height: DsSpace.md),
          DsSkeleton(height: 64, radius: DsRadius.lg),
          SizedBox(height: DsSpace.lg),
          DsSkeleton(height: 84, radius: DsRadius.lg),
          SizedBox(height: DsSpace.lg),
          DsSkeleton(height: 150, radius: DsRadius.lg),
        ],
      );
}

class _Content extends StatelessWidget {
  const _Content({required this.overview});
  final DeliveryStatisticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final pending = overview.pendingRemittances;
    final month = overview.thisMonth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending != null) ...[const SizedBox(height: DsSpace.md), _PendingRemittances(pending: pending)],
        DsSectionHeader(title: "delivery_couriers".tr()),
        DsMetricStrip(
          items: [
            DsMetric(
              label: "s_active_couriers".tr(),
              value: '${DsFormat.count(overview.activeCouriers ?? 0)} / ${DsFormat.count(overview.totalCouriers ?? 0)}',
              color: DsColor.success,
            ),
            DsMetric(label: "s_delivered_orders".tr(), value: DsFormat.count(overview.totalDeliveredOrders ?? 0)),
          ],
        ),
        DsSectionHeader(title: "s_financial_summary".tr()),
        _MoneyPanel(
          rows: [
            if (month != null) ...[
              _Heading("delivery_stat_this_month".tr()),
              [
                DsMetric(label: "delivery_stat_remitted".tr(), value: DsFormat.money(month.remitted)),
                DsMetric(label: "delivery_stat_gross_collected".tr(), value: DsFormat.money(month.grossCollected)),
              ],
              [DsMetric(label: "delivery_stat_earnings".tr(), value: DsFormat.money(month.earnings), color: DsColor.primary)],
            ],
            _Heading("s_total".tr()),
            [
              DsMetric(label: "delivery_stat_remitted".tr(), value: DsFormat.money(overview.totalRemitted)),
              DsMetric(label: "delivery_stat_gross_collected".tr(), value: DsFormat.money(overview.totalGrossCollected)),
            ],
            [
              DsMetric(label: "delivery_stat_owed_to_store".tr(), value: DsFormat.money(overview.totalOwedToStore)),
              DsMetric(label: "delivery_stat_earnings".tr(), value: DsFormat.money(overview.totalEarnings), color: DsColor.primary),
            ],
          ],
        ),
      ],
    );
  }
}

class _Heading {
  const _Heading(this.text);
  final String text;
}

/// One white surface: small headings and two-up figures separated by hairlines.
class _MoneyPanel extends StatelessWidget {
  const _MoneyPanel({required this.rows});
  final List<Object> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final r in rows) {
      if (r is _Heading) {
        if (children.isNotEmpty) children.add(const Divider(height: 1));
        children.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.md, DsSpace.lg, 0),
          child: Text(r.text, style: DsText.label.copyWith(color: DsColor.textMuted)),
        ));
      } else if (r is List<DsMetric>) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpace.sm),
          child: IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i == 1) const VerticalDivider(width: 1, color: DsColor.divider),
                  Expanded(child: i < r.length ? Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: r[i]) : const SizedBox()),
                ],
              ],
            ),
          ),
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: DsColor.surface,
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// Cash handovers waiting for review: the one thing on this screen that needs
/// a decision, so it leads and links straight to the review list.
class _PendingRemittances extends StatelessWidget {
  const _PendingRemittances({required this.pending});
  final PendingRemittances pending;

  @override
  Widget build(BuildContext context) {
    final has = (pending.count ?? 0) > 0;
    void open() => NavigationUtils.navigateTo(context: context, destinationScreen: const RemittancesView());
    if (!has) {
      return DsGroup(children: [
        DsRow(
          icon: Icons.check_circle_outline_rounded,
          title: "s_no_cash_handovers_waiting_for_review".tr(),
          onTap: open,
        ),
      ]);
    }
    return DsCard(
      highlight: DsColor.warning,
      onTap: open,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: DsColor.warningBg, borderRadius: BorderRadius.circular(DsRadius.md)),
            child: const Icon(Icons.payments_outlined, color: DsColor.warning, size: 22),
          ),
          const SizedBox(width: DsSpace.md),
          Expanded(
            child: Text(
              "delivery_stat_pending_remittances".tr(namedArgs: {'count': DsFormat.count(pending.count), 'amount': DsFormat.money(pending.amount)}),
              style: DsText.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle),
        ],
      ),
    );
  }
}
