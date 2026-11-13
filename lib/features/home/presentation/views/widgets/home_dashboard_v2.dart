import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/views/sales_report_details_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'home_analytics_sections.dart';

/// The three time-range presets the dashboard's hero card & trend chart can
/// be scoped to — mapped straight onto `RecentStats`/`Trends`' matching
/// today/weekly/monthly fields, so no extra request is needed to switch.
enum DashboardPeriod { today, week, month }

/// `trends.dailyRevenue` only includes days the store actually had a sale
/// on — a new/quiet store can easily have just 4-5 entries in there. Taking
/// "the last N array entries" as-is meant the window's start/end depended
/// on wherever real sales happened to exist (e.g. showing "Thursday to
/// Monday" for "7 أيام", or a 4-day spread like "20 to 23" for "30 يوم"),
/// not on the calendar. This instead always builds exactly `windowSize`
/// *consecutive calendar days ending today*, filling in 0 revenue for any
/// day with no sales — so "7 أيام" is always literally the last 7 days
/// including today, and "30 يوم" the last 30, no matter how sparse the data is.
List<DailyRevenue> dashboardDailyWindow(List<DailyRevenue>? daily, DashboardPeriod period) {
  final windowSize = period == DashboardPeriod.month ? 30 : 7;

  final byDate = <String, DailyRevenue>{};
  for (final entry in daily ?? <DailyRevenue>[]) {
    final date = DateTime.tryParse(entry.date ?? '');
    if (date == null) continue;
    byDate[_dateKey(date)] = entry;
  }

  final today = DateTime.now();
  final todayAtMidnight = DateTime(today.year, today.month, today.day);
  return List<DailyRevenue>.generate(windowSize, (i) {
    final day = todayAtMidnight.subtract(Duration(days: windowSize - 1 - i));
    final key = _dateKey(day);
    return byDate[key] ?? DailyRevenue(date: key, revenue: 0, orders: 0);
  });
}

String _dateKey(DateTime date) =>
    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

/// "اليوم / 7 أيام / 30 يوم" as one segmented control (a single decision,
/// so a single object — not three loose pills).
class DashboardPeriodSelector extends StatelessWidget {
  const DashboardPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DashboardPeriod selected;
  final ValueChanged<DashboardPeriod> onChanged;

