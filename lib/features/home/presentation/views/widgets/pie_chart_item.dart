import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartItem extends StatelessWidget {
  const PieChartItem({super.key, required this.instance});
  final OrderStats instance;

  @override
  Widget build(BuildContext context) {
    const List<String> knownStatuses = ['pending', 'shipped', 'confirmed', 'delivered', 'cancelled', 'refunded'];

    OrdersByStatus getStatusData(String status) {
      return instance.ordersByStatus?.firstWhere(
            (o) => o.status == status,
            orElse: () => OrdersByStatus(status: status, count: 0, percentage: 0),
          ) ??
          OrdersByStatus(status: status, count: 0, percentage: 0);
    }

    final statusDataList = knownStatuses.map(getStatusData).toList();

    Map<String, double> dataMap = {
      for (final data in statusDataList)
        AppConstants.getStatusText(data.status): data.percentage?.toDouble() ?? 0.0,
    };

    final colorList = <Color>[
      DsColor.warning.withOpacity(0.8),
      DsColor.info.withOpacity(0.8),
      DsColor.info.withOpacity(0.8),
      DsColor.success.withOpacity(0.8),
      DsColor.danger.withOpacity(0.8),
      DsColor.textMuted.withOpacity(0.8),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(statusDataList.length, (index) {
              final data = statusDataList[index];
              final Color color = colorList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: color,
                    ),
                    SizedBox(width: AppConstants.width5(context)),
                    Text(
                      AppConstants.getStatusText(data.status),
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(width: AppConstants.width5(context)),
                    Text(
                      '(${data.count ?? 0})',
                      style: Styles.inter10400grey(context),
                    ),
                  ],
                ),
              );
            }),
          ),
          PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartRadius: MediaQuery.of(context).size.width / 4,
            colorList: colorList,
            initialAngleInDegree: 0,
            centerWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "s_share".tr(),
                  style: Styles.inter14500black(context),
                ),
                Text(
                  "100%",
                  style: Styles.inter10400grey(context),
                ),
              ],
            ),
            chartType: ChartType.ring,
            ringStrokeWidth: 30,
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: false,
              showChartValuesInPercentage: true,
              decimalPlaces: 0,
            ),
            legendOptions: const LegendOptions(
              showLegends: false, // نلغي الـ Legend الافتراضي
            ),
          ),
        ],
      ),
    );
  }
}