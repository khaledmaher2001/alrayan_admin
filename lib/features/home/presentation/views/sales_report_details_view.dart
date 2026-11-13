import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_sales_report/get_sales_report_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_sales_report/get_sales_report_state.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_analytics_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';

class SalesReportDetailsView extends StatelessWidget {
  const SalesReportDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetSalesReportCubit(getIt.get<HomeRepoImpl>())
        ..getSalesReport(
          startDate: _defaultStart(),
          endDate: _defaultEnd(),
        ),
      child: const _SalesReportDetailsBody(),
    );
  }

  static String _defaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .toIso8601String()
        .split('T')
        .first;
  }

  static String _defaultEnd() =>
      DateTime.now().toIso8601String().split('T').first;
}

class _SalesReportDetailsBody extends StatefulWidget {
  const _SalesReportDetailsBody();

  @override
  State<_SalesReportDetailsBody> createState() =>
      _SalesReportDetailsBodyState();
}

class _SalesReportDetailsBodyState extends State<_SalesReportDetailsBody> {
  late DateTime _startDate;
  late DateTime _endDate;
  _QuickFilter? _activeFilter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = now;
    _startDate = DateTime(now.year, now.month, now.day);
    _activeFilter = _QuickFilter.today;
  }

  void _applyFilter(DateTime start, DateTime end, [_QuickFilter? filter]) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _activeFilter = filter;
    });
    context.read<GetSalesReportCubit>().getSalesReport(
          startDate: _fmt(start),
          endDate: _fmt(end),
        );
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
      locale: const Locale('ar'),
      builder: (context, child) => _arabicDatePickerTheme(context, child),
    );
    if (picked != null) {
      _applyFilter(picked, _endDate);
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) => _arabicDatePickerTheme(context, child),
    );
    if (picked != null) {
      _applyFilter(_startDate, picked);
    }
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
                title: "s_sales_reports".tr(),
                textColor: Colors.black,
                withNotifications: false,
                hasBack: true,
              ),
              SizedBox(height: AppConstants.height10(context)),
              _DateFilterSection(
                startDate: _startDate,
                endDate: _endDate,
                activeFilter: _activeFilter,
                onQuickFilter: (filter) {
                  final now = DateTime.now();
                  DateTime start;
                  switch (filter) {
                    case _QuickFilter.today:
                      start = DateTime(now.year, now.month, now.day);
                    case _QuickFilter.last7Days:
                      start = now.subtract(const Duration(days: 7));
                    case _QuickFilter.last30Days:
                      start = DateTime(now.year, now.month - 1, now.day);
                    case _QuickFilter.thisMonth:
                      start = DateTime(now.year, now.month, 1);
                    case _QuickFilter.thisYear:
                      start = DateTime(now.year, 1, 1);
                  }
                  _applyFilter(start, now, filter);
                },
                onPickStart: _pickStart,
                onPickEnd: _pickEnd,
              ),
              Expanded(
                child: BlocBuilder<GetSalesReportCubit, GetSalesReportState>(
                  builder: (context, state) {
                    if (state is GetSalesReportLoading ||
                        state is GetSalesReportInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GetSalesReportError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.sp20(context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: DsColor.danger, size: 48),
                              SizedBox(height: AppConstants.height10(context)),
                              Text(
                                "s_couldn_t_load_the_report".tr(),
                                style: Styles.inter16500black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              Text(
                                state.message,
                                style: Styles.inter12500Black(context)
                                    .copyWith(color: AppColors.gray),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppConstants.height20(context)),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<GetSalesReportCubit>()
                                      .getSalesReport(
                                        startDate: _fmt(_startDate),
                                        endDate: _fmt(_endDate),
                                      );
                                },
                                child: Text("s_retry".tr()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is GetSalesReportSuccess) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width20(context),
                          vertical: AppConstants.height10(context),
                        ),
                        child: Column(
                          children: [
                            SalesReportDetailsContent(report: state.report),
                            SizedBox(height: AppConstants.height20(context)),
                          ],
                        ),
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

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  Widget _arabicDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      child: child!,
    );
  }
}

enum _QuickFilter { today, last7Days, last30Days, thisMonth, thisYear }

class _DateFilterSection extends StatelessWidget {
  const _DateFilterSection({
    required this.startDate,
    required this.endDate,
    required this.activeFilter,
    required this.onQuickFilter,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime startDate;
  final DateTime endDate;
  final _QuickFilter? activeFilter;
  final void Function(_QuickFilter) onQuickFilter;
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickChip(
                  label: "s_today".tr(),
                  isActive: activeFilter == _QuickFilter.today,
                  onTap: () => onQuickFilter(_QuickFilter.today),
                ),
                SizedBox(width: AppConstants.width10(context)),
                _QuickChip(
                  label: "s_last_7_days".tr(),
                  isActive: activeFilter == _QuickFilter.last7Days,
                  onTap: () => onQuickFilter(_QuickFilter.last7Days),
                ),
                SizedBox(width: AppConstants.width10(context)),
                _QuickChip(
                  label: "s_last_30_days".tr(),
                  isActive: activeFilter == _QuickFilter.last30Days,
                  onTap: () => onQuickFilter(_QuickFilter.last30Days),
                ),
                SizedBox(width: AppConstants.width10(context)),
                _QuickChip(
                  label: "s_this_month".tr(),
                  isActive: activeFilter == _QuickFilter.thisMonth,
                  onTap: () => onQuickFilter(_QuickFilter.thisMonth),
                ),
                SizedBox(width: AppConstants.width10(context)),
                _QuickChip(
                  label: "s_this_year".tr(),
                  isActive: activeFilter == _QuickFilter.thisYear,
                  onTap: () => onQuickFilter(_QuickFilter.thisYear),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _DatePickerButton(
                  label: "s_from".tr(),
                  date: startDate,
                  onTap: onPickStart,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width10(context)),
                child: Icon(
                  Icons.arrow_forward,
                  size: AppConstants.sp15(context),
                  color: AppColors.gray,
                ),
              ),
              Expanded(
                child: _DatePickerButton(
                  label: "s_to".tr(),
                  date: endDate,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : DsColor.fill,
          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
          border: Border.all(
            color: isActive
                ? AppColors.primaryColor
                : DsColor.border,
          ),
        ),
        child: Text(
          label,
          style: Styles.inter12500Black(context).copyWith(
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

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
            Icon(
              Icons.calendar_today_outlined,
              size: AppConstants.sp15(context),
              color: AppColors.primaryColor,
            ),
            SizedBox(width: AppConstants.width5(context)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Styles.inter10400grey(context),
                ),
                Text(
                  _formatDate(date),
                  style: Styles.inter12500Black(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