  static const _labels = {
    DashboardPeriod.today: "home_period_today",
    DashboardPeriod.week: "home_period_week",
    DashboardPeriod.month: "home_period_month",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: DsColor.fill, borderRadius: BorderRadius.circular(DsRadius.md)),
      child: Row(
        children: [
          for (final period in DashboardPeriod.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: period == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: period == selected ? DsColor.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(DsRadius.sm),
                      border: period == selected ? Border.all(color: DsColor.border) : null,
                    ),
                    child: Text(
                      _labels[period]!.tr(),
                      style: DsText.label.copyWith(color: period == selected ? DsColor.text : DsColor.textMuted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Revenue panel: the one number the owner opens the app for, with its trend.
/// Orders and customers (all-time totals from `overview`) sit underneath as
/// supporting figures instead of competing coloured tiles.
class TotalSalesHeroCard extends StatelessWidget {
  const TotalSalesHeroCard({
    super.key,
    required this.period,
    required this.recentStats,
    required this.trends,
    this.totalOrders,
    this.totalCustomers,
  });

  final DashboardPeriod period;
  final RecentStats? recentStats;
  final Trends? trends;
  final num? totalOrders;
  final num? totalCustomers;

  num _revenue() {
    switch (period) {
      case DashboardPeriod.today:
        return (recentStats?.todayRevenue as num?) ?? 0;
      case DashboardPeriod.week:
        return (recentStats?.weeklyRevenue as num?) ?? 0;
      case DashboardPeriod.month:
        return (recentStats?.monthlyRevenue as num?) ?? 0;
    }
  }

  List<double> _series() {
    return dashboardDailyWindow(trends?.dailyRevenue, period)
        .map((e) => ((e.revenue as num?) ?? 0).toDouble())
        .toList();
  }

  double? _growthPercent(List<double> series) {
    // The series is daily, so the badge compares today with yesterday; for the
    // 7/30-day views there is no previous-period total to compare against.
    if (period != DashboardPeriod.today || series.length < 2) return null;
    final previous = series[series.length - 2];
    final last = series.last;
    if (previous == 0) return null;
    final growth = ((last - previous) / previous) * 100;
    // A tiny "yesterday" makes the percentage meaningless (e.g. 50,073,230%).
    return growth.abs() > 999 ? null : growth;
  }

  @override
  Widget build(BuildContext context) {
    final series = _series();
    final growth = _growthPercent(series);
    final up = (growth ?? 0) >= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DsColor.surface,
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.lg, DsSpace.lg, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("home_total_sales".tr(), style: DsText.label.copyWith(color: DsColor.textMuted)),
                const SizedBox(height: DsSpace.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("home_money".tr(namedArgs: {"v": formatMoney(_revenue())}), maxLines: 1, style: DsText.display),
                      ),
                    ),
                    if (growth != null) ...[
                      const SizedBox(width: DsSpace.sm),
                      DsStatusBadge(
                        status: null,
                        icon: up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        label: "home_vs_yesterday".tr(namedArgs: {"p": growth.abs().toStringAsFixed(1)}),
                        fg: up ? DsColor.success : DsColor.danger,
                        bg: up ? DsColor.successBg : DsColor.dangerBg,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (series.length >= 2)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Padding(padding: const EdgeInsets.only(top: DsSpace.sm), child: _Sparkline(series: series)),
            )
          else
            const SizedBox(height: DsSpace.lg),
          if (totalOrders != null || totalCustomers != null) ...[
            const Divider(height: 1),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _PanelFigure(icon: Icons.receipt_long_outlined, label: "home_orders_count".tr(), value: formatCount(totalOrders))),
                  const VerticalDivider(width: 1, color: DsColor.divider),
                  Expanded(child: _PanelFigure(icon: Icons.people_outline_rounded, label: "home_customers_count".tr(), value: formatCount(totalCustomers))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelFigure extends StatelessWidget {
  const _PanelFigure({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: DsSpace.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: DsColor.textMuted),
            const SizedBox(width: DsSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(value, maxLines: 1, style: DsText.number.copyWith(fontSize: 16)),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.series});

  final List<double> series;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i]),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: DsColor.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [DsColor.primary.withValues(alpha: .14), DsColor.primary.withValues(alpha: 0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kept for compatibility: a small figure card (orders / customers).
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => DsCard(child: _PanelFigure(icon: icon, label: title, value: value));
}

/// "Needs action" row: what is waiting, how many, and where to go.
/// A non-zero count is a tinted pill in the row's tone; zero stays quiet.
class DashboardActionRow extends StatelessWidget {
  const DashboardActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.tone = DsColor.primary,
    this.toneBg = DsColor.primarySoft,
    this.extra,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final num count;
  final Color tone;
  final Color toneBg;
  final Widget? extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return DsRow(
      icon: icon,
      title: title,
      onTap: onTap,
      showChevron: onTap != null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (extra != null) ...[extra!, const SizedBox(width: DsSpace.sm)],
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: active ? toneBg : Colors.transparent, borderRadius: BorderRadius.circular(DsRadius.pill)),
            child: Text(formatCount(count), style: DsText.bodyStrong.copyWith(color: active ? tone : DsColor.textSubtle, fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        ],
      ),
    );
  }
}

/// Kept for compatibility with older call sites.
class DashboardQuickStatCard extends StatelessWidget {
  const DashboardQuickStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DsGroup(children: [DsRow(icon: icon, title: title, value: value, onTap: onTap)]);
}

/// "أداء المبيعات" line chart + average order value / completion rate.
class SalesPerformanceSection extends StatelessWidget {
  SalesPerformanceSection({
    super.key,
    required this.period,
    required this.trends,
    required this.overview,
  });

  final DashboardPeriod period;
  final Trends? trends;
  final Overview? overview;

  List<_TrendPoint> _points() {
    final window = dashboardDailyWindow(trends?.dailyRevenue, period);
    final useDayNumbers = period == DashboardPeriod.month;
    return window
        .map((e) => _TrendPoint(
              useDayNumbers ? _dayNumber(e.date) : _shortDate(e.date),
              ((e.revenue as num?) ?? 0).toDouble(),
            ))
        .toList();
  }

  static String _shortDate(String? iso) {
    final date = DateTime.tryParse(iso ?? '');
    if (date == null) return '';
    final days = ["s_mon".tr(), "s_tue".tr(), "s_wed".tr(), "s_thu".tr(), "s_fri".tr(), "s_sat".tr(), "s_sun".tr()];
    return days[date.weekday - 1];
  }

  // The "30 يوم" series carries one point per day of the last month; showing
  // each point's full date/label made the x-axis unreadable, so this keeps
  // just the day-of-month number (falls back to the raw value if it isn't
  // a date at all).
  static String _dayNumber(String? iso) {
    final date = DateTime.tryParse(iso ?? '');
    return date != null ? "${date.day}" : (iso ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final points = _points();

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "s_sales_performance".tr(),
            subtitle: "s_sales_trend_over_the_selected_period".tr(),
            trailing: HomeViewAllButton(
              onTap: () => NavigationUtils.navigateTo(
                context: context,
                destinationScreen: const SalesReportDetailsView(),
              ),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          if (points.length < 2)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.height20(context)),
              child: Center(
                child: Text(
                  "s_not_enough_data_to_show_the_chart".tr(),
                  style: DsText.label.copyWith(color: DsColor.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * .18,
              child: _TrendChart(points: points),
            ),
          SizedBox(height: AppConstants.height15(context)),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  title: "s_average_order_value".tr(),
                  value: "home_money".tr(namedArgs: {"v": formatMoney(overview?.averageOrderValue as num?)}),
                  icon: Icons.trending_up,
                ),
              ),
              Container(width: 1, height: AppConstants.height30(context), color: DsColor.border),
              Expanded(
                child: _MiniMetric(
                  title: "s_order_completion_rate".tr(),
                  value: "${_formatPercent(overview?.completionRate as num?)}%",
                  icon: Icons.check_circle_outline,
                  valueColor: DsColor.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint(this.label, this.value);
  final String label;
  final double value;
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];
    final maxY = points.map((p) => p.value).fold<double>(0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 0 ? 1 : maxY / 3,
          getDrawingHorizontalLine: (_) => FlLine(color: DsColor.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              // Only thin labels out for the 30-point month view — the
              // week/today view has just 7 points, so every day gets its
              // own label instead of skipping every other one.
              interval: points.length > 10 ? (points.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[index].label,
                    style: DsText.caption,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => DsColor.text,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: DsColor.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: DsColor.primary,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  DsColor.primary.withValues(alpha: .25),
                  DsColor.primary.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DsText.caption),
        SizedBox(height: AppConstants.height5(context) / 2),
        Row(
          children: [
            Text(
              value,
              style: DsText.subheading.copyWith(color: valueColor),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Icon(icon, size: AppConstants.sp15(context), color: valueColor ?? DsColor.primary),
          ],
        ),
      ],
    );
  }
}

/// "حالة الطلبات" donut chart. All six known statuses are always shown in
/// the legend (even at 0), since `orderStats.ordersByStatus` only returns
/// statuses that currently have orders.
class OrderStatusDonutSection extends StatelessWidget {
  const OrderStatusDonutSection({super.key, required this.ordersByStatus, required this.totalOrders});

  final List<OrdersByStatus> ordersByStatus;
  final int totalOrders;

  /// Every status the app recognizes, always shown even at a count of 0 —
  /// the API only returns statuses that currently have orders, which used
  /// to make the legend look incomplete.
  static const _allStatuses = [
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
    'refunded',
  ];

  List<OrdersByStatus> _mergedStatuses() {
    final byStatus = {
      for (final s in ordersByStatus)
        if (s.status != null) s.status!: s,
    };
    return [
      for (final status in _allStatuses)
        byStatus[status] ?? OrdersByStatus(status: status, count: 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (ordersByStatus.isEmpty) {
      return HomeFeatureEmptyCard(
        title: "s_order_status".tr(),
        message: "s_not_enough_data_yet".tr(),
      );
    }

    final allStatuses = _mergedStatuses();

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("s_order_status".tr(), style: DsText.subheading),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .32,
                height: MediaQuery.of(context).size.width * .32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: MediaQuery.of(context).size.width * .11,
                        sections: [
                          for (final s in allStatuses)
                            if ((s.count ?? 0) > 0)
                              PieChartSectionData(
                                value: (s.count ?? 0).toDouble(),
                                color: AppConstants.getTextColor(s.status),
                                showTitle: false,
                                radius: MediaQuery.of(context).size.width * .05,
                              ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$totalOrders", style: DsText.number),
                        Text(
                          "s_total".tr(),
                          style: DsText.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in allStatuses)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
                        child: Row(
                          children: [
                            Container(
                              width: AppConstants.width10(context),
                              height: AppConstants.width10(context),
                              decoration: BoxDecoration(
                                color: AppConstants.getTextColor(s.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                            Expanded(
                              child: Text(
                                AppConstants.getStatusText(s.status),
                                style: DsText.label,
                              ),
                            ),
                            Text("${s.count ?? 0}", style: DsText.bodyStrong),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 1234567.5 → "1,234,567.5" (Latin digits, like the rest of the app).
String formatMoney(num? value) => NumberFormat('#,##0.##', 'en').format(value ?? 0);

/// 12345 → "12,345".
String formatCount(num? value) => NumberFormat('#,##0', 'en').format(value ?? 0);

String _formatPercent(num? value) {
  if (value == null) return '0';
  return value.toDouble().toStringAsFixed(1);
}
