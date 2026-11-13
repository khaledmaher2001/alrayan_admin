import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/item_analytics_model.dart';
import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_item_analytics/get_item_analytics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_item_analytics/get_item_analytics_state.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';

class ItemAnalyticsView extends StatelessWidget {
  const ItemAnalyticsView({
    super.key,
    required this.productId,
    this.productName,
  });

  final int productId;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetItemAnalyticsCubit(getIt.get<HomeRepoImpl>()),
      child: _ItemAnalyticsBody(
        productId: productId,
        productName: productName,
      ),
    );
  }
}

class _ItemAnalyticsBody extends StatefulWidget {
  const _ItemAnalyticsBody({required this.productId, this.productName});

  final int productId;
  final String? productName;

  @override
  State<_ItemAnalyticsBody> createState() => _ItemAnalyticsBodyState();
}

class _ItemAnalyticsBodyState extends State<_ItemAnalyticsBody> {
  // `_groupBy == null` means a custom period (مدة محددة): the API gets the
  // selected Cairo days (inclusive) plus a grouping that suits the range length.
  String? _groupBy = 'day';
  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isCustomRange => _groupBy == null;

  @override
  void initState() {
    super.initState();
    final range = _presetRange(_groupBy!);
    _startDate = range.$1;
    _endDate = range.$2;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final cubit = context.read<GetItemAnalyticsCubit>();
    if (_groupBy != null) {
      cubit.getItemAnalytics(
        productId: widget.productId,
        groupBy: _groupBy,
      );
    } else {
      final days = _endDate.difference(_startDate).inDays;
      cubit.getItemAnalytics(
        productId: widget.productId,
        groupBy: days > 92 ? 'month' : 'day',
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
      );
    }
  }

  /// Display-only range that mirrors what the server reports for each grouping,
  /// so the date buttons stay meaningful while in grouping mode.
  (DateTime, DateTime) _presetRange(String groupBy) {
    final now = DateTime.now();
    switch (groupBy) {
      case 'month':
        return (DateTime(now.year - 1, now.month, now.day), now);
      case 'year':
        return (DateTime(now.year - 4, 1, 1), now);
      case 'day':
      default:
        return (now.subtract(const Duration(days: 30)), now);
    }
  }

