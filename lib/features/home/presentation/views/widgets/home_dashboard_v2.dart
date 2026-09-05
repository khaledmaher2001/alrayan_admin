import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/views/sales_report_details_view.dart';
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

/// "اليوم / 7 أيام / 30 يوم" pill selector.
class DashboardPeriodSelector extends StatelessWidget {
  const DashboardPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DashboardPeriod selected;
  final ValueChanged<DashboardPeriod> onChanged;

  static const _labels = {
    DashboardPeriod.today: "اليوم",
    DashboardPeriod.week: "7 أيام",
    DashboardPeriod.month: "30 يوم",
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: DashboardPeriod.values.map((period) {
        final isSelected = period == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: period == DashboardPeriod.month
                  ? 0
                  : AppConstants.width10(context),
            ),
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.height10(context),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                ),
                child: Text(
                  _labels[period]!,
                  style: Styles.inter14500black(context).copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// The dark "إجمالي المبيعات" hero card, with a period-over-period growth
/// badge and a minimal sparkline built from the matching `trends` series.
class TotalSalesHeroCard extends StatelessWidget {
  const TotalSalesHeroCard({
    super.key,
    required this.period,
    required this.recentStats,
    required this.trends,
  });

  final DashboardPeriod period;
  final RecentStats? recentStats;
  final Trends? trends;

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
    if (series.length < 2) return null;
    final previous = series[series.length - 2];
    final last = series.last;
    if (previous == 0) return null;
    return ((last - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final series = _series();
    final growth = _growthPercent(series);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إجمالي المبيعات",
            style: Styles.inter14500black(context).copyWith(color: Colors.white70),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "${_formatMoney(_revenue())} ج.م",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.inter24600black(context).copyWith(color: Colors.white),
          ),
          if (growth != null) ...[
            SizedBox(height: AppConstants.height5(context)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: growth >= 0 ? Colors.greenAccent : Colors.redAccent,
                  size: AppConstants.sp15(context),
                ),
                Text(
                  "${growth.abs().toStringAsFixed(1)}%",
                  style: Styles.inter14600black(context).copyWith(
                    color: growth >= 0 ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
          if (series.length >= 2) ...[
            SizedBox(height: AppConstants.height10(context)),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .06,
              child: _Sparkline(series: series),
            ),
          ],
        ],
      ),
    );
  }
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
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.white,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

/// Small white card used for "عدد الطلبات" / "عدد العملاء".
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.sp5(context)),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: AppConstants.sp20(context)),
          ),
          SizedBox(width: AppConstants.height10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Styles.inter18500Black(context)),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  title,
                  style: Styles.inter12500Black(context).copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

/// "طلبات جديدة" / "قيد التوصيل" / "مخزون منخفض" quick-access row.
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chevron_left, color: Colors.grey.shade400, size: AppConstants.sp15(context)),
                const Spacer(),
                Icon(icon, color: iconColor, size: AppConstants.sp20(context)),
              ],
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(value, style: Styles.inter18500Black(context)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Styles.inter10400grey(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// "أداء المبيعات" line chart + average order value / completion rate.
class SalesPerformanceSection extends StatelessWidget {
  const SalesPerformanceSection({
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
    const days = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
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
            title: "أداء المبيعات",
            subtitle: "اتجاه المبيعات خلال الفترة المختارة",
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
                  "لا توجد بيانات كافية لعرض الرسم البياني",
                  style: Styles.inter12500Black(context).copyWith(color: Colors.grey.shade600),
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
                  title: "متوسط قيمة الطلب",
                  value: "${_formatMoney(overview?.averageOrderValue as num?)} ج.م",
                  icon: Icons.trending_up,
                ),
              ),
              Container(width: 1, height: AppConstants.height30(context), color: Colors.grey.shade200),
              Expanded(
                child: _MiniMetric(
                  title: "نسبة اكتمال الطلبات",
                  value: "${_formatPercent(overview?.completionRate as num?)}%",
                  icon: Icons.check_circle_outline,
                  valueColor: Colors.green,
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
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
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
                    style: Styles.inter10400grey(context),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.secondaryColor,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryColor,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(.25),
                  AppColors.primaryColor.withOpacity(0),
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
        Text(title, style: Styles.inter10400grey(context)),
        SizedBox(height: AppConstants.height5(context) / 2),
        Row(
          children: [
            Text(
              value,
              style: Styles.inter16500black(context).copyWith(color: valueColor),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Icon(icon, size: AppConstants.sp15(context), color: valueColor ?? AppColors.primaryColor),
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
      return const HomeFeatureEmptyCard(
        title: "حالة الطلبات",
        message: "لا توجد بيانات كافية حاليا",
      );
    }

    final allStatuses = _mergedStatuses();

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("حالة الطلبات", style: Styles.inter16500black(context)),
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
                        Text("$totalOrders", style: Styles.inter18500Black(context)),
                        Text(
                          "الإجمالي",
                          style: Styles.inter10400grey(context),
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
                                style: Styles.inter12500Black(context),
                              ),
                            ),
                            Text("${s.count ?? 0}", style: Styles.inter14600black(context)),
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

String _formatMoney(num? value) {
  if (value == null) return '0';
  final v = value.toDouble();
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(1);
}

String _formatPercent(num? value) {
  if (value == null) return '0';
  return value.toDouble().toStringAsFixed(1);
}