  void _selectGroupBy(String value) {
    if (value == _customValue) {
      // Keep the dates on screen as the custom period and let the user adjust them.
      if (_isCustomRange) return;
      setState(() => _groupBy = null);
      _load();
      _pickDate(isStart: true);
      return;
    }
    final range = _presetRange(value);
    setState(() {
      _groupBy = value;
      _startDate = range.$1;
      _endDate = range.$2;
    });
    _load();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: isStart ? _endDate : DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      // Choosing a date switches to custom-range mode and drops `groupBy`.
      _groupBy = null;
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
        if (_startDate.isAfter(picked)) _startDate = picked;
      }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: DsColor.page,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: "i_analysis_of".tr(namedArgs: {"a": widget.productName ?? "i_the_product".tr()}),
                textColor: Colors.black,
                withNotifications: false,
                hasBack: true,
              ),
              SizedBox(height: AppConstants.height10(context)),
              _FilterPanel(
                groupBy: _groupBy,
                startDate: _startDate,
                endDate: _endDate,
                isCustomRange: _isCustomRange,
                onGroupChanged: _selectGroupBy,
                onPickStart: () => _pickDate(isStart: true),
                onPickEnd: () => _pickDate(isStart: false),
              ),
              Expanded(
                child: BlocBuilder<GetItemAnalyticsCubit, GetItemAnalyticsState>(
                  builder: (context, state) {
                    if (state is GetItemAnalyticsLoading ||
                        state is GetItemAnalyticsInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is GetItemAnalyticsError) {
                      return _ErrorBody(message: state.message, onRetry: _load);
                    }
                    if (state is GetItemAnalyticsSuccess) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width20(context),
                          vertical: AppConstants.height10(context),
                        ),
                        child: _AnalyticsContent(analytics: state.analytics),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}

/// Chip value for the custom period; never sent to the API.
const _customValue = 'custom';

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.groupBy,
    required this.startDate,
    required this.endDate,
    required this.isCustomRange,
    required this.onGroupChanged,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String? groupBy;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCustomRange;
  final ValueChanged<String> onGroupChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width20(context),
        vertical: AppConstants.height10(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("s_view_by".tr(), style: Styles.inter12500Black(context)),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              _GroupChip(
                  label: "s_daily".tr(),
                  value: 'day',
                  selected: groupBy,
                  onTap: onGroupChanged),
              SizedBox(width: AppConstants.width10(context)),
              _GroupChip(
                  label: "s_monthly".tr(),
                  value: 'month',
                  selected: groupBy,
                  onTap: onGroupChanged),
              SizedBox(width: AppConstants.width10(context)),
              _GroupChip(
                  label: "s_yearly".tr(),
                  value: 'year',
                  selected: groupBy,
                  onTap: onGroupChanged),
              SizedBox(width: AppConstants.width10(context)),
              _GroupChip(
                  label: "s_custom_period".tr(),
                  value: _customValue,
                  selected: groupBy ?? _customValue,
                  onTap: onGroupChanged),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                    label: "s_from".tr(), date: startDate, onTap: onPickStart),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width10(context)),
                child: Icon(Icons.arrow_forward,
                    size: AppConstants.sp15(context), color: AppColors.gray),
              ),
              Expanded(
                child:
                    _DateButton(label: "s_to".tr(), date: endDate, onTap: onPickEnd),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            isCustomRange
                ? "s_custom_range_data_follows_the_select".tr()
                : "s_the_range_follows_the_view_automatic".tr(),
            style: Styles.inter10400grey(context),
          ),
        ],
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding:
              EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : DsColor.fill,
            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryColor : DsColor.border,
            ),
          ),
          child: Text(
            label,
            style: Styles.inter12500Black(context)
                .copyWith(color: isSelected ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width10(context),
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          color: DsColor.fill,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: DsColor.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: AppConstants.sp15(context),
                color: AppColors.primaryColor),
            SizedBox(width: AppConstants.width5(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Styles.inter10400grey(context)),
                  Text(
                    '${date.year}-${_two(date.month)}-${_two(date.day)}',
                    style: Styles.inter12500Black(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.analytics});

  final ItemAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    final product = analytics.product;
    final summary = analytics.summary;
    final comparison = analytics.comparison;
    final buckets = analytics.buckets;

    final hasComparison = comparison != null &&
        (comparison.quantityChangePercent != null ||
            comparison.revenueChangePercent != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: product?.name ?? "s_product_overview".tr(),
                subtitle: _periodRangeText(analytics.period),
              ),
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      title: "s_sell_through_rate".tr(),
                      value: _percent(product?.sellThroughRate),
                      color: AppColors.primarySwatchColor,
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _HeroStat(
                      title: "s_total_sales".tr(),
                      value: _number(product?.totalSold),
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.height10(context)),
              Wrap(
                spacing: AppConstants.width10(context),
                runSpacing: AppConstants.height10(context),
                children: [
                  _MetricChip(
                    title: "s_current_stock".tr(),
                    value: _number(product?.currentStock),
                  ),
                  _MetricChip(
                    title: "s_current_price".tr(),
                    value: '${_number(product?.currentPrice)} ${"s_egp".tr()}',
                  ),
                  _MetricChip(
                    title: "s_supplier_price".tr(),
                    value: '${_number(product?.supplierPrice)} ${"s_egp".tr()}',
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.height15(context)),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("s_period_summary".tr(), style: Styles.inter16500black(context)),
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      title: "s_revenue".tr(),
                      value: '${_number(summary?.totalRevenue)} ${"s_egp".tr()}',
                      color: AppColors.primarySwatchColor,
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _HeroStat(
                      title: "s_profit".tr(),
                      value: '${_number(summary?.totalProfit)} ${"s_egp".tr()}',
                      color: DsColor.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.height10(context)),
              Wrap(
                spacing: AppConstants.width10(context),
                runSpacing: AppConstants.height10(context),
                children: [
                  _MetricChip(
                    title: "s_quantity_sold".tr(),
                    value: _number(summary?.totalQuantitySold),
                  ),
                  _MetricChip(
                    title: "s_profit_margin".tr(),
                    value: _percent(summary?.profitMargin),
                  ),
                  _MetricChip(
                    title: "s_orders".tr(),
                    value: _number(summary?.totalOrders),
                  ),
                  _MetricChip(
                    title: "s_unique_customers".tr(),
                    value: _number(summary?.uniqueCustomers),
                  ),
                  _MetricChip(
                    title: "s_average_selling_price".tr(),
                    value: '${_number(summary?.averageSellingPrice)} ${"s_egp".tr()}',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (hasComparison) ...[
          SizedBox(height: AppConstants.height15(context)),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "s_compared_with_the_previous_period".tr(),
                  style: Styles.inter16500black(context),
                ),
                SizedBox(height: AppConstants.height20(context)),
                Row(
                  children: [
                    Expanded(
                      child: _ChangeStat(
                        title: "s_quantity_change".tr(),
                        value: comparison.quantityChangePercent,
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: _ChangeStat(
                        title: "s_revenue_change".tr(),
                        value: comparison.revenueChangePercent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (buckets.isNotEmpty) ...[
          SizedBox(height: AppConstants.height15(context)),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("s_period_details".tr(), style: Styles.inter16500black(context)),
                SizedBox(height: AppConstants.height15(context)),
                ...buckets.map((bucket) => _BucketTile(bucket: bucket)),
              ],
            ),
          ),
        ],
        SizedBox(height: AppConstants.height20(context)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.inter16500black(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: AppConstants.height5(context)),
          Text(subtitle, style: Styles.inter10400grey(context)),
        ],
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            value,
            style: Styles.inter18500Black(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height10(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.greyColor[50],
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height5(context)),
          Text(value, style: Styles.inter14500black(context)),
        ],
      ),
    );
  }
}

class _ChangeStat extends StatelessWidget {
  const _ChangeStat({required this.title, required this.value});

  final String title;
  final num? value;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final isUp = (value ?? 0) >= 0;
    final color = !hasValue
        ? AppColors.gray
        : isUp
            ? DsColor.success
            : DsColor.danger;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height5(context)),
          Row(
            children: [
              if (hasValue)
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: AppConstants.sp15(context),
                  color: color,
                ),
              if (hasValue) SizedBox(width: AppConstants.width5(context)),
              Text(
                _change(value),
                style: Styles.inter18500Black(context).copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({required this.bucket});

  final ItemAnalyticsBucket bucket;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.height10(context)),
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: AppColors.greyColor[50],
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_bucketLabel(bucket.bucket),
                  style: Styles.inter12500Black(context)),
              Text(
                '${_number(bucket.revenue)} ${"s_egp".tr()}',
                style: Styles.inter14500black(context)
                    .copyWith(color: AppColors.primaryColor),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height5(context)),
          Row(
            children: [
              _BucketMeta(label: "s_quantity".tr(), value: _number(bucket.quantity)),
              SizedBox(width: AppConstants.width15(context)),
              _BucketMeta(label: "s_orders_2".tr(), value: _number(bucket.orders)),
              SizedBox(width: AppConstants.width15(context)),
              _BucketMeta(label: "s_profit".tr(), value: '${_number(bucket.profit)} ${"s_egp".tr()}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketMeta extends StatelessWidget {
  const _BucketMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: Styles.inter10400grey(context)),
        Text(value, style: Styles.inter12500Black(context)),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.sp20(context)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, color: DsColor.danger, size: 48),
          SizedBox(height: AppConstants.height10(context)),
          Text("s_couldn_t_load_the_analysis".tr(), style: Styles.inter16500black(context)),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Styles.inter12500Black(context)
                .copyWith(color: AppColors.gray),
          ),
          SizedBox(height: AppConstants.height20(context)),
          ElevatedButton(
              onPressed: onRetry, child: Text("s_retry".tr())),
        ]),
      ),
    );
  }
}

String _number(num? value) {
  if (value == null) return '0';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

String _percent(num? value) => value == null ? '-' : '${_number(value)}%';

String _change(num? value) {
  if (value == null) return '—';
  final sign = value > 0 ? '+' : '';
  return '$sign${_number(value)}%';
}

String _bucketLabel(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  return raw.split('T').first;
}

String _periodRangeText(ItemAnalyticsPeriod? period) {
  if (period == null) return '';
  final start = _bucketLabel(period.startDate);
  final end = _bucketLabel(period.endDate);
  if (start == '-' || end == '-') return '';
  return "i_from_x_to_x_36".tr(namedArgs: {"a": "${start}", "b": "${end}"});
}
